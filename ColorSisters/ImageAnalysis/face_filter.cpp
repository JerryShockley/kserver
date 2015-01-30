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

typedef struct {
    Vec3b   bgrMin;			// minimum B, G, R values in color chart
    Vec3b   bgrMax;			// maximum B, G, R values in color chart
} FilterSkinTonesContext;

// filterSkinTones -- mask off any pixels outside of the adjusted skin tones
//
// This filter creates an upside-down pentagon at a specific ratio relative
// to the face bounding box and uses that to eliminate all other pixels, with
// the goal of getting skin pixels only from the cheeks, mouth, and chin.
// Unfortunately, the bounding box size is too variable for this technique to
// work reliably.

Mat filterSkinTones(const Mat& face, FilterCtxPtr context)
{
    shared_ptr<FilterSkinTonesContext>ctx = static_pointer_cast<FilterSkinTonesContext>(context);
    
    // Create a mask for extracting pixels with skin tones
    Mat mask(face.size(), CV_8UC1);
    
    for (int i=0; i<face.rows; i++) {
	for (int j=0; j<face.cols; j++) {
	    Vec3b pixel = face.at<Vec3b>(i, j);
	    unsigned chansInRange = 0;
	    for (auto c = 0; c < 3; c++) {
		if (pixel[c] >= ctx->bgrMin[c] && pixel[c] <= ctx->bgrMax[c])
		    chansInRange++;
	    }
	    
	    // To control the range of acceptable pixels, change the test here:
	    // chansInRange > 0		-- if any channel is in range, OK
	    // chansInRange > 1		-- at least two channels must be in range
	    // chansInRange > 2		-- all three channels must be in range
	    // so "> 0" is loosest (encloses a bigger range), while "> 2" is
	    // the tightest.
	    mask.at<uchar>(i, j) = (chansInRange > 0);
	}
    }
    
    // Copy over the Matrix, masking off any out-of-range pixels.
    Mat facePixels = Mat::zeros(face.rows, face.cols, CV_8UC3);
    face.copyTo(facePixels, mask);
    return facePixels;
}

// filterSkinTonesInit -- Allocate and initialize any saved context
//
// filterSkinTones requires a table of min/max values for each channel; this
// is dependent on the specific chart being used but doesn't change for the
// life of execution. This function is called to allocate heap space for this
// data, read the chart information to build the min/max values, and return a
// pointer to the context which will be used by the filterSkinTones function.

FilterCtxPtr filterSkinTonesInit(SharedImageResources& rsrc)
{
    Vec3b vmin = Vec3b(255, 255, 255), vmax = Vec3b(0, 0, 0);
    const vector<ColorRegion>& rgs = rsrc.getChartRegions();
    
    // Find the minimum and maximum values for the colors across all regions
    // Keep in mind openCV channels are BGR, not RGB
    for (auto reg = rgs.begin(); reg != rgs.end(); ++reg)
	if (reg->type == NORMAL) {
	    if (reg->printed_color.blue  < vmin[0]) vmin[0] = reg->printed_color.blue;
	    if (reg->printed_color.blue  > vmax[0]) vmax[0] = reg->printed_color.blue;
	    if (reg->printed_color.green < vmin[1]) vmin[1] = reg->printed_color.green;
	    if (reg->printed_color.green > vmax[1]) vmax[1] = reg->printed_color.green;
	    if (reg->printed_color.red   < vmin[2]) vmin[2] = reg->printed_color.red;
	    if (reg->printed_color.red   > vmax[2]) vmax[2] = reg->printed_color.red;
	}
    shared_ptr<FilterSkinTonesContext> ctx = make_shared<FilterSkinTonesContext>();
    ctx->bgrMin = vmin;
    ctx->bgrMax = vmax;
    return ctx;
}


// filterChinCheek -- mask off all but the chin and cheeks from a face
//
// This filter creates an upside-down pentagon at a specific ratio relative
// to the face bounding box and uses that to eliminate all other pixels, with
// the goal of getting skin pixels only from the cheeks, mouth, and chin.
// Unfortunately, the bounding box size is too variable for this technique to
// work reliably.

Mat filterChinCheek(const Mat& face, void* context)
{
    // empirically found constant relating width of face relative to face
    // bounding box.
    const double faceWidth = 26.0 / 159.0;
    
    const cv::Size size = face.size();
    
    // Empirically found values, validated by Sabine
    const int mask_height = size.height / 2;
    const int mask_width = int(double(size.width) * faceWidth);
    const double widthMask2 = size.width * (1.0 - faceWidth);
    
    const double m = (size.height * 0.25) / (size.width * (0.5 - faceWidth));
    const double p = (size.height * 0.75) - m * size.width * faceWidth;
    
    const double mp = (size.height * 0.25) / (size.width * 0.5 - widthMask2);
    const double pp = (size.height * 0.75) - mp * widthMask2;
    
    // Create a mask for extracting the face pixels
    Mat mask = Mat::zeros(size, CV_8UC1);
    for (int y = mask_height; y < size.height; y++) {
	for (int x = mask_width; x < size.width - mask_width; x++) {
	    if ((m * x + p - y) > 0 && (mp * x + pp - y) > 0) {
		mask.at<uchar>(y, x) = 1;
	    }
	}
    }
    
    Mat facePixels = Mat::zeros(face.rows, face.cols, CV_8UC3);
    face.copyTo(facePixels, mask);
    return facePixels;
}


