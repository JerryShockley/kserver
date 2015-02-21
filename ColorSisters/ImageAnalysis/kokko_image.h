//
//  kokko_image.h
//  image_pipeline
//
//  Created by Scott Trappe on 8/21/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//

#ifndef __kokko_image__
#define __kokko_image__

#include <string>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "chart_detector.h"
#include "skinpixels.h"
#include "exemplar.h"

typedef	std::shared_ptr<void>   FilterCtxPtr;
typedef	cv::Mat (*FilterFunc)(const cv::Mat& face, FilterCtxPtr context,
			      const std::string& imageName);

class SharedImageResources {
public:
    SharedImageResources() : debugFPath(""), faceFilterFunc(NULL) {}
    SharedImageResources(const std::string& chartDefFile,
			 const std::string& faceModel)
		{
		    init(chartDefFile, faceModel);
		}
    void	init(const std::string& chartDefFile,
		     const std::string& faceModel);
    void	loadExemplarDB(const std::string& skinPixelFile,
			       const std::string shadeDBFile = "")
		{
		    refImages.load(skinPixelFile, shadeDBFile);
		}
    
    // Getter functions to access some context
    const std::vector<ColorRegion>& getChartRegions() const
		{
		    return detector.get_chart().get_regions();
		}
    const std::string&	getIntermediateFilePath() { return debugFPath; }
    
    // Setter functions to change attributes
    void	setIntermediateFilePath(const std::string& debugFilePath);
    void	setMaxFaces(unsigned n)	    { refImages.setMaxFaces(n); }
    void	setMaxRecShades(unsigned n) { refImages.setMaxRecShades(n); }
    void	setFaceFilter(FilterFunc func, FilterCtxPtr context)
		{
		    faceFilterFunc = func;
		    faceFilterContext = context;
		}
    void	setColorFilter(FilterFunc func, FilterCtxPtr context)
		{
		    colorFilterFunc = func;
		    colorFilterContext = context;
		}
    
private:
    ChartDetector   detector;
    cv::CascadeClassifier faceModel;
    ExemplarDB	    refImages;		// DB of reference images and shade assignments
    std::string	    debugFPath;		// where to write interemediate files
    FilterFunc	    faceFilterFunc;	// "extra" filtering of face
    FilterCtxPtr    faceFilterContext;	// any global data it requires
    FilterFunc	    colorFilterFunc;	// "extra" filtering of face by color
    FilterCtxPtr    colorFilterContext;	// any global data it requires
    
    friend class    KokkoImage;
};


class KokkoImage {
public:
    KokkoImage(SharedImageResources *resources,
	       const cv::Mat& image, const std::string& imageName = "")
    {
	initWithImage(resources, image, imageName);
    }
    KokkoImage(SharedImageResources *resources,
	       const std::string& imageFile);
    
    // Functions to get various bits of info from the image
    cv::Rect	getChartRect();
    cv::Rect	getFaceRect();
    cv::Mat	getFaceImage();		    // return the current image of face
    SkinPixels	getExtractedSkin();
    const FaceRank&	getFaceRank();
    const Recommendations& getRecommendations();
    
    // Override default settings for various parameters
    void	setBrands(const BrandSet& br)	    { brands = br; }

private:
    SharedImageResources *shared;	    // where all the common data is kept
    std::string	imageName;		    // name of image, if any
    std::string	debugImagePath;		    // path and base name for debug files
    cv::Mat	sizedImage;		    // image resized to keep smaller
    cv::Mat	filteredFace;		    // image cropped to face area
    cv::Rect	chartRect;		    // coordinates of chart in sizedImage
    cv::Rect	faceRect;		    // coordinates of face in sizedImage
    SkinPixels	extractedSkin;		    // isolated, recolored skin pixels
    FaceRank	matches;		    // list of exemplars matched
    Recommendations brandsShades;	    // list of brands and matching shades
    
    bool	lookedForChart;		    // have tried to find chart
    bool	lookedForFace;		    // have tried to find face
    bool	foundChart;		    // set if chart has been located
    bool	foundFace;		    // set if face has been located
    bool	skinIsolated;		    // set if recolored skin extracted
    bool	facesRanked;		    // set if face compared to exemplars
    bool	madeRecoms;		    // set if recommendations made
    double	scaleBy;		    // scaleBy = original / sizedImage
    BrandSet	brands;			    // make recommendations just for these brands
    
    // Internal functions
    void	initWithImage(SharedImageResources *rsrc,
			      const cv::Mat& image,
			      const std::string& imageName = "");
    void	findChart();		    // locate the chart in the image
    void	getChartColors();
    void 	findFace();		    // locate the face in the image
    void	rankFaces();		    // rank exemplars matching face
    void	extractSkinPixels();	    // recolor and extract skin pixels
    void	makeRecommendations();	    // produce recommendations for face
    cv::Rect	scaleRect(const cv::Rect& origRect) const;
    cv::Rect	resizeRect(const cv::Rect& origRect,
			   double scaleWidthBy,
			   double scaleHeightBy) const;
};

#endif /* defined(__kokko_image__) */
