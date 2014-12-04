/***********************************************************************/
/*                                                                     */
/* Written and (C) by Jerome Berclaz                                   */
/* email : berclaz@live.com                                            */
/*                                                                     */
/***********************************************************************/

#ifndef CHART_H
#define CHART_H

#include <vector>
#include "common.h"
#include <opencv2/core/core.hpp>

typedef std::vector<cv::Point2f> polygonf_t;
typedef polygonf_t::size_type polygonfSize_t;

enum region_type_t { NORMAL, BLACK, WHITE, UNUSED };


struct color_t
{
    unsigned char red;
    unsigned char green;
    unsigned char blue;
};


struct colorf_t
{
    float red;
    float green;
    float blue;
};


class ColorRegion
{
 public:
  polygonf_t shape;
  color_t printed_color;
  colorf_t sampled_mean;
  colorf_t sampled_stddev;
  region_type_t type;
};

typedef std::vector<ColorRegion>::size_type colorRegionSize_t;

// Class representing a color chart
class Chart
{
 private:
  // outer lines around the color squares
  std::vector<polygonf_t> frame;
  // color regions
  std::vector<ColorRegion> regions;
  // chart width/height ratio
  double ratio;
  // chart name
  std::string name;

 public:
  void load(const std::string& chart_file_name);
    
  inline bool is_square() const { return fabs(ratio - 1) < 0.05;  }

  inline const std::vector<polygonf_t> &get_frame() const { return frame; }

  inline const std::vector<ColorRegion> &get_regions() const { return regions; }

  inline const ColorRegion &get_region(int i) const {
    return regions.at(i);
  }

  inline void set_sampled_color(int i, const cv::Scalar &mean, const cv::Scalar &stddev) {
    regions.at(i).sampled_mean.red = mean[2];
    regions.at(i).sampled_mean.green = mean[1];
    regions.at(i).sampled_mean.blue = mean[0];
    regions.at(i).sampled_stddev.red = stddev[2];
    regions.at(i).sampled_stddev.green = stddev[1];
    regions.at(i).sampled_stddev.blue = stddev[0];
  }

    inline colorRegionSize_t get_nbr_regions() const { return regions.size(); }
    
    inline double get_ratio() const { return ratio; }

  void save_sampled_data(const std::string &file_name) const;

 private:

  polygonf_t string_to_rectangle(const std::string &line) const;

  color_t string_to_color(const std::string &line) const;

  friend class ColorMeasure;
};

#endif
