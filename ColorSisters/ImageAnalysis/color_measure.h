/***********************************************************************/
/*                                                                     */
/* Written and (C) by Jerome Berclaz                                   */
/* email : berclaz@live.com                                            */
/*                                                                     */
/***********************************************************************/
#ifndef COLOR_MEASURE_H
#define COLOR_MEASURE_H

#include <string>
#include "Eigen/Core"
#include "common.h"
#include "chart.h"

struct color_measure_t {
  color_t printed;
  colorf_t sampled_mean;
  colorf_t sampled_stddev;
};

class ColorMeasure
{
 private:
  Eigen::MatrixXf ref;
  Eigen::MatrixXf samples;
  Eigen::MatrixXf trans;
  std::string chart_name;

 public:
  ColorMeasure(const std::string &file_name);

  ColorMeasure(const Chart &chart);

  void transform_color(double &red, double &green, double &blue) const;

  inline double get_transform(int i, int j) const {
    return trans(i, j);
  }

  inline void get_sample(int i, double &red, double &green, double &blue) const {
    red = samples(i, 0);
    green = samples(i, 1);
    blue = samples(i, 2);
  }

  inline void get_ref(int i, double &red, double &green, double &blue) const {
    red = ref(i, 0);
    green = ref(i, 1);
    blue = ref(i, 2);
  }

 private:
  void load(const std::string &file_name);

  void compute_transform();

  color_measure_t read_measure(const std::vector<std::string> &tokens) const;
};

#endif
