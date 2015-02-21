//
//  face_filter.cpp
//  image_pipeline
//
//  Created by Scott Trappe on 8/20/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <vector>
#include <limits>
#include <numeric>

#include <opencv2/opencv.hpp>
#include "opencv2/core/core.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/objdetect/objdetect.hpp"
#include <opencv2/legacy/legacy.hpp>

#include "common.h"
#include "face_filter.h"
#include "kokko_image.h"

using namespace std;
using namespace cv;

// The original version of the convex hull filter used 8-bit channel values
// to represent either RGB or CIE-Lab color information. For Lab, this presents
// a problem because the definitions of a* and b* are signed, not unsigned,
// quantities, and all three are normally represented as floating point values.
// OpenCV has a representation for Lab as unsigned 8-bit, by biasing a* and b*
// by 128 (changing their range from [-127, 127] to [1, 255], and multiplying
// L* by 2.55 so that more resolution of the Luminenance value is preserved
// (and making its range [0, 255]). However, this means that in color space
// terms one cannot calculate the "distance" between two colors (using the
// traditional delta-e calculation) without compensating for the scale
// difference for L*. So the following define will change the internal
// representation to be floating point, preserving the conventional definition
// of the Lab values.

#define LAB_FLOAT
#ifdef LAB_FLOAT
typedef Point2f	    CPoint2;
typedef Vec3f	    CVec3;
typedef float	    Chan;
#define	CSCALE(x)   ((x) / 255.0)	// scale value 0-255 -> [0.0, 1.0]
#else
typedef Point	    CPoint2;
typedef Vec3b	    CVec3;
typedef int	    Chan;
#define CSCALE(x)   (x)
#endif

// PRINT_COORDINATES, if defined, causes the original color values from the
// chart definition to be printed, along with the resulting points from the
// creation of the convex hull
//#define	PRINT_COORDINATES

typedef struct {
    string	    debugFilePrefix;	// where to write debug output to
    vector<CPoint2> contours[3];
} FilterSkinTonesHullCtx;


// filterSkinTonesHullInit -- Allocate and initialize any saved context for the
// skin tones color filter based on a convex hull
//
// filterSkinHull builds a three dimensional convex hull using R, G, and B
// as the three axes; the points from the color chart are plotted in space
// and a convex hull constructed where those points are on the "shell" of
// the hull.
//
// Actually, we approximate the three-dimensional shape by building three
// two-dimensional contours; each contour is parallel to one axis: an RG
// contour, an RB contour, and a GB contour.

