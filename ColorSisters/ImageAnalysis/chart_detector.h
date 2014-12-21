/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#ifndef __CHART_DETECTOR_H__
#define __CHART_DETECTOR_H__

#include <iostream>
#include <fstream>
#include <vector>
#include <opencv2/highgui/highgui.hpp>
#include "chart.h"

typedef std::vector<cv::Point> polygon_t;
typedef polygon_t::size_type polygonSize_t;

struct model_group_t
{
  std::vector<polygonSize_t> indices;
  cv::Point2f center;
};


class ChartDetector
{
private:
    Chart chart;
    static const int max_image_dim = 1000;

public:
    ChartDetector() {}

    inline void init(const std::string& chart_layout_file) {
	chart.load(chart_layout_file);
    }
    
    // The primary interface to the Chart Detector. image contains the
    // image to be analyzed; debugFilesPrefix, if a non-empty string, must be a
    // full path + base file name; several output files with various
    // intermediate results will be created (each with a different extension).
    // The return value is the bounding box around the chart. An exception is
    // thrown if no chart is found.
    cv::Rect detect(const cv::Mat& image, const std::string& debugFilesPrefix = "");
    
    // Similar to above, but given a path to an image stored in the file
    // system instead.
    inline cv::Rect detect(const std::string &image_file_name,
			   const std::string& debugFilesPrefix = "") {
        return detect(cv::imread(image_file_name, CV_LOAD_IMAGE_COLOR), debugFilesPrefix);
    }

    void save_results(const std::string &dest_file) const;

    inline const Chart &get_chart() const {
	return chart;
    }

 private:
  void align_rectangle(polygon_t &rect) const;

  void align_rectangle(polygon_t &rect, const cv::Point &ref) const;
    
  void clockwise_rectangle(polygon_t &rect) const;

  void shrink(polygonf_t &rect, int shrink_ratio) const;

  void project_regions(const cv::Mat &h,
		       std::vector<polygon_t> &projected,
                       int shrink_ratio) const;

    polygonSize_t select_rectangles(std::vector<polygon_t> &rectangles,
				    const std::string& debugFilePrefix);

  polygonSize_t validate_group(const std::vector<polygon_t> &rectangles,
			       model_group_t &group,
			       const std::vector<float> &ratios,
			       std::ofstream *debug_out);

  cv::Mat compute_homography(const polygonf_t &source,
			     const std::vector<polygon_t> &rectangles,
                             const cv::Mat &image, bool &mirrored) const;
};

#endif
