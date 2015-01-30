//
//  kokko_image.cpp
//  image_pipeline
//
//  Created by Scott Trappe on 8/21/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//

#include "common.h"
#include "color_measure.h"
#include "kokko_image.h"
#if (!TARGET_OS_IPHONE)
// On iOS, all images are represented using UIImage objects, and the metadata
// for an image (such as the rotation) is accessed using methods of that class.
// We will never get input images as JPEG or PNG files. Consequently, there is
// no need to use the Exiv2 library, and I don't want to have to port it to
// iOS right now. So when the target OS is iOS, just omit this library and
// raise an exception if we pass in an image file.
#include <exiv2/exiv2.hpp>
#endif	// !TARGET_OS_IPHONE

using namespace std;
using namespace cv;

// The constant MAX_IMAGE_SIZE limits the size of images for analysis. Any
// image where either dimension exceeds this will be rescaled to stay within
// this limit. This is intended to be 'invisible' to the caller; all image
// coordinates (x, y, height, and width) reported to the user of the class
// will be maintained relative to the original size.
//
// Essentially, this value is a way of trading off memory use and execution
// speed for reduced accuracy. Smaller values will obviously take less memory
// and run faster. But at some point, the number of pixel in the chart will
// be too few and either we won't detect the chart at all or we will misread
// the color values (because they will be averaged with pixels outside the
// color square). The same could happen for the face.
//
// Having this limit is essential to getting "reasonable" performance; the 8MP
// image captured by the iPhone 5s rear-facing camera took over a minute to
// analyze. Shrinking to < 1 megapixel reduced the run time to under 15 seconds,
// without any other tuning of the algorithms.
//
// The imaging experiments reported in the HP paper resized all captured
// images (externally) to ~500 pixels in either dimension and they got OK
// results. Still, it seems prudent to use a larger value at first (to be
// "safe" and have more than enough pixels to analyze). As we gain experience,
// we can tune the value to find an optimal balance between size and robustness.
// I chose 960 (rather than 1000) thinking that was more likely to produce
// rational values for the shrink factor, reducing the blending across pixels.
// I don't know if it really matters; Jerome used 1000 in an earlier version.

#define MAX_IMAGE_SIZE	    960

// Forward references
static	int getEXIFOrientation(const string& image_name);
static	Mat recolorImage(const Mat &input, const ColorMeasure &measures);

// methods for SharedImageResources
void SharedImageResources::init(const std::string& chartDefFile,
				const std::string& faceCascadeFile)
{
    // Load the cascade for face detection
    faceModel.load(faceCascadeFile);
    if (faceModel.empty())
	throw KokkoException("could not load face cascade file '" + faceCascadeFile + "'");
    
    // Load chart
    detector.init(chartDefFile);
    debugFPath = "";
    faceFilterFunc = NULL;
    colorFilterFunc = NULL;
}


void SharedImageResources::setIntermediateFilePath(const string& inbetweenFilePath)
{
    // if the debugFPath value is != "", then the class user
    // wants intermediate results saved during the pipeline execution.
    // The value of the string is a path plus a base file name; only
    // an extension should be appended to distinguish one file from another.
    
    debugFPath = inbetweenFilePath;
}


// Public Methods for KokkoImage

cv::Rect KokkoImage::getChartRect()
{
    if (!foundChart)
	findChart();
    return scaleRect(chartRect);
}


cv::Rect KokkoImage::getFaceRect()
{
    if (!foundFace)
	findFace();
    return scaleRect(faceRect);
}


cv::Mat KokkoImage::getFaceImage()
{
    if (!foundFace)
	findFace();
    return filteredFace;
}


const FaceRank& KokkoImage::getFaceRank()
{
    if (!facesRanked)
	rankFaces();
    return matches;
}

SkinPixels KokkoImage::getExtractedSkin()
{
    if (!skinIsolated)
	extractSkinPixels();
    return extractedSkin;
}