FilterCtxPtr filterSkinTonesHullInit(SharedImageResources& rsrc, bool useLab)
{
    // Build a 1-dimensional matrix with the RGB color values; this makes
    // conversion to Lab easy.
    vector<CVec3> bgr_points;
    const vector<ColorRegion>& rgs = rsrc.getChartRegions();
    for (auto reg = rgs.cbegin(); reg != rgs.cend(); ++reg)
	if (reg->type == NORMAL)	// only want color patches, not B & W
	    // Build the vector as BGR, to match the image channel order.
	    // If using floating point Lab, must scale the integer 0-255 to
	    // float 0.0-1.0 for proper conversion
	    bgr_points.push_back(CVec3(CSCALE(reg->printed_color.blue),
				       CSCALE(reg->printed_color.green),
				       CSCALE(reg->printed_color.red)));

    // Use the template version of Mat (Mat_) since we know the types; this
    // allows us to use C++ iterators in the next step.
    Mat_<CVec3> colors(bgr_points), labColors;
    cvtColor(colors, labColors, CV_BGR2Lab);
    
    // Create 3 vectors of 2d points, all the possible combinations from three
    // coordinates: (x,y,z) -> (x,y), (x,z), (y,z).
    // The order is arbitrary, but must be consistent between this function
    // and the actual color filter or the results will be meaningless. Mapping:
    //	0 = (L*, a*)
    //	1 = (L*, b*)
    //	2 = (a*, b*)
    
    vector<CPoint2>vertexes[3];
    for (CVec3 pixel : labColors) {
	vertexes[0].push_back(CPoint2(pixel[0], pixel[1]));
	vertexes[1].push_back(CPoint2(pixel[0], pixel[2]));
	vertexes[2].push_back(CPoint2(pixel[1], pixel[2]));
    }
    
    // Allocate space to store the results
    shared_ptr<FilterSkinTonesHullCtx> ctx = make_shared<FilterSkinTonesHullCtx>();
    ctx->debugFilePrefix = rsrc.getIntermediateFilePath();

#ifdef PRINT_COORDINATES
    ofstream hullDetails;
    bool debug = ctx->debugFilePrefix != "";
    if (debug)
	hullDetails.open(ctx->debugFilePrefix + "image.fdbg.txt");
#endif
    
    // Now create the contours from the point sets, one plane at a time
    for (auto plane = 0; plane < 3; plane++) {
	vector<int> hull;
	
	// convextHull() takes as input a 1-dimenstional Mat containing the set
	// of points that represent a 2d contour. Create an anonymous Mat to
	// hold the vector. The output is a vector; each element is an index
	// into the source Mat; the subset of points that form a convex hull.
	convexHull(Mat_<CPoint2>(vertexes[plane]), hull);
	
	// Save the points forming the contour
	for (int vertex_inx : hull)
	    ctx->contours[plane].push_back(vertexes[plane][vertex_inx]);
	
#ifdef PRINT_COORDINATES
	if (debug) {
	    static const char *planeNames[3] = {"L*-a*", "L*-b*", "a*-b*"};
	    
	    // Display the plane coordinates
	    hullDetails << "Plane " << planeNames[plane]
	                << ":\n    Original coordinates:\n";
	    int pixnum = 0;
	    for (CPoint2 p : vertexes[plane])
		hullDetails << "\t" << ++pixnum << ": " << p.x << ", " << p.y << endl;
	    hullDetails << "    Contour coordinates:\n";
	    pixnum = 0;
	    for (CPoint2 p : ctx->contours[plane])
		hullDetails << "\t" << ++pixnum << ": " << p.x << ", " << p.y << endl;
	    hullDetails << endl;
	}
#endif
    }

#ifdef PRINT_COORDINATES
    hullDetails.close();
#endif

    return ctx;
}


// filterSkinTonesHull -- mask out pixels where the color doesn't lie within the
//			  convex hull formed by the color patches on the chart
//
// For each pixel in the input image, we want to measure the pixel to determine
// its "distance" from the convex hull of "valid skin colors". If the pixel is
// inside or on the surface of the convex hull, it is obviously valid. But if
// it is more than some delta outside of the hull, it is not a valid pixel and
// should not be included in the set of skin pixels to be analyzed.
//
// We extract the three possible 2D coordinates of the 3D point and measure
// the distance of each 2D cooridinate against the contour recorded in the
// corresponding plane; if the distance is greater than a certain threshold in
// ANY of the planes, it is marked bad. distThresholds[] specifies this limit.
//
// The values in distThresholds[] were chosen based on (very little)
// experimentation; they worked well enough that no deep investigation was
// performed. A good follow-up action would be to determine more precisely
// what the threshold should be.
//
// A second filtering step is also performed. The range of luminance values
// from the "good" pixels resulting from the previous pass is calculated and
// all pixels at the bottom 10% of luminance or the top 10% are eliminated.
//
// NOTE: Input and output matrices are always in sRGB. Internally, for analysis
// purposes, images are first converted to CIE-Lab color space. Because Lab more
// closely conforms to how humans perceive color, the "distance" measurements
// are more relevant.
//
// For human analysis, it is helpful to look at the image with the bad pixels
// marked so they are easily spotted. If debug is enabled, we generate a
// special image file where bad pixels are colored with primary colors; the
// pixels are sorted into different bins. Four colors indicate pixels that
// failed the convex hull test; the distance is indicated by the color, from
// green (relatively close) to yellow, to red and finally to black (very far
// away). Pixels eliminated because of the luminance clipping are colored blue.
//
// NOTE 2: The color distance is calculated as the square root of the sum of
// squares of the individual component distances, i.e.:
//
//	dist = sqrt( (L2 - L1)**2 + (a2 - a1)**2 + (b2 - b1)**2 )
//
// This corresponds to the original definition of delta-e (CIE76), a standard
// measure in color science to determine the degree of difference between two
// colors. Subsequently, the definition of delta-e has become increasingly more
// sophisticated to address perceptual non-uniformities; I didn't see that the
// added complexity would provide much benefit since we are just looking for a
// gross match (see https://en.wikipedia.org/wiki/Color_difference for a good
// description of how the delta-e calculation has evolved over time).
//
// NOTE: For the CIE-Lab color space


