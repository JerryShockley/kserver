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
    Mat rotated;
    
    if (!picture.data)
	throw KokkoException("could not read image file '" + imageFileName + "'");

    // Check EXIF orientation
    int orientation = checkExifOrientation(imageFileName);
    // If EXIF tag exists and image is rotated, rectify it
    switch (orientation) {
	case 8: // rotate 90 degrees left
	    transpose(picture, rotated);
	    flip(rotated, picture, 0);
	    break;
		
	case 3: // rotate 180 degrees
	    flip(picture, rotated, -1);
	    picture = rotated;
	    break;
		
	case 6: // rotate 90 degrees right
	    transpose(picture, rotated);
	    flip(rotated, picture, 1);
	    break;
		
	case -1:
	    // no orientation information
	    break;
	    
	default:
	    // ignore other rotations
	    break;
    }

    extractSkinPixels(picture, pixels);
}


void SkinToneMatcher::extractSkinPixels(const Mat& original, SkinPixels& pixels)
{
    static int from4to3[] = { 0, 0, 1, 1, 2, 2 };
    static int from1to3[] = { 0, 0, 0, 1, 0, 2 };
    
    bool debug = (intermediateFilePath != "");
    Mat picture;			// contains a version of original with 3 channels
    
    switch (original.channels()) {
	case 4:
	{				// Scope necessary because var decl follows label
	    Mat rgba2rgb(original.size(), CV_8UC3);
	    mixChannels( &original, 1, &rgba2rgb, 1, from4to3, 3 );
	    picture = rgba2rgb;
	    break;
	}
	    
	case 1:
	{
	    Mat bw2rgb(original.size(), CV_8UC3);
	    mixChannels( &original, 1, &bw2rgb, 1, from1to3, 3 );
	    picture = bw2rgb;
	    break;
	}
	    
	case 3:
	    picture = original;
	    break;
	    
	default:
	    throw KokkoException("Unsupported number of channels: %d" + to_string(original.channels()));
    }
   
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
	    pixels.load(recoloredFace);
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

int SkinToneMatcher::checkExifOrientation(const std::string &image_name) const
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




