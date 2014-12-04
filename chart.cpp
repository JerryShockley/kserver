/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#include "chart.h"
#include "common.h"
#include <stdlib.h>
#include <fstream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/ini_parser.hpp>

using namespace std;
using namespace cv;

void Chart::load(const string &chart_file_name)
{
  boost::property_tree::ptree pt;
  boost::property_tree::ini_parser::read_ini(chart_file_name, pt);
  name = pt.get<string>("Name.name");
  // read number of borders
  int nbr_edges = pt.get<int>("Frame.nbr_edges");
  // read every edge
  for (int i=0; i<nbr_edges; i++) {
    char name[64];
    sprintf(name, "Frame.edge%d", i+1);
    string line = pt.get<string>(name);
    frame.push_back(string_to_rectangle(line));
  }
  Point2f side1 = frame[0][1] - frame[0][0];
  Point2f side2 = frame[0][2] - frame[0][1];
  ratio = norm(side1) / norm(side2);

  // read number of color regions
  int nbr_color_regions = pt.get<int>("ColorRegions.number");

  // read every color region
  for (int i=0; i<nbr_color_regions; i++) {
    string section_name = "Region" + to_string(i+1);
    ColorRegion new_region;
    new_region.shape = string_to_rectangle(pt.get<string>(section_name + ".coordinates"));
    new_region.printed_color = string_to_color(pt.get<string>(section_name + ".printed_color"));
    string option = pt.get<string>(section_name + ".option", "");
    if (option.compare("not_used_in_transform") == 0) {
      new_region.type = UNUSED;
    }
    else if (option.compare("white") == 0) {
      new_region.type = WHITE;
    }
    else if (option.compare("black") == 0) {
      new_region.type = BLACK;
    }
    else {
      new_region.type = NORMAL;
    }
    regions.push_back(new_region);
  }
}

polygonf_t Chart::string_to_rectangle(const string &line) const
{
  vector<string> tokens;
  vector<float> coordinates;
  boost::split(tokens, line, boost::is_any_of(" "));
  if (tokens.size() != 4) {
    throw KokkoException("Invalid chart format (coordinates).");
  }
  for (int j=0; j<4; j++) {
    coordinates.push_back(atof(tokens[j].c_str()));
  }
  polygonf_t poly;
  poly.push_back(Point2f(coordinates[0], coordinates[1]));
  poly.push_back(Point2f(coordinates[2], coordinates[1]));
  poly.push_back(Point2f(coordinates[2], coordinates[3]));
  poly.push_back(Point2f(coordinates[0], coordinates[3]));
  return poly;
}

color_t Chart::string_to_color(const string &line) const
{
  vector<string> tokens;
  vector<int> channels;
  boost::split(tokens, line, boost::is_any_of(" "));
  if (tokens.size() != 3) {
    throw KokkoException("Invalid chart format (color).");
  }
  for (int j=0; j<3; j++) {
    channels.push_back(atoi(tokens[j].c_str()));
  }
  color_t color;
  color.red = channels[0];
  color.green = channels[1];
  color.blue = channels[2];
  return color;
}

void Chart::save_sampled_data(const std::string &file_name) const
{
  ofstream sfile(file_name);
  sfile << name << endl;
  sfile << regions.size() << endl;
  for (auto it = regions.begin(); it != regions.end(); ++it) {
    switch (it->type) {
    case NORMAL:
      sfile << "n ";
      break;
    case UNUSED:
      sfile << "u ";
      break;
    case BLACK:
      sfile << "b ";
      break;
    case WHITE:
      sfile << "w ";
      break;
    }
    sfile << (int)it->printed_color.red << " " << (int)it->printed_color.green << " " 
          << (int)it->printed_color.blue << " " << it->sampled_mean.red << " "
          << it->sampled_mean.green << " " << it->sampled_mean.blue << " "
          << it->sampled_stddev.red << " " << it->sampled_stddev.green << " "
          << it->sampled_stddev.blue << endl;
  }
  sfile.close();
}
