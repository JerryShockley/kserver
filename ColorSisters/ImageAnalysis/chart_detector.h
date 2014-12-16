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
  std::vector<int> indices;
  cv::Point2f center;
};


class ChartDetector
{
private:
    Chart chart;
    bool debug;
    std::ofstream chart_details;
    static const int max_image_width = 1000;

public:
    ChartDetector() : debug(false) {}

    inline void init(const std::string& chart_layout_file) {
	chart.load(chart_layout_file);
    }
    
    std::vector<cv::Point> detect(const cv::Mat& image, const std::string& out_path = "");
    
    inline std::vector<cv::Point> detect(const std::string &image_file_name, const std::string& out_path = "") {
	// image_file_name is the complete path and file name, including any extension.
	// out_path is a full path and base file name; distinct output files can be
	// created by appending a suffix and/or extension.
      return detect(cv::imread(image_file_name, CV_LOAD_IMAGE_COLOR), out_path);
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

  polygonSize_t select_rectangles(std::vector<polygon_t> &rectangles);

  int validate_group(const std::vector<polygon_t> &rectangles, 
                     model_group_t &group, 
                     const std::vector<float> &ratios);

  cv::Mat compute_homography(const polygonf_t &source,
			     const std::vector<polygon_t> &rectangles,
                             const cv::Mat &image, bool &mirrored) const;
};

#endif
