//
//  pipeline.h
//  image_pipeline
//
//  Created by Scott Trappe on 8/21/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#ifndef __image_pipeline__pipeline__
#define __image_pipeline__pipeline__

#include <string>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "chart_detector.h"
#include "skinpixels.h"
#include "exemplar.h"

class SkinToneMatcher {
public:
    SkinToneMatcher(bool useMask = false) : useFaceMask(useMask), intermediateFilePath("") {}
    SkinToneMatcher(const std::string& chartDefFile,
		    const std::string& faceModel,
		    bool useMask = false) : useFaceMask(useMask), intermediateFilePath("") {
	init(chartDefFile, faceModel);
    }
    
    void init(const std::string& chartDefFile,
	      const std::string& faceModel);
    void loadExemplarDB(const std::string& skinPixelFile, const std::string shadeDBFile = "") {
	refImages.load(skinPixelFile, shadeDBFile);
    }
    void setIntermediateFilePath(const std::string& inbetweenFilePath);

    void extractSkinPixels(const std::string& image_fileName, SkinPixels& pixels);
    void extractSkinPixels(const cv::Mat& picture, SkinPixels& pixels);
    
    FaceRank matchFaces(const std::string& imageFileName);
    FaceRank matchFaces(const cv::Mat& picture);
    FaceRank matchFaces(const SkinPixels& pixels) {
	return refImages.match(pixels);
    }
    
    Recommendations recommend(const std::string& imageFileName, const BrandSet& theseBrands);
    Recommendations recommend(const std::string& imageFileName) {
	return recommend(imageFileName, BrandSet());
    }
    
    Recommendations recommend(const cv::Mat& picture, const BrandSet& theseBrands) {
	SkinPixels skin;
	extractSkinPixels(picture, skin);
	return recommend(skin, theseBrands);
    }
    Recommendations recommend(const cv::Mat& picture) {
	return recommend(picture, BrandSet());
    }
    Recommendations recommend(const FaceRank& matches, const BrandSet& theseBrands) {
	return refImages.recommend(matches, theseBrands);
    }
    Recommendations recommend(const FaceRank& matches) {
	return refImages.recommend(matches, BrandSet());
    }
    Recommendations recommend(const SkinPixels& pixels, const BrandSet& theseBrands) {
	return refImages.recommend(pixels, theseBrands);
    }
    Recommendations recommend(const SkinPixels& pixels) {
	return refImages.recommend(pixels, BrandSet());
    }
    
    
    bool getMaskMode() const		{ return useFaceMask; }
    void setMaskMode(bool useMask)	{ useFaceMask = useMask; }
    void setMaxFaces(unsigned n)	{ refImages.setMaxFaces(n); }
    void setMaxRecShades(unsigned n)	{ refImages.setMaxRecShades(n); }
    void setCompareInterval(int n)	{ refImages.setCompareInterval(n); }
    
private:
    ChartDetector detector;
    cv::CascadeClassifier face_cascade;
    ExemplarDB refImages;		    // DB of reference images and shade assignments
    bool useFaceMask;			    // use a smaller set of pixels just capturing skin
    std::string intermediateFilePath;	    // where to write interemediate files

    int checkExifOrientation(const std::string &image_name) const;
};

#endif /* defined(__image_pipeline__pipeline__) */
