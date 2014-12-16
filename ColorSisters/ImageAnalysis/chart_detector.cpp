/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#ifndef CHART_DETECTOR_CPP
#define CHART_DETECTOR_CPP

#include <stdio.h>
#include <set>
#include <cassert>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include "chart_detector.h"

// Once the chart has been located, the chart definition is used to determine
// where the corners of each color square should be. But we don't want to
// sample right to the edges because we may pick up some of the border color.
// So we reduce the size of the square to insure that we only sample colors
// well inside it. This constant controls how much smaller the sampled square
// will be from the defined size, as a percentage. So 0 = 0% smaller (same
// size as defined square) and 20 = 20% smaller. Since it is a percentage, the
// legal values are 0% - 100%.
#define	REDUCED_SQUARE_SIZE_COLOR	25

// As part of the chart detection process we compute the intensity of each
// color square. Like what's described above, we want to sample near the center
// of the square. This is less sensitive to the number of pixels sampled, so
// the square can be smaller. Thus this constant is defined as positive offset
// to the value defined above.
#define	REDUCED_SQUARE_SIZE_INTENSITY	(REDUCED_SQUARE_SIZE_COLOR + 5)


using namespace std;
using namespace cv;

struct intel {
  float intensity;
  int x;
  int y;
};

bool compare_intel (const intel &i, const intel &j) { 
  return (i.intensity<j.intensity); 
}

int compare_order(const vector<intel> &a, const vector <intel> &b)
{
  assert(a.size() == b.size());
  int difference = 0;
  vector<intel>::size_type n = a.size();
  for (int i=0; i<(int)n; i++) {
    if (a[i].x != b[i].x || a[i].y != b[i].y) {
      int diff = -1;
      for (int j=0; j<(int)n; j++) {
        if (a[i].x == b[j].x && a[i].y == b[j].y) {
          diff = abs(i-j);
          break;
        }
      }
      assert(diff != -1);
      difference += diff;
    }
  }
  return difference;
}

void print_int_list(ofstream& outFile, const vector<intel> &a)
{
  vector<intel>::size_type n = a.size();
  for (int i=0; i<(int)n; i++) {
    outFile << a[i].intensity << "  " << a[i].x << " - " << a[i].y << endl;
  }
}

Point2f get_center(const polygonf_t &poly)
{
  polygonfSize_t n = poly.size();
  Point2f center = poly[0];
  for (int j=1; j<(int)n; j++) {
    center += poly[j];
  }
  center.x /= n;
  center.y /= n;
  return center;
}

Point2f get_center(const polygon_t &poly)
{
  polygonSize_t n = poly.size();
  Point2f center = poly[0];
  for (int j=1; j<(int)n; j++) {
    center.x += poly[j].x;
    center.y += poly[j].y;
  }
  center.x /= n;
  center.y /= n;
  return center;
}

float get_rect_area(const polygon_t &poly)
{
  if (poly.size() != 4) {
    throw KokkoException("Polygon is not a rectangle.");
  }
  cv::Point side1 = poly[1] - poly[0];
  cv::Point side2 = poly[2] - poly[1];
  cv::Point side3 = poly[3] - poly[2];
  cv::Point side4 = poly[0] - poly[3];
  return (norm(side1) + norm(side3)) * (norm(side2) + norm(side4)) / 4.0;
}

float get_rect_area(const polygonf_t &poly)
{
  if (poly.size() != 4) {
    throw KokkoException("Polygon is not a rectangle.");
  }
  cv::Point side1 = poly[1] - poly[0];
  cv::Point side2 = poly[2] - poly[1];
  return norm(side1) * norm(side2);
}

