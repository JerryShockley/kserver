//
//  pipeline.cpp
//  image_pipeline
//
//  Created by Scott Trappe on 8/21/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#include "common.h"
#include "color_measure.h"
#include "face_extractor.h"
#include "pipeline.h"

using namespace std;
using namespace cv;

static Mat recolorImage(const Mat &input, const ColorMeasure &measures);

void SkinToneMatcher::init(const std::string& chartDefFile,
			   const std::string& faceModel)
{
    
    // Load the cascade for face detection
    face_cascade.load(faceModel);
    if (face_cascade.empty())
	throw KokkoException("could not load face cascade file '" + faceModel + "'");
    
    // Load chart
    detector.init(chartDefFile);
}


void SkinToneMatcher::setIntermediateFilePath(const string& inbetweenFilePath)
{
    // if the intermediateFilePath value is != "", then the class user
    // wants intermediate results saved during the pipeline execution.
    // The value of the string is a path plus a base file name; only
    // an extension should be appended to distinguish one file from another.
    
    intermediateFilePath = inbetweenFilePath;
}


void SkinToneMatcher::extractSkinPixels(const string& imageFileName, SkinPixels& pixels)
{
    Mat picture = imread(imageFileName);
    if (!picture.data)
	throw KokkoException(")could not read image file '" + imageFileName + "'");
    extractSkinPixels(picture, pixels);
}


void SkinToneMatcher::extractSkinPixels(const Mat& picture, SkinPixels& pixels)
{
    bool debug = (intermediateFilePath != "");
    
    try {
	// Find the chart
	detector.detect(picture, intermediateFilePath);
    
	// create color transform
	ColorMeasure measure(detector.get_chart());
	
	if (debug) {
	    // Save color corrected image
	    Mat color_corrected = recolorImage(picture, measure);
	    imwrite(intermediateFilePath + ".xfix.png", color_corrected);
	    // Save sampled color values
	    detector.get_chart().save_sampled_data(intermediateFilePath + ".cclr.txt");
	}
	
	// Apply openCV face detector
	Mat face = extractFace(picture, face_cascade);
	
	if (debug)
	    // Save the detected face area
	    imwrite(intermediateFilePath + ".fbox.png", face);

	if (useFaceMask) {
	    // Extract a subset of the face which should only contain skin pixels.
	    
	    Mat facePixels = extractSkinFromFace(face);
	    Mat recoloredFace = recolorImage(facePixels, measure);
	    pixels.load(facePixels);
	    if (debug)
		imwrite(intermediateFilePath + ".fskn.png", recoloredFace);
	} else {
	    Mat recoloredFace = recolorImage(face, measure);
	    pixels.load(recoloredFace);
	}
    }
    catch (cv::Exception e) {
	throw KokkoException("OpenCV error: " + e.msg );
    }
}

FaceRank SkinToneMatcher::matchFaces(const string& imageFileName)
{
    SkinPixels skin;
    
    extractSkinPixels(imageFileName, skin);
    return refImages.match(skin);
}


FaceRank SkinToneMatcher::matchFaces(const Mat& picture)
{
    SkinPixels skin;
    
    extractSkinPixels(picture, skin);
    return refImages.match(skin);
}

Recommendations SkinToneMatcher::recommend(const std::string& imageFileName, const BrandSet& theseBrands)
{
    FaceRank matches;
    
    matches = matchFaces(imageFileName);
    return refImages.recommend(matches, theseBrands);
}


static Mat recolorImage(const Mat &input, const ColorMeasure &measures)
{
    Mat output(input.rows, input.cols, CV_8UC3);
    
    for (int i=0; i<input.cols; i++) {
	for (int j=0; j<input.rows; j++) {
	    Vec3b pixels = input.at<Vec3b>(j, i);
	    double blue = pixels(0);
	    double green = pixels(1);
	    double red = pixels(2);
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
    return output;
}