const Recommendations& KokkoImage::getRecommendations()
{
    if (!madeRecoms)
	makeRecommendations();
    return brandsShades;
}


// Private methods for KokkoImage

// This is the initialization for all the class instance variables; all
// constructors will eventually call this function. Should ONLY be called
// from a constructor, never later.

void KokkoImage::initWithImage(SharedImageResources *rsrc,
			       const Mat& image,
			       const string& imName)
{
    const static cv::Rect zeroRect = cv::Rect(Point(0, 0), Size(0, 0));
    
    if (!rsrc)
	throw KokkoException("INTERNAL ERROR: call to KokkoImage with NULL shared resource point");
    shared = rsrc;
    
    // If needed, scale the image so that we don't have to operate on huge data
    // sets. We remember the shrink factor so that we can scale coordinates back
    // and forth between the shrunken image (which all the dependent routines
    // operate on) and the original image (which of course is what the caller
    // gave us and therefore expects coordinates to be relative to.)
    //
    // The choice of 960 is somewhat arbitrary; Jerome's original version used
    // 1000 as the maximum; older pipeine versions tried to limit the maximum
    // size to 500.I thought 960 was more likely to result in rational
    // values for shrink and thus fewer "blended" pixels. Not sure it reall
    int max_size = std::max(image.cols, image.rows);
    if (max_size > MAX_IMAGE_SIZE) {
	double shrink = double(MAX_IMAGE_SIZE) / max_size;
	// resize() will allocate a new cv::Mat with the appropriate rows/cols
	// and copy over all the data.
	// Note: must qualify Size() with cv:: because Size is also defined in
	// certain iOS header files.
	resize(image, sizedImage, cv::Size(0,0), shrink, shrink, INTER_LANCZOS4);
	scaleBy = 1.0 / shrink;		// save the multiplier to get back
    } else {
	// make a deep copy of the original image so can operate on it without
	// affecting the caller's data.
	sizedImage = image.clone();
	scaleBy = 1.0;			// sized image same as original
    }
    
    // remember name off image, if any
    imageName = imName;
    debugImagePath = shared->debugFPath;
    if (debugImagePath != "")
	// if debugFPath == "", then debug files are not to be produced,
	// which is why we check before appending the image name or a default
	debugImagePath += (imName != "")? imName : "image";

    // These boolean variables keep track of the progress through the processing
    // of the image. Calls to any method are allowed; they will simply invoke
    // the necessary preceding stages if necessary to make sure the right
    // information is available.
    foundChart = foundFace = skinIsolated = facesRanked = madeRecoms = false;
    chartRect = zeroRect;
    faceRect = zeroRect;
    
    // if brands is the empty set, any brand can be recommended; otherwise the
    // recommendations are limited to the brands specified.
    brands = BrandSet();
}


KokkoImage::KokkoImage(SharedImageResources *rsrc,
		       const string& imageFileName)
{
    Mat originalImage = imread(imageFileName);
    Mat rotated;
    
    if (!originalImage.data)
	throw KokkoException("could not read image file '" + imageFileName + "'");
    
    // retrieve the EXIF orientation information; if none exists, -1 is
    // returned. Otherwise, rotate or flip the image if necessary to put in
    // the standard orientation.
    switch (getEXIFOrientation(imageFileName)) {
	case 8:			    // rotate 90 degrees left
	    transpose(originalImage, rotated);
	    flip(rotated, originalImage, 0);
	    break;
	    
	case 3:			    // rotate 180 degrees
	    flip(originalImage, rotated, -1);
	    originalImage = rotated;
	    break;
	    
	case 6:			    // rotate 90 degrees right
	    transpose(originalImage, rotated);
	    flip(rotated, originalImage, 1);
	    break;
	    
	case -1:
	    // no orientation information
	    break;
	    
	default:
	    // ignore other rotations
	    break;
    }
    
    // get the base name of the image file
    string baseName = imageFileName;
    string::size_type start;
    if ((start = baseName.find_last_of("/\\")) != string::npos)
	baseName.erase(0, start + 1);
    
    // strip off the extension, if any
    if ((start = baseName.find('.')) != string::npos)
	baseName.erase(start);
    
    // let initWithImage do the remainder of the initialization
    initWithImage(rsrc, originalImage, baseName);
}


