/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#include "color_measure.h"
#include <fstream>
#include "boost/algorithm/string.hpp"
#include "Eigen/SVD"

using namespace std;

typedef vector<color_measure_t>::size_type color_measure_size_t;


ColorMeasure::ColorMeasure(const std::string &file_name)
{
  load(file_name);
  compute_transform();
}

ColorMeasure::ColorMeasure(const Chart &chart)
{
  chart_name = chart.name;

  int nbr_black = 0, nbr_white = 0, nbr_color = 0;
  color_t printed_black = { 0, 0, 0}, printed_white = { 0, 0, 0};
  colorf_t sampled_white = { 0, 0, 0}, sampled_black = {0, 0, 0};
  const vector<ColorRegion> &regions = chart.regions;
  for (auto reg = regions.begin(); reg != regions.end(); ++reg) {
    switch (reg->type) {
    case NORMAL:
      nbr_color++;
      break;
    case BLACK:
      if (nbr_black == 0) {
        printed_black = reg->printed_color;
      }
      sampled_black.red += reg->sampled_mean.red;
      sampled_black.green += reg->sampled_mean.green;
      sampled_black.blue += reg->sampled_mean.blue;
      nbr_black++;
      break;
    case WHITE:
      if (nbr_white == 0) {
        printed_white = reg->printed_color;
      }
      sampled_white.red += reg->sampled_mean.red;
      sampled_white.green += reg->sampled_mean.green;
      sampled_white.blue += reg->sampled_mean.blue;
      nbr_white++;
      break;
    case UNUSED:
      break;
    }
  }

  int nbr_samples = nbr_color + (nbr_black > 0) + (nbr_white > 0);
  ref.resize(nbr_samples, 3);
  samples.resize(nbr_samples, 4);
  trans.resize(4, 3);
  int color_index = 0;
  for (auto reg = regions.begin(); reg != regions.end(); ++reg) {
    if (reg->type == NORMAL) {
      samples(color_index, 0) = reg->sampled_mean.red;
      samples(color_index, 1) = reg->sampled_mean.green;
      samples(color_index, 2) = reg->sampled_mean.blue;
      samples(color_index, 3) = 1;
      ref(color_index, 0) = reg->printed_color.red;
      ref(color_index, 1) = reg->printed_color.green;
      ref(color_index, 2) = reg->printed_color.blue;
      color_index++;
    }
  }
  if (nbr_white > 0) {
    int white_index = nbr_samples - 2;
    samples(white_index, 0) = sampled_white.red / nbr_white;
    samples(white_index, 1) = sampled_white.green / nbr_white;
    samples(white_index, 2) = sampled_white.blue / nbr_white;
    samples(white_index, 3) = 1;
    ref(white_index, 0) = printed_white.red;
    ref(white_index, 1) = printed_white.green;
    ref(white_index, 2) = printed_white.blue;
  }
  if (nbr_black > 0) {
    int black_index = nbr_samples - 1;
    samples(black_index, 0) = sampled_black.red / nbr_black;
    samples(black_index, 1) = sampled_black.green / nbr_black;
    samples(black_index, 2) = sampled_black.blue / nbr_black;
    samples(black_index, 3) = 1;
    ref(black_index, 0) = printed_black.red;
    ref(black_index, 1) = printed_black.green;
    ref(black_index, 2) = printed_black.blue;
  }

  compute_transform();
}

void ColorMeasure::compute_transform()
{
  trans = samples.jacobiSvd(Eigen::ComputeThinU | Eigen::ComputeThinV).solve(ref);
}

void ColorMeasure::transform_color(double &red, double &green, double &blue) const
{
  Eigen::Vector4f color(red, green, blue, 1.0);
  Eigen::VectorXf t = color.transpose() * trans;
  red = t(0);
  green = t(1);
  blue = t(2);
}

