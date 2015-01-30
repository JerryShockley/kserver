//
//  face_extractor.h
//  image_pipeline
//
//  Created by Scott Trappe on 8/20/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//

#ifndef __image_pipeline__face_extractor__
#define __image_pipeline__face_extractor__

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include "kokko_image.h"

/*
 * This really should be a class definition, something along the lines of
 *
 *  class FilterImage {
 *	FilterImage();
 *	virtual cv::Mat filterImage(const cv::Mat& image);
 *  };
 *
 * Then each unique filter would just derive from this base class, implementing
 * the filterImage function. Use would be something like this:
 *
 *  SharedImageResources image_pipe;
 *  image_pipe.init(chart, faceModel);
 *  MyFilterImage fancyFilter(any initialization params including image_pipe);
 *  image_pipe.setFilter(fancyFilter);
 *
 * The derived class could have whatever private data it needs to perform the
 * filter operation.
 *
 * But my C++ programming skills are not great, and I'm sure I would run into
 * issues. So I'll do this the way you would do it in C, which is not nearly
 * as elegant or safe.
 */

extern cv::Mat filterChinCheek(const cv::Mat& image, FilterCtxPtr context);
extern cv::Mat filterSkinTones(const cv::Mat& image, FilterCtxPtr context);
extern FilterCtxPtr filterSkinTonesInit(SharedImageResources& rsrc);

#endif /* defined(__image_pipeline__face_extractor__) */