// findChart -- Find the chart in the image and save its coordinates
void KokkoImage::findChart()
{
    try {
	// Find the chart in the resized image. Eventually, this function
	// should just find the chart and return the coordinates. All the
	// rest of the work to extract the chart colors should be deferred
	// to a later step, that way the chart finder can run faster
	// (possibly fast enough to run at video frame rates).  !!FIXME!!
	chartRect = shared->detector.detect(sizedImage, debugImagePath);
	
	// detect will throw an exception if it doesn't find the chart, so
	// if we get here then the chart was found.
	foundChart = true;
    }
    catch (cv::Exception e) {
	throw KokkoException("OpenCV error: " + e.msg );
    }
}


// findFace -- Find the face in the image and save its coordinates
void KokkoImage::findFace()
{
    try {
	// Apply openCV face detector
	vector<cv::Rect> face_coor;
	
	shared->faceModel.detectMultiScale(sizedImage, face_coor,
					   1.1, 5, 0 |CV_HAAR_FIND_BIGGEST_OBJECT,
					   cv::Size(0, 0));
	
	if (face_coor.empty())
	    throw KokkoException("could not find a face in the image file\n");
	
	// detectMultiScale returns a vector of rectangles with the coordinates
	// for each face it found. I don't know if it ranks the faces by size,
	// or "certainty" of recognition, or anything. We just choose the first
	// one. Someday, add checks that either face_coor.size() == 1, or do
	// something to handle multiple faces being returned.   !!FIXME!!
	faceRect = face_coor[0];
	filteredFace = sizedImage(faceRect).clone();
	foundFace = true;
	
	if (debugImagePath != "") {
	    // Grab the subset of the image that is the detected face bounding
	    // box and save it to a temporary file.
	    // At some point we will want to move this from here to
	    // extractSkinPixels() to reduce the overhead of this function.
	    imwrite(debugImagePath + ".fbox.png", filteredFace);
	}
	// detect will throw an exception if it doesn't find the chart, so
	// if we get here then the chart was found.
    }
    catch (cv::Exception e) {
	throw KokkoException("OpenCV error: " + e.msg );
    }
}


void KokkoImage::extractSkinPixels()
{
    if (!foundChart)			// Need chart location
	findChart();
    if (!foundFace)			// Need face location
	findFace();
    
    if (shared->faceFilterFunc != NULL) {
	Mat adjFace = shared->faceFilterFunc(filteredFace, shared->faceFilterContext);
	filteredFace = adjFace;
	// OPTIONAL DEBUG STEP: Save new face image here as unique file
    }
    
    // create color transform
    ColorMeasure measure(shared->detector.get_chart());
    
    // recolorImage() is slow. So for the non-debug case, only
    // color-correct the (much smaller) face area.
    Mat recoloredFace = recolorImage(filteredFace, measure);
    
    if (shared->colorFilterFunc != NULL) {
	Mat adjColors = shared->colorFilterFunc(recoloredFace, shared->colorFilterContext);
	recoloredFace = adjColors;
	// OPTIONAL DEBUG STEP: Save new recolored image here as unique file
	if (debugImagePath != "")
	    imwrite(debugImagePath + ".xclr.png", recoloredFace);
    }

    extractedSkin.load(recoloredFace, SkinPixels::l_noMinMax);
    extractedSkin.setImageID(imageName);
    skinIsolated = true;
    
    if (debugImagePath != "") {
	// Save sampled color values
	shared->detector.get_chart().save_sampled_data(debugImagePath + ".cclr.txt");
	
	// Save a copy of the original image after it was color-corrected.
	// We avoid recoloring the entire image in general because this is
	// a very slow operation. Normal case is to recolor just the
	// extracted face area.
	Mat color_corrected = recolorImage(sizedImage, measure);
	imwrite(debugImagePath + ".xfix.png", color_corrected);
	
	// Write out the actual pixel values from the face
	extractedSkin.save(debugImagePath + ".fpix.txt");
    }
}