void ColorMeasure::load(const std::string &file_name)
{
  ifstream chart_file(file_name.c_str());
  if (!chart_file.good()) {
    throw KokkoException("Unable to open color file '" + file_name + "'.");
  }
  string line;
  getline(chart_file, chart_name);
  getline(chart_file, line);
    color_measure_size_t nbr_samples = atoi(line.c_str());
  vector<color_measure_t> color_measures;
  color_measure_t white_measure, black_measure;
  white_measure.sampled_mean.red = 0;
  white_measure.sampled_mean.green = 0;
  white_measure.sampled_mean.blue = 0;
  black_measure.sampled_mean.red = 0;
  black_measure.sampled_mean.green = 0;
  black_measure.sampled_mean.blue = 0;
  int nbr_white = 0, nbr_black = 0;
  for (color_measure_size_t i=0; i<nbr_samples; i++) {
    getline(chart_file, line);
    vector<string> tokens;
    boost::split(tokens, line, boost::is_any_of(" "));
    if (tokens.size() != 10) {
      throw KokkoException("Invalid color file format (0)");
    }
    switch (tokens[0][0]) {
    case 'u':
      continue;
      break;
    case 'n': 
      {
        color_measure_t new_measure = read_measure(tokens);
        color_measures.push_back(new_measure);
      }
      break;
    case 'w':
      {
        color_measure_t nm = read_measure(tokens);
        if (nbr_white == 0) {
          white_measure = nm;
        }
        else {
          color_measure_t &wm = white_measure;
          if (wm.printed.red != nm.printed.red || wm.printed.green != nm.printed.green 
              || wm.printed.blue != nm.printed.blue) {
            throw KokkoException("Invalid color file format (2)");
          }
          wm.sampled_mean.red += nm.sampled_mean.red;
          wm.sampled_mean.green += nm.sampled_mean.green;
          wm.sampled_mean.blue += nm.sampled_mean.blue;          
        }
        nbr_white++;
      }
      break;
    case 'b':
      {
        color_measure_t nm = read_measure(tokens);
        if (nbr_black == 0) {
          black_measure = nm;
        }
        else {
          color_measure_t &bm = black_measure;
          if (bm.printed.red != nm.printed.red || bm.printed.green != nm.printed.green 
              || bm.printed.blue != nm.printed.blue) {
            throw KokkoException("Invalid color file format (3)");
          }
          bm.sampled_mean.red += nm.sampled_mean.red;
          bm.sampled_mean.green += nm.sampled_mean.green;
          bm.sampled_mean.blue += nm.sampled_mean.blue;          
        }
        nbr_black++;
      }
      break;
    default:
      throw KokkoException("Invalid color file format (1)");
    }
  }
  if (nbr_white > 1) {
    white_measure.sampled_mean.red /= nbr_white;
    white_measure.sampled_mean.green /= nbr_white;
    white_measure.sampled_mean.blue /= nbr_white;
  }
  if (nbr_black > 1) {
    black_measure.sampled_mean.red /= nbr_black;
    black_measure.sampled_mean.green /= nbr_black;
    black_measure.sampled_mean.blue /= nbr_black;
  }

  nbr_samples = color_measures.size() + (nbr_black > 0) + (nbr_white > 0);
  ref.resize(nbr_samples, 3);
  samples.resize(nbr_samples, 4);
  trans.resize(4, 3);
  for (unsigned int i=0; i<color_measures.size(); i++) {
    samples(i, 0) = color_measures[i].sampled_mean.red;
    samples(i, 1) = color_measures[i].sampled_mean.green;
    samples(i, 2) = color_measures[i].sampled_mean.blue;
    samples(i, 3) = 1;
    ref(i, 0) = color_measures[i].printed.red;
    ref(i, 1) = color_measures[i].printed.green;
    ref(i, 2) = color_measures[i].printed.blue;
  }
    color_measure_size_t index = color_measures.size();
  if (nbr_white > 0) {
    samples(index, 0) = white_measure.sampled_mean.red;
    samples(index, 1) = white_measure.sampled_mean.green;
    samples(index, 2) = white_measure.sampled_mean.blue;
    samples(index, 3) = 1;
    ref(index, 0) = white_measure.printed.red;
    ref(index, 1) = white_measure.printed.green;
    ref(index, 2) = white_measure.printed.blue;
    index++;
  }
  if (nbr_black > 0) {
    samples(index, 0) = black_measure.sampled_mean.red;
    samples(index, 1) = black_measure.sampled_mean.green;
    samples(index, 2) = black_measure.sampled_mean.blue;
    samples(index, 3) = 1;
    ref(index, 0) = black_measure.printed.red;
    ref(index, 1) = black_measure.printed.green;
    ref(index, 2) = black_measure.printed.blue;
  }
  chart_file.close();
}

color_measure_t ColorMeasure::read_measure(const vector<string> &tokens) const {
  color_measure_t m;
  m.printed.red = atoi(tokens[1].c_str());
  m.printed.green = atoi(tokens[2].c_str());
  m.printed.blue = atoi(tokens[3].c_str());
  m.sampled_mean.red = atof(tokens[4].c_str());
  m.sampled_mean.green = atof(tokens[5].c_str());
  m.sampled_mean.blue = atof(tokens[6].c_str());
  m.sampled_stddev.red = atof(tokens[7].c_str());
  m.sampled_stddev.green = atof(tokens[8].c_str());
  m.sampled_stddev.blue = atof(tokens[9].c_str());
  return m;
}