Mat filterSkinTonesHull(const Mat& face, FilterCtxPtr context, const string& imageName)
{
    static const Vec3b pixelBlack  = Vec3b(0, 0, 0);
    static const Vec3b pixelBlue   = Vec3b(255, 0, 0);
    //    static const Vec3b pixelCyan   = Vec3b(255, 255, 0);
    static const Vec3b pixelRed    = Vec3b(0, 0, 255);
    static const Vec3b pixelGreen  = Vec3b(0, 255, 0);
    static const Vec3b pixelYellow = Vec3b(0, 255, 255);
    static const double distThreshold[3] = {
#ifdef LAB_FLOAT
	15, 15, 20.0		    // L range is smaller by sqrt(2.55)
#else
	10.0, 10.0, 10.0	    //
#endif
    };
#ifdef	COLOR_BY_DISTANCE
    static const struct error_category {
	double		errLimit;   // if distance >= this, color the pixel...
	const Vec3b&	color;	    // ... with this color
    } errorCategory[4] = {
#ifdef LAB_FLOAT
	{40.0, pixelRed},	    // distances         >= 21
	{30.0, pixelYellow},	    // distances between >= 14 && < 21
	// The value below should be chosen to be no larger than the smallest
	// value in distThreshold, otherwise pixels will be coded black that
	// are actually close to being in range. It can't be zero, we reserve
	// zero for "all three planes are bad".
	{ 1.0, pixelGreen},	    // distances between >= 1 && < 14
#else
	{30.0, pixelRed},	    // distances         >= 30
	{15.0, pixelYellow},	    // distances between >= 15 && < 30
	{ 1.0, pixelGreen},	    // distances between >=  1 && < 15
#endif
	{ 0.0, pixelBlack}	    // must be last element, catch-all
    };
#endif	    // COLOR_BY_DISTANCE
	
    // Initial values are OK whether the lab representation is float or uchar
    Chan minL = Chan(255);	    // track minimum L value
    Chan maxL = Chan(0);	    // and maximum L value
    
    // Get the three contours
    shared_ptr<FilterSkinTonesHullCtx>ctx = static_pointer_cast<FilterSkinTonesHullCtx>(context);
    
    Mat results = face.clone();	    // filtered results written here
    Mat debugImage;
    bool debug = (ctx->debugFilePrefix != "");
    
    if (debug) {
	debugImage = face.clone();
    }
    int badPoints = 0;		    // count of how many points we are throwing out
    
    Mat imageToAnalyze;
#ifdef LAB_FLOAT
    {
	Mat scaledBGR;
	// convert from CV_8UC3 to CV_32FC3, and scale 0..255 values to 0..1
	face.convertTo(scaledBGR, CV_32FC3, 1.0/255.0);
	cvtColor(scaledBGR, imageToAnalyze, CV_BGR2Lab);
    }
#else
    cvtColor(face, imageToAnalyze, CV_BGR2Lab);
#endif
	
    for (int r = 0; r < imageToAnalyze.rows; r++)
	for (int c = 0; c < imageToAnalyze.cols; c++) {
	    CVec3 pixel = imageToAnalyze.at<CVec3>(r, c);
	    CPoint2 ptInPlane[3];
	    // This must exactly match filterSkinTonesHullInit or results will be wrong!
	    ptInPlane[0] = CPoint2(pixel[0], pixel[1]);
	    ptInPlane[1] = CPoint2(pixel[0], pixel[2]);
	    ptInPlane[2] = CPoint2(pixel[1], pixel[2]);
	    
	    // Now compare the three points to see where they lie with respect
	    // to the three contour planes. pointPolygonTest() returns the
	    // distance:
	    //	    < 0 ==> outside the contour
	    //	    = 0 ==> on the countour edge
	    //	    > 0 ==> inside the contour
	    // We're not really interesting in knowing how far inside the
	    // hull the point is, so negate the result so we can measure how
	    // far we are outside using positive values -- easier to understand.
	    int planesOutOfRange = 0;
#ifdef COLOR_BY_DISTANCE
	    double cumDistance = 0.0;
#endif
	    double errDistance[3];	// how far is pixel out of range
	    for (auto plane = 0; plane < 3; plane++) {
		double distance = -pointPolygonTest(ctx->contours[plane],
						    ptInPlane[plane], true);
		errDistance[plane] = distance - distThreshold[plane];
		if (errDistance[plane] > 0.0)
		    planesOutOfRange++;
#ifdef COLOR_BY_DISTANCE
		cumDistance += distance * distance;	// square of delta
#endif
	    }
	    if (planesOutOfRange) {
		results.at<Vec3b>(r, c) = pixelBlack;	// mask off pixel
		if (debug) {
		    badPoints++;
#ifdef COLOR_BY_DISTANCE
		    // colors indicate "how far" the pixel is out of range
		    if (planesOutOfRange == 3)
			// if all three planes failed, force the distance to
			// zero which will be coded as black: "really bad".
			cumDistance = 0.0;
		    else
			// Calculating the Euclidean distance between two
			// points, the square root of the sum-of-the-squares.
			cumDistance = sqrt(cumDistance);
		    // Determine which "bin" to classify this bad pixel as
		    int i = 0;
		    while (cumDistance < errorCategory[i].errLimit)
			i++;
		    debugImage.at<Vec3b>(r, c) = errorCategory[i].color;
#else
		    // find which plane had the largest delta and color the
		    // pixel to mark the plane
		    int plShow = -1;
		    double largestDist = 0.0;
		    for (auto plane = 0; plane < 3; plane++)
			if (errDistance[plane] > largestDist) {
			    largestDist = errDistance[plane];
			    plShow = plane;
			}
		    debugImage.at<Vec3b>(r, c) = (plShow == 0)? pixelRed :
			                         (plShow == 1)? pixelGreen :
						 /* plShow==2 */ pixelYellow;
#endif		// COLOR_BY_DISTANCE
		}
	    } else if (pixel[0] > 0.0) {
		// Pixel is good; channel 0 is L*, the luminance.
		// Record the minimum and maximum luminance seen in the image
		if (pixel[0] < minL)
		    minL = pixel[0];
		if (pixel[0] > maxL)
		    maxL = pixel[0];
	    }
	}
    
    // Eliminate any pixel where the luminance is in the bottom 15% or top 10%
    // of the luminance range.
    Chan rangeL = maxL - minL;
    Chan lowerL = Chan(rangeL * 0.15) + minL;
    Chan upperL = Chan(rangeL * 0.9) + minL;
    
    // Now clip all input values outside this range. For now, just marking
    // them in blue. We only mark pixels not already masked out -- this is
    // an extra level of pixel filtering.
    for (int r = 0; r < imageToAnalyze.rows; r++)
	for (int c = 0; c < imageToAnalyze.cols; c++)
	    if (results.at<Vec3b>(r, c) != pixelBlack) {
		// only mark pixels not already masked out
		float lum = imageToAnalyze.at<CVec3>(r, c)[0];
		if (lum < lowerL || lum > upperL) {
		    results.at<Vec3b>(r, c) = pixelBlack;
		    if (debug)
			debugImage.at<Vec3b>(r, c) = pixelBlue;
		    badPoints++;
		}
	}

    if (debug)
	imwrite(ctx->debugFilePrefix + imageName + ".xhul.png", debugImage);

    return results;
}