// rankFaces -- Match the face in the current image against our database of
// exemplar faces and rank them from closest to farthest match (in terms of
// skin color)

void KokkoImage::rankFaces()
{
    if (!skinIsolated)
	extractSkinPixels();
    
    // This feels like a hack that I have to manually force the format to
    // to f_counts because I know the match function will eventually call
    // KuiperCounts and need the data in this format. I have to do it here
    // because match() takes a const argument so it can't alter the
    // skin data. This is F*cked up.!  SRT 2015/01/26.
    extractedSkin.setFormat(SkinPixels::f_counts);
    
    matches = shared->refImages.match(extractedSkin);
    // match can cause an exception so if we reach this point we have
    // ranked the faces. (Note that matches.size() could be 0).
    facesRanked = true;
}


void KokkoImage::makeRecommendations()
{
    if (!facesRanked)
	rankFaces();

    brandsShades = shared->refImages.recommend(matches, brands);
    madeRecoms = true;
}


static int getEXIFOrientation(const std::string &image_name)
{
#if TARGET_OS_IPHONE
    throw KokkoException("EXIF library has not been ported to iOS");
#else	// TARGET_OS_IPHONE
    Exiv2::Image::AutoPtr image;
    
    try {
	image = Exiv2::ImageFactory::open(image_name);
    }
    catch (Exiv2::AnyError& e) {
	// std::cout << "Caught Exiv2 exception '" << e << "'\n";
	return -1;
    }

    assert(image.get() != 0);
    image->readMetadata();

    Exiv2::ExifData &exifData = image->exifData();
    if (exifData.empty()) {
	return -1;
    }

    Exiv2::ExifData::const_iterator end = exifData.end();
    for (Exiv2::ExifData::const_iterator i = exifData.begin(); i != end; ++i) {
	if (i->key().compare("Exif.Image.Orientation") == 0 && i->tag() == 274) {
	    return (int)i->value().toLong();
	}
    }

    return -1;
#endif	// TARGET_OS_IPHONE
}

// scaleRect -- scale a rectangle to the original coordinates
cv::Rect KokkoImage::scaleRect(const cv::Rect& origRect) const
{
    if (scaleBy == 1.0)
	return origRect;
    cv::Rect sRect;
    sRect.x = round(origRect.x * scaleBy);
    sRect.y = round(origRect.y * scaleBy);
    sRect.height = round(origRect.height * scaleBy);
    sRect.width = round(origRect.width * scaleBy);
    return sRect;
}

// recolorImage -- using the color data from the chart, use a least-squares
// algorithm to readjust every pixel. Note that this only works on sRGB data.
static Mat recolorImage(const Mat &input, const ColorMeasure &measures)
{
    static const Vec3b fullBlack(0, 0, 0);
    static const Vec3b fullWhite(255, 255, 255);
    Mat output = Mat::zeros(input.rows, input.cols, CV_8UC3);
    
    for (int i=0; i<input.cols; i++) {
	for (int j=0; j<input.rows; j++) {
	    Vec3b pixel = input.at<Vec3b>(j, i);
	    // Pixel values at either extreme are mask values and should
	    // not be changed by the recoloring
	    if (pixel != fullBlack && pixel != fullWhite) {
		double blue = pixel(0);
		double green = pixel(1);
		double red = pixel(2);
		measures.transform_color(red, green, blue);
		if (red > 255) red = 255;
		if (green > 255) green = 255;
		if (blue > 255) blue = 255;
		if (red < 0) red = 0;
		if (green < 0) green = 0;
		if (blue < 0) blue = 0;
		output.at<Vec3b>(j, i) = Vec3b(blue, green, red);
	    }
	}
    }
    return output;
}




