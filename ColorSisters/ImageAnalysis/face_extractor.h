//
//  face_extractor.h
//  image_pipeline
//
//  Created by Scott Trappe on 8/20/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#ifndef __image_pipeline__face_extractor__
#define __image_pipeline__face_extractor__

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/objdetect/objdetect.hpp>

extern cv::Mat extractFace(const cv::Mat &image, cv::CascadeClassifier& faceModel);
extern cv::Mat extractSkinFromFace(const cv::Mat& image);

#endif /* defined(__image_pipeline__face_extractor__) */
