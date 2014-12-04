//
//  face_extractor.cpp
//  image_pipeline
//
//  Created by Scott Trappe on 8/20/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
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
#include "face_extractor.h"


using namespace std;
using namespace cv;

static Mat createMask(const cv::Size& size);

Mat extractFace(const Mat &image, CascadeClassifier& faceModel)
{
    // Apply openCV face detector
    vector<cv::Rect> face_coor;
    
    faceModel.detectMultiScale(image, face_coor, 1.1, 5, 0 |CV_HAAR_FIND_BIGGEST_OBJECT, cv::Size(0, 0));
    
    if (face_coor.empty())
	throw KokkoException("could not find a face in the image file\n");

    return image(face_coor[0]).clone();
}


Mat extractSkinFromFace(const Mat& face)
{

    Mat mask = createMask(face.size());
    Mat facePixels = Mat::zeros(face.rows, face.cols, CV_8UC3);
    
    face.copyTo(facePixels, mask);
    return facePixels;
}


// Create a mask for extracting a subset of the "face" returned by the
// face detector. The problem is that the OpenCV detector returns a very large
// rectangle including a lot of image beyond the boundaries of the face.

static Mat createMask(const cv::Size& size)
{
    // Create a mask for extracting the face pixels
    Mat mask = Mat::zeros(size, CV_8UC1);
    
    // Empirically found values, validated by Sabine
    int mask_height = size.height / 2;
    int mask_width = size.width * 26 / 159;
    double widthMask2 = size.width * (1.0 - 26.0 / 159.0);
    
    double m = (size.height * 0.25) / (size.width * (0.5 - 26.0 / 159.0));
    double p = size.height * 0.75 - m * size.width * 26.0 / 159.0;
    
    double mp = (size.height * 0.25) / (size.width * 0.5 - widthMask2);
    double pp = size.height * 0.75 - mp * widthMask2;
    
    for (int y=mask_height; y<size.height; y++) {
	for (int x=mask_width; x<size.width-mask_width; x++) {
	    if ((m * x + p - y) > 0 && (mp * x + pp - y) > 0) {
		mask.at<uchar>(y, x) = 1;
	    }
	}
    }
    return mask;
}