vector<Point> ChartDetector::detect(const Mat& original, const string& out_path)
{
    assert(original.channels() == 3);
    Mat image = original;
    Mat debug_image;
    
    // create debug image, if necessary
    if (out_path != "") {
	debug = true;
	chart_details.open(out_path + ".cdbg.txt");
	chart_details << "Ratio: " << chart.get_ratio() << endl;
	debug_image = image.clone();
    }
    
    // resize image if needed
    if (max(image.cols, image.rows) > max_image_width) {
	int max_dim = max(image.cols, image.rows);
	float factor = (float)max_image_width / max_dim;
	Mat small;
	resize(image, small, cv::Size(0,0), factor, factor, INTER_LANCZOS4);
	image = small;
    }
    
    // convert to grayscale
    Mat gray;
    cvtColor(image, gray, COLOR_BGR2GRAY);
    
    // threhsold intensity
    Mat thresh;
    threshold(gray, thresh, 127, 255, THRESH_BINARY);
    
    // find contours
    vector<polygon_t> contours;
    vector<Vec4i> hier;
    findContours(thresh, contours, hier, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    
    // select large rectangles
    vector<polygon_t> rectangles;
    vector<int> indices;
    int i = 0;
    for (vector<polygon_t>::iterator cnt = contours.begin();
	 cnt < contours.end(); ++cnt) {
	// keep only large enough contours
	if (contourArea(*cnt) > 5000) { // TODO: make it proportional to the image size
	    // compute approximate polygon
	    polygon_t hull;
	    approxPolyDP(*cnt, hull, 0.007 * arcLength(*cnt, true), true);
	    // keep only rectangles
	    if (hull.size() == 4) {
		rectangles.push_back(hull);
		indices.push_back(i);
	    }
	}
	i++;
    }
    
    // select chart rectangles
    long outer = select_rectangles(rectangles);
    if (outer < (int)(chart.get_frame().size() - 1)) {
	if (debug) {
	    drawContours(image, rectangles, -1, Scalar(0, 0, 255), 2);
	    string outimage(out_path + ".cdbg.png");
	    imwrite(outimage.c_str(), image);
	}
	char message[512];
	if (outer < 0) {
	    sprintf(message, "Unable to locate chart.");
	}
	else {
	    sprintf(message, "Only %ld chart borders found.", outer);
	}
	throw KokkoException(message);
    }
    
    // make sure first rectangle is clockwise and first corner is top left
    if (chart.is_square()) {
	clockwise_rectangle(rectangles[0]);
    }
    else {
	align_rectangle(rectangles[0]);
    }
    for (unsigned int i=1; i<rectangles.size(); i++) {
	clockwise_rectangle(rectangles[i]);
    }
    
    // make sure all rectangles are aligned the same way
    for (unsigned int i=1; i<rectangles.size(); i++) {
      align_rectangle(rectangles[i], rectangles[0][0]);
    }
    
    // find chart homography
    polygonf_t source;
    for (unsigned int j=0; j<rectangles.size(); j++) {
	for (unsigned int i=0; i<chart.get_frame()[j].size(); i++) {
	    source.push_back(chart.get_frame()[j][i]);
	}
    }
    bool mirrored;
    Mat h = compute_homography(source, rectangles, image, mirrored);
    
    float x_scale = original.cols / (float)image.cols;
    float y_scale = original.rows / (float)image.rows;
    // rescale homography for the original image (if needed)
    if (original.cols > image.cols) {
	Mat mult = Mat::zeros(3, 3, CV_64F);
	mult.at<double>(0, 0) = x_scale;
	mult.at<double>(1, 1) = y_scale;
	mult.at<double>(2, 2) = 1;
	h = mult * h;
    }

    // compute bounding box
    vector<Point> bounding_box;
    double min_x = original.cols, max_x = 0, min_y = original.rows, max_y = 0;
    unsigned long rect = rectangles.size() - 1;
    for (unsigned int j=0; j<rectangles[rect].size(); j++) {
      if (rectangles[rect][j].x * x_scale < min_x) {
        min_x = rectangles[rect][j].x * x_scale;
      }
      if (rectangles[rect][j].x * x_scale > max_x) {
        max_x = rectangles[rect][j].x * x_scale;
      }
      if (rectangles[rect][j].y * y_scale < min_y) {
        min_y = rectangles[rect][j].y * y_scale;
      }
      if (rectangles[rect][j].y * y_scale > max_y) {
        max_y = rectangles[rect][j].y * y_scale;
      }
    }
    bounding_box.push_back(Point(min_x, min_y));
    bounding_box.push_back(Point(max_x, min_y));
    bounding_box.push_back(Point(max_x, max_y));
    bounding_box.push_back(Point(min_x, max_y));
    
    // project squares to image
    vector<polygon_t> projected_squares;
    project_regions(h, projected_squares, REDUCED_SQUARE_SIZE_COLOR);
    
    if (debug) {
      Scalar green( 0, 255, 0);
      Scalar blue( 255, 0, 0);
      Scalar red( 0, 0, 255);
	
      // rescale rectangles (if needed)
      for (unsigned int j=0; j<rectangles.size(); j++) {
        for (unsigned int i=0; i<rectangles[j].size(); i++) {
          rectangles[j][i].x *= x_scale;
          rectangles[j][i].y *= y_scale;
        }
      }
	
      // draw chart frame
      drawContours(debug_image, rectangles, -1, green, 2);
	
      // draws chart corners
      polygonf_t dest;
      perspectiveTransform(source, dest, h);
      for (int i=0; i<4; i++) {	    
        circle(debug_image, dest[i], 6 * x_scale, i == 0 ? (mirrored ? red : blue) : green, 2);
      }
	
      // draw projected squares
      drawContours(debug_image, projected_squares, -1, blue, 2);
	
      // saving color squares image
      Mat image_mask(debug_image.rows, debug_image.cols, CV_8UC3, Scalar(0, 0, 0));
      Scalar on(1, 1, 1);
      drawContours(image_mask, projected_squares, -1, on, -1);
      string colorSquaresFile(out_path + ".cmsk.png");
      imwrite(colorSquaresFile.c_str(), original.mul(image_mask));
	
      // Write out the image file with a bounding box around all the matched
      // rectangles in the color chart.
      string detectedFileName(out_path + ".cbox.png");
      imwrite(detectedFileName.c_str(), debug_image);
    }
    
    // compute color statistics and write them out
    // This is the actual goal behind all this code -- isolate the color squares in the
    // color chart and write out the color values for each square.
    size_t n = projected_squares.size();
    for (unsigned int i=0; i<n; i++) {
      Mat compute_mask(original.rows, original.cols, CV_8U, Scalar(0));
      vector<polygon_t> sq;
      sq.push_back(projected_squares[i]);
      drawContours(compute_mask, sq, 0, 1, -1);
      Scalar mean, std_dev;
      meanStdDev(original, mean, std_dev, compute_mask);
	
      chart.set_sampled_color(i, mean, std_dev);
    }
    if (debug)
      chart_details.close();

    return bounding_box;
}



void ChartDetector::save_results(const string &dest_file) const
{
  chart.save_sampled_data(dest_file);
}

// make sure that the rectangle's corners are in clockwise order
// and that the first corner is the top left
void ChartDetector::align_rectangle(polygon_t &rect) const
{
  clockwise_rectangle(rect);
  cv::Point v1 = rect[1] - rect[0];
  cv::Point v2 = rect[2] - rect[1];
  if (norm(v1) > norm(v2)) {
    float m1 = (rect[0] + rect[1]).y;
    float m2 = (rect[2] + rect[3]).y;
    if (m1 > m2) {
      polygon_t temp = rect;
      rect[0] = temp[2];
      rect[1] = temp[3];
      rect[2] = temp[0];
      rect[3] = temp[1];
    }
  }
  else {
    float m1 = (rect[0] + rect[1]).x;
    float m2 = (rect[2] + rect[3]).x;
    polygon_t temp = rect;
    if (m1 > m2) {
      rect[0] = temp[3];
      rect[1] = temp[0];
      rect[2] = temp[1];
      rect[3] = temp[2]; 
    }
    else {
      rect[0] = temp[1];
      rect[1] = temp[2];
      rect[2] = temp[3];
      rect[3] = temp[0];
    }
  }
}

// make sure the first corner of the rectangle is the closest to the ref point
void ChartDetector::align_rectangle(polygon_t &rect, const cv::Point &ref) const
{
  int closest = -1;
  double smallest_distance = 1000000;
  for (int i=0; i<4; i++) {
    double dist = norm(rect[i] - ref);
    if (dist < smallest_distance) {
      smallest_distance = dist;
      closest = i;
    }
  }
  if (closest != 0) {
    polygon_t temp = rect;
    for (int i=0; i<4; i++) {
      rect[i] = temp[(i + closest) % 4];
    }
  }
}

// make sure that the rectangle's corners are in clockwise order
void ChartDetector::clockwise_rectangle(polygon_t &rect) const
{
  cv::Point v1 = rect[1] - rect[0];
  cv::Point v2 = rect[2] - rect[1];
  float cross = v1.x * v2.y - v1.y * v2.x;
  if (cross < 1.0) {
    polygon_t temp = rect;
    rect[1] = temp[3];
    rect[3] = temp[1];
  }
}

// shrink rectangle by 'amount'
void ChartDetector::shrink(polygonf_t &rect, int shrink_ratio) const
{
    assert(0 <= shrink_ratio && shrink_ratio <= 100);
    double shrink_factor = ((100.0 - shrink_ratio) / 100.0);

    Point2f center(0, 0);
  for (int i=0; i<4; i++) {
    center += rect[i];
  }
  center = center * 0.25;
  for (int i=0; i<4; i++) {
    Point2f v = rect[i] - center;
    rect[i] = center + v * shrink_factor;
  }
}

// project squares into the image, according to homography h
void ChartDetector::project_regions(const Mat &h, vector<polygon_t> &projected, 
                                    int shrink_ratio) const
{
  for (auto sq = chart.get_regions().begin();
       sq != chart.get_regions().end(); ++sq) {
    polygonf_t tr_square;
    perspectiveTransform(sq->shape, tr_square, h);
    shrink(tr_square, shrink_ratio);
    polygon_t int_square;
    for (unsigned int i=0; i<tr_square.size(); i++) {
      int_square.push_back(cv::Point(roundf(tr_square[i].x), roundf(tr_square[i].y)));
    }
    projected.push_back(int_square);
  }
}

Mat ChartDetector::compute_homography(const polygonf_t &source, const vector<polygon_t> &rectangles,
                                      const Mat &image, bool &mirrored) const
{
  // select only color regions
  const vector<ColorRegion> &all_regions = chart.get_regions();
  vector<ColorRegion> regions;
  for (auto reg = all_regions.begin(); reg != all_regions.end(); ++reg) {
    if (reg->type != BLACK && reg->type != WHITE) {
      regions.push_back(*reg);
    }
  }
  colorRegionSize_t nbr_colors = regions.size();
  // create reference order
  vector<intel> ref_int(nbr_colors);
  for (colorRegionSize_t i=0; i<nbr_colors; i++) {
    ref_int[i].intensity = 0.2126 * regions[i].printed_color.red + 0.7152 
      * regions[i].printed_color.green + 0.0722 * regions[i].printed_color.blue;
    ref_int[i].x = (int)i;
    ref_int[i].y = 0;
  }
  sort (ref_int.begin(), ref_int.end(), compare_intel);

  vector<Mat> homographies;
  colorRegionSize_t min = nbr_colors * nbr_colors;
  int orientation = -1;
  int mirror[4] = { 1, 0, 3, 2};
  // test each of the 4 possible rotations + mirror
  for (int side=0; side<8; side++) {
    polygonf_t dest;
    for (unsigned int j=0; j<rectangles.size(); j++) {
      polygonSize_t n = rectangles[j].size();
      for (polygonSize_t i=0; i<n; i++) {
        if (side < 4) {
          dest.push_back(rectangles[j][(i+side)%n]);
        }
        else {
          dest.push_back(rectangles[j][(mirror[i]+side)%n]);
        }
      }
    }

    homographies.push_back(findHomography(source, dest));

    // project squares to image
    vector<polygon_t> projected;
    project_regions(homographies[side], projected, REDUCED_SQUARE_SIZE_INTENSITY);

    // compute color statistics
    vector<intel> sample_int(nbr_colors);
    for (colorRegionSize_t i=0; i<nbr_colors; i++) {
      Mat compute_mask(image.rows, image.cols, CV_8U, Scalar(0));
      vector<polygon_t> sq;
      sq.push_back(projected[i]);
      drawContours(compute_mask, sq, 0, 1, -1);
      Scalar mean, std_dev;
      meanStdDev(image, mean, std_dev, compute_mask);
      sample_int[i].intensity = 0.2126 * mean[2] + 0.7152 * mean[1] + 0.0722 * mean[0];
      sample_int[i].x = (int)i;
      sample_int[i].y = 0;
    }
    sort (sample_int.begin(), sample_int.end(), compare_intel);

    colorRegionSize_t diff = compare_order(ref_int, sample_int);
    if (diff < min) {
      min = diff;
      orientation = side;
    }
  }
  assert(orientation != -1);
 
  mirrored = orientation > 3;

  return homographies[orientation];
}

bool compare_area (const polygon_t &a, const polygon_t &b) { 
  return (get_rect_area(a)<get_rect_area(b)); 
}

// TODO: deal with outer rectangle occluded
int ChartDetector::validate_group(const vector<polygon_t> &rectangles, 
                                  model_group_t &group, const vector<float> &ratios)
{
  size_t gn = group.indices.size();
  if (debug) {
    chart_details << gn << " rectangles in group." << endl;
  }
  unsigned int passed = 0;
  set<int> indices;
  for (int i=0; i<(int)(gn-1); i++) {
    double ratio = float(get_rect_area(rectangles[group.indices[i+1]])) / get_rect_area(rectangles[group.indices[i]]);
    if (debug) {
      chart_details << "  ratio: " << ratio << endl;
    }
    if (fabs(ratio - ratios[passed]) < 0.05) {
      passed++;
      if (!indices.count(group.indices[i])) {
        indices.insert(group.indices[i]);
      }
      if (!indices.count(group.indices[i+1])) {
        indices.insert(group.indices[i+1]);
      }
    }
    if (passed == ratios.size()) {
      break;
    }
  }
  if (passed >= ratios.size()-1) {
    group.indices.resize(indices.size());
    int i = 0;
    for (set<int>::iterator it = indices.begin(); it != indices.end(); ++it) {
      group.indices[i++] = *it;
    }
  }
  return passed;
}

// select the rectangles corresponding to the chart boundary
polygonSize_t ChartDetector::select_rectangles(vector<polygon_t> &rectangles)
{
  // sort rectangles by decreasing area
  sort(rectangles.begin(), rectangles.end(), compare_area);

  // compute ratio of areas in rectangles from model
  size_t ms = chart.get_frame().size();
  vector<float> ratios;
  for (size_t i=0; i<ms-1; i++) {
    ratios.push_back(float(get_rect_area(chart.get_frame()[i+1])) / get_rect_area(chart.get_frame()[i]));
    if (debug) {
      chart_details << "ratio: " << ratios.back() << endl;
    }
  }
  // group rectangles with the same center (to deal with multiple charts)
  size_t n = rectangles.size();
  vector<model_group_t> groups;
  const double center_threshold = 0.015;
  for (int i=0; i<(int)n; i++)
    {
      Point2f center = get_center(rectangles[i]);
      if (debug) {
        chart_details << "center: " << center.x << " - " << center.y << endl;
      }
      bool placed = false;
      for (vector<model_group_t>::iterator it = groups.begin(); it != groups.end(); ++it) {
        double diff = norm(it->center - center);
        double diagonal = norm(rectangles[i][2] - rectangles[i][0]);
        if (debug) {
          chart_details << "diff : " << diff << ", diagonal: " << diagonal << ", ratio: " << diff/ diagonal << endl;
        }
        if (diff / diagonal < center_threshold) {
          it->indices.push_back(i);
          placed = true;
          break;
        }
      }
      if (!placed) {
        model_group_t new_group;
        new_group.indices.push_back(i);
        new_group.center = center;
        groups.push_back(new_group);
      }
    }
  if (debug) {
    chart_details << "Found " << groups.size() << " groups." << endl;
  }
  // return the first group that passes the area ratio test
  for (vector<model_group_t>::iterator it = groups.begin(); it != groups.end(); ++it) {
    if (validate_group(rectangles, *it, ratios) >= (int)(ratios.size()-1)) {
      vector<polygon_t> temp(it->indices.size());
      for (unsigned int i=0; i<it->indices.size(); i++) {
        temp[i] = rectangles[it->indices[i]];
      }
      rectangles.resize(it->indices.size());
      for (unsigned int i=0; i<it->indices.size(); i++) {
        rectangles[i] = temp[i];
      }
      return rectangles.size();
    }
  }
  return -1;
}

#endif
