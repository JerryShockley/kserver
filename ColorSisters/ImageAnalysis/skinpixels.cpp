//
//  skinpixels.cpp
//
//  Created by Scott Trappe on 5/20/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//
// FACE PIXEL DATA FILE FORMAT (.fpix.txt, .fpdb.txt)
// ==================================================
// Face data is stored as ASCII text with either LF or CR-LF marking end-of-line.
// If the file name ends with the extension ".fpix.txt" it should contain data
// for exactly one face. If the file name ends with a ".fpdb.txt" extension,
// the file may contain data for multiple faces. The data for a single face
// consists of a header line followed by one or more data lines.
//
// Header Line
// -----------
// The format of the header line is:
//
//	<face-ID> <shade-name> <pixel-count> [<color-space>]
//
// Exactly one space separates each field. Some legacy pixel data files have
// a simpler header line in the format:
//
//	<pixel-count>
//
// The format of each field is:
//	<face-ID>	any sequence of characters not including whitespace
// 	<shade-name>	any sequence of characters not including whitespace
//	<pixel-count>	an integer
//      <color-space>	either the string "RGB" or "Lab"
//
// <face-ID> is the name of the image file containing the original image. The
// <face-ID> is used to identify exemplars and hence must be unique across all
// faces used as exemplars for recommendation purposes. The case of letters and
// any extension on <face-ID>, if present, should be ignored in comparisons
// (e.g., "image.jpg", "IMAGE.jpg" and "image.PPM" should be treated as the
// same <face-ID>).
//
// <shade-name> is the name of the shade for a particular cosmetics brand; it
// is the judgment by a human expert of the best matching shade for this face.
// If no shade has been associated with this face image, <shade-name> is '??'.
// No brand information is included. If <shade-name> matches the pattern:
//
//	[CNW][1-8]
//
// (e.g., C1, N4, W7), it is assumed to be L'Oreal True Match Foundation. This
// is only important to the "Kuiper" tool, which uses L'Oreal foundation shades
// to measure accuracy of the ranking algorithm.
//
// <pixel-count> is the number of pixel values for this face; the number of
// data values on the following lines must match this count.
//
// <color-space> indicates which color space the data values represent, either
// sRGB (with a D65 color temperature), or CIE-LAB. If <color-space> is absent,
// sRGB is assumed.
//
// Data Lines
// ----------
// Pixels are reprented as a triple of values, called channels. The
// interpretation of what each value represents depends on the color space:
//
//	<color-space>	<Channel-1>  <Channel-2>  <Channel-3>
//	-------------	-----------  -----------  -----------
//	sRGB		    Red         Green        Blue
//      CIE-LAB	            L*           a*           b*
//
// The channel data can be organized into one of three formats:
//	(1) pixels
//	(2) channels, or
//	(3) value counts
//
// In Format (1), <pixel-count> lines following the header; each line contains
// data for a single pixel, in the order:
//
//	<channel-1-value> <channel-2-value> <channel-3-value>
//
// Example:
//
//	image1.jpg N3 15329 RGB
//	34 183 208
//	103 4 216
//	122 0 23
//	78 240 225
//	9 184 73
//	... (for 15324 more lines)
//
// Format (2) has exactly three lines following the header line; each line
// contains all the data for a single channel (e.g., in RGB, the first data
// line has all the Red values, the second data line has the Green values,
// and the third line has the Blue values). Values for pixel N are split
// across the three lines: the N-th value on each line. There must be exactly
// <pixel_count> values on each line. Example:
//
//	image1.jpg N3 15329
//	34 103 122 78 9 ...
//	183 4 0 240 184 ...
//	208 216 23 225 73 ...
//
// Format (3) is a compressed representation where the pixel structure need
// not be preserved. Like format (2), there are exactly three lines following
// the header line, one for each channel. However, rather than the actual
// channel values, the data is in this format:
//
//	<least-value> <val-1-count> <val-2-count> ...
//
// <least-value> is the lowest-valued channel value that occurs at least once
// in the data set; <val-1-count> is the number of occurences of that channel
// value. <val-2-count> is the number of occurences of the channel value
// "<least-value> + 1", and so on. If the last count represents a channel value
// less than CHAN_MAX_VAL, all remaining channel values occured zero times.
// To distinguish format (3) from format (2), the <pixel-count> is the negated
// count of pixels, e.g., -15329 instead of 15329. The sum of the counts on
// each line must match the absolute value of <pixel-count>. Example:
//
//	image1.jpg N3 -15329
//	9 17 24 42 75 52 30 19 12 5 0 0 0 3 21 63 102 145 201 287 219 243 130 ...
//	0 8 11 13 16 15 17 11 23 18 18 19 21 42 37 49 41 53 28 71 69 82 74 ...
//      23 1 0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 5 5 6 6 8 8 10 11 14 16 17 21 23 ...
//
// While a negative <pixel-count> signals Format (3), a positive <pixel-count>
// does not identify whether the data will be in Format (1) or Format (2). This
// is determined by examining the data line itself: if the number of values on
// the data line is exactly three, then it is a pixel line, otherwise it is a
// channel line. If <pixel-count> is three, then this would be ambiguous, but
// this is extremely unlikely to occur in practice.
//
// Channel Values
// --------------
// Channel values can be encoded either as integers or floating point values.
// The valid range of values depends on the color space and the encoding type
// according to the table below:
//
//	Color Space   Number Type   Value Range
//	-----------   -----------   -----------
//	sRGB          Floating Pt   R,G,B: [0.0, 1.0]
//      sRGB	      Integer	    R,G,B: [0, 255]
//	CIE-LAB	      Floating Pt   L*: [0.0, 100.0]
//				    a*: [-86.182, 98.259]
//				    b*: [-107.87, 94.482]
//	CIE-LAB	      Integer	    L*: [0, 100]
//				    a*: [42, 226]
//				    b*: [20, 222]
//
// A floating point sRGB value of 1.0 is equivalent to the integer value 255
// (i.e., the relationship between floating point and integer values is:
//
//	integer-value = floating-point-value * 255.0
//
// Note that for CIE-LAB, the integer representation of a* and b* is not the
// "true" value; each is biased by 128 so that the value is always positive:
//
//	encoded-a = true-a + 128
//	encoded-b = true-b + 128
//
// When data is in Format (3), only the integer encoding is allowed.
//
// Floating point vs. integer encoding is determined by analysis of the data
// line: if a single value on the data line is in floating-point, the entire
// data-line is taken to be floating-point. All channel values for a single
// face must be encoded the same way: all integers or all floating point.
//
// Sorting and Pixel Coherency
// ---------------------------
// By default, Formats (1) and (2) maintain "pixel coherency": the three
// values composing a pixel are either on the same line (Format (1)), or in
// the same relative position (N-th data value for Format (2)). With pixel
// coherency, it is possible to convert the face data between color spaces
// (e.g., sRGB -> CIE-LAB).
//
// Because the Kuiper analysis requires data to be sorted, the pixel data may
// instead be stored as sorted values; sorting is performed on each channel
// independently and consequently destroys pixel coherency. It is STRONGLY
// recommended that sorted data NOT be stored as Format (1); ideally, sorted
// data should only be stored in Format (3) (which leverages the ordering
// to greatly reduce the storage requirements for the data).
//
// When reading in data for a face, the class determines whether the data
// is already sorted and if so, prevents color space conversions.

#include <iostream>
#include <sstream>
#include <cmath>

#include "skinpixels.h"
#include "common.h"
#include <opencv2/core/core.hpp>

extern "C" {
#ifdef __COMPILED_ON_XCODE    // defined in Prefix.pch for the project
#include "colorspace.h"
#else
#include "../lib/colorspace/colorspace.h"
#endif
}

using namespace std;

void SkinPixels::clear()
{
    imageID = "";
    shadeName = "";
    pixelCnt = 0;
    format = f_any;
    colorSpace = cs_rgb;
    asFloat = false;
    sorted = true;
    for (auto chan = 0; chan < NUM_CHANS; chan++)
	chans[chan].clear();
    memset(valCnts, 0, sizeof(valCnts));
}


// load -- read in pixel values from an openCV iamge
void SkinPixels::load(const cv::Mat& image, limit_t filter)
{
    cv::Mat bgr_planes[NUM_CHANS], vectorized[NUM_CHANS];
    
    clear();
    
    // image is a rectangular array with three "planes", one for each of
    // the colors (R, G, B). We need to access each plane separately;
    // split creates an array of matrices, one plane in each matrix.
    cv::split(image, bgr_planes);
    
    // Somewhat non-intuitively, the split matrices have the R, G, and B
    // values assigned this way: B is in plane 0, G in plane 1, and R in
    // plane 2. Since the common convention is the ordering R, G, B,
    // we will swap the B & R planes in the following operation.
    
    // reshape(1, 1) changes the rectangular matrix into a single row
    // (vector) of values, without copying data, so this operation is cheap.
    vectorized[0] = bgr_planes[2].reshape(1, 1);
    vectorized[1] = bgr_planes[1].reshape(1, 1);
    vectorized[2] = bgr_planes[0].reshape(1, 1);
    
    // Now comes the relatively expensive copy of data from the OpenCV
    // matrix into the SkinPixels array of channels.
    if (filter == l_none) {
	// If no filtering is done, can do a mass copy using the vector<>
	// assign() function
	for (auto chan = 0; chan < NUM_CHANS; chan++) {
	    const uchar* p = vectorized[chan].ptr<uchar>(0);
	    
	    // Copy data to a vector.  Note that (p + mat.cols) points to the
	    // end of the row.
	    chans[chan].assign(p, p + vectorized[chan].cols);
	}
    } else {
	// filter out pixels that are either all zeros or all ones from the
	// matrix (these represent masked-off portions of the image, don't
	// want it polluting the data set. Unfortunately, means we have to
	// copy over the data pixel-by-pixel to do the comparisons.
	int numPixels = vectorized[0].cols;
	for (auto chan = 0; chan < NUM_CHANS; chan++)
	    chans[chan].reserve(numPixels);	// make big enough
	for (int i = 0; i < numPixels; i++) {
	    unsigned chanSum = 0;
	    for (auto chan = 0; chan < NUM_CHANS; chan++)
		chanSum += vectorized[chan].at<uchar>(i);
	    
	    if ((chanSum > 0 && chanSum < (NUM_CHANS * 255)) ||
		(chanSum == 0 && filter == l_noMax) ||
		(chanSum == (NUM_CHANS * 255) && filter == l_noMin))
		// Either the pixel is not all zeros or all ones, or
		// it was all zeros and the filter mode was l_noMax (so all
		// zeroes is OK) or all ones and the filter mode was l_noMin
		for (auto chan = 0; chan < NUM_CHANS; chan++)
		    chans[chan].push_back(vectorized[chan].at<uchar>(i));
	}
    }
    pixelCnt = chans[0].size();
    format = f_pixels;		    // data is still organized by pixel
    sorted = false;
    colorSpace = cs_rgb;
}


// loadOneFace -- read pixel data for one image
//
// The input file is text; it may contain data for one or more faces. The data for a face is
// structured into multiple records; a record is one line, which may be terminated using
// either UNIX or MS-DOS conventions. There are three possible types of lines: a header line,
// a pixel line, and a channel line. A header line always comes first. Its format is:
//
// The output is a Vector of Faces; for each face there are three sub-vectors containing the
// channel values for the pixels in the face; they are guaranteed to be sorted from least
// to greatest value.

bool SkinPixels::loadOneFace(TextInput& pixelFile, ChanValInt minVal, ChanValInt maxVal)
{
    string headerLine, csName;
    stringstream header;
    dindex_t totClipped = 0;			// Don't do anything with this info currently
    dindex_t totOutOfRange = 0;			// Don't do anything with this info curretnly
    dindex_t dataLineCnt = 0;
    dindex_t dataLinesToRead = NUM_CHANS;	// Must always read at least one data line
    linetype_t lineType = UnknownLine;
    dindex_t pixelsStored;
    int pixelsInFile;
   
    clear();					// inits all fields
    
    if (!pixelFile.getline(headerLine))
    	return false;
    
    header = stringstream(headerLine);
    if (headerLine.find(' ') != string::npos) {
	// "new" style header line with 3 fields: imagename, shadename, sample count
	header >> imageID >> shadeName >> pixelsInFile;
	if (header >> csName && csName == "Lab")
	    colorSpace = cs_lab;
    } else	// "old" style header line -- just sample count
	header >> pixelsInFile;
    if (pixelsInFile == 0 || abs(pixelsInFile) > 200000)
	throw KokkoException(pixelFile.fileMsg("couldn't parse header line"));
    
    if (pixelsInFile == NUM_CHANS)
	throw KokkoException(pixelFile.fileMsg("Ambiguous face data -- must have more than 3 pixels per face"));
    
    if (pixelsInFile < 0) {
	lineType = CountLine;
	format = f_counts;
	pixelCnt = -pixelsInFile;	// sum of all counts should equal this
    } else {
	pixelCnt = pixelsInFile;	// sum of all counts should equal this
	for (auto chan = 0; chan < NUM_CHANS; chan++)
	    chans[chan].reserve(pixelCnt);
    }
    pixelsStored = pixelCnt;			// assume will keep all pixels read
    while (dataLineCnt < dataLinesToRead) {
	ParseDataLine chanLine(pixelFile, pixelCnt, lineType, minVal, maxVal);
	
	if (lineType == UnknownLine) {		// Need to determine which time of line this is
	    asFloat = chanLine.isFloat();
	    if (chanLine.valsRead() == NUM_CHANS) {
		format = f_pixels;
		sorted = false;			// pixel data is never sorted
		lineType = PixelLine;
		dataLinesToRead = pixelCnt;
	    } else {
		lineType = ChanLine;
		format = f_chans;
	    }
	}
	switch (lineType) {
	    default:
		throw KokkoException("Internal Error: lineType = " + to_string(UnknownLine));
		break;
		
	    case PixelLine:
		// when data is in pixel format, sorting is irrelevant
		if (chanLine.valsOutOfRange() || chanLine.valsClipped())
		    // if any errors occured on this pixel, just drop the pixel
		    pixelsStored--;
		else	    // add the pixel components to each channel
		    for (auto chan = 0; chan < NUM_CHANS; chan++)
			chans[chan].push_back(chanLine.at(chan));
		break;
		
	    case ChanLine:
		for (ChanValInt v : chanLine.data())
		    chans[dataLineCnt].push_back(v);
		if (chanLine.size() < pixelsStored)
		    pixelsStored = static_cast<int>(chanLine.size());
		if (!chanLine.isSorted())
		    sorted = false;
		break;
		
	    case CountLine:
		ChanValInt start = chanLine.at(0);
		unsigned totalCount = 0;
		
		for (dindex_t i = 1; i < chanLine.size(); i++) {
		    valCnts[dataLineCnt][start++] = chanLine.at(i);
		    totalCount += chanLine.at(i);
		}
		if (totalCount < pixelsStored)
		    pixelsStored = totalCount;
		break;
	}
	totClipped += chanLine.valsClipped();
	totOutOfRange += chanLine.valsOutOfRange();
	dataLineCnt++;
    }
    if (pixelsStored < pixelCnt) {
	// one or more values were not stored, make sure all the channels have the
	// same number of values and that their length == pixelsStored
	if (lineType == ChanLine ) {
	    for (auto chan = 0; chan < NUM_CHANS; chan++)
		if (chans[chan].size() > pixelsStored)
		    chans[chan].resize(pixelsStored);
	} else if (lineType == CountLine) {
	    for (auto chan = 0; chan < NUM_CHANS; chan++) {
		unsigned cur_count = 0;
		unsigned v;		// Must be larger range than ChanValInt for loops to work
		
		for (v = 0; v <= CHAN_MAX_INT; v++) {
		    cur_count += valCnts[chan][v];
		    if (cur_count > pixelsStored) {
			// Adjust down this entry to not exceed the total
			valCnts[chan][v] -= cur_count - pixelsStored;
			break;
		    }
		}
		// Any remaining counts should be set to zero
		for (; v <= CHAN_MAX_INT; v++)
		    valCnts[chan][v] = 0;
	    }
	}
	// No need to do anything special for PixelLine, chans are always coherent
	pixelCnt = pixelsStored;
    }
    return true;
}


void SkinPixels::loadFirstFace(const string& inFile, ChanValInt lowLim, ChanValInt hiLim)
{
    TextInput pixelFile(inFile);

    if (!pixelFile.is_open())
	throw KokkoException("Could not open file: \"" + inFile + "\": " + std::strerror(errno));

    if (!loadOneFace(pixelFile, lowLim, hiLim))
	throw KokkoException(inFile + ": no face found");
}


void SkinPixels::save(const string& outfile)
{
    ofstream out;			// Only used if the results file is different than stdout
    streambuf *backup = NULL;
    int outPixels = static_cast<int>(pixelCnt);
    
    if (outfile != "") {
	out.open(outfile, ios::out);
	if (!out.is_open())
	    throw KokkoException("Could not open output file: \"" + outfile + "\": " + std::strerror(errno));
	backup = cout.rdbuf();     // back up cout's streambuf
	cout.rdbuf(out.rdbuf());
    }
    
    // Write the header line
    cout << imageID << ' ' << ((shadeName != "")? shadeName : "??");
    cout << ' ' << ((format == f_counts)? -outPixels : outPixels);
    cout << ' ' << ((colorSpace == cs_lab)? "Lab" : "RGB") << endl;
    
    // Datalines are written in the specified format
    switch (format) {
	case f_pixels:
	    for (dindex_t pixel = 0; pixel < pixelCnt; pixel++) {
		for (auto chan = 0; chan < NUM_CHANS; chan++) {
		    if (chan != 0)
			cout << ' ';		// separate values with single space
		    outVal(chans[chan].at(pixel));
		}
		cout << endl;
	    }
	    break;
	    
	case f_chans:
	    for (auto chan = 0; chan < NUM_CHANS; chan++) {
		for (dindex_t pixel = 0; pixel < pixelCnt; pixel++) {
		    if (pixel != 0)
			cout << ' ';		// separate values with single space
		    outVal(chans[chan].at(pixel));
		}
		cout << endl;
	    }
	    break;
	    
	case f_counts:
	    for (auto chan = 0; chan < NUM_CHANS; chan++) {
		int high_val;		// can go negative if no counts present
		bool firstValOutput = false;
		
		// first find the last (highest) non-zero value
		for (high_val = CHAN_MAX_INT; high_val >= 0; high_val--)
		    if (valCnts[chan][high_val])
			break;
		
		// Now scan from the lowest value up; don't output
		// anything until the first non-zero count is found
		for (auto val = 0; val <= high_val; val++)
		    if (firstValOutput || valCnts[chan][val] > 0) {
			if (!firstValOutput) {
			    // This is the first non-zero value, so write
			    // it out to identify the starting value; all
			    // the remaining values are counts (with the
			    // ordering implying a monotonic increase in values).
			    cout << val;
			    firstValOutput = true;
			}
			cout << ' ' << valCnts[chan][val];
		    }
		if (high_val < 0)
		    cout << "0 0";		// No non-zero counts
		cout << endl;
	    }
	    break;
	    
	default:
	    throw KokkoException("Internal error: SkinPixels::save() with format = " + to_string(format));
	    break;
    }
    if (backup != NULL) {
	cout.rdbuf(backup);
	out.close();
    }
}


void SkinPixels::setFormat(format_t newFormat)
{
    if (newFormat != f_any && newFormat != format) {
	if (format == f_counts) {
	    // desired format must be either PixelLine or ChanLine
	    // build channel values from a table of value counts
	    for (auto chan = 0; chan < NUM_CHANS; chan++) {
		chans[chan].clear();
		chans[chan].reserve(pixelCnt);
		// Loop is more complicated because has to go over the entire
		// range of the data type
		
		for (ChanValInt val = 0; ; ) {
		    // This version of the vector insert() function will insert
		    // the appropriate # of entries, each with value 'val'
		    chans[chan].insert(chans[chan].end(), valCnts[chan][val], val);
		    if (val == CHAN_MAX_INT)
			break;
		    val++;
		}
	    }
	    sorted = true;		// converting always leaves chans sorted
	} else if (newFormat == f_counts) {
	    // current format must be either PixelLine or ChanLine
	    // build a table of value counts from the individual data values
	    memset(valCnts, 0, sizeof(valCnts));
	    for (auto chan = 0; chan < NUM_CHANS; chan++) {
		for (ChanValInt val : chans[chan])
		    valCnts[chan][val]++;
	    }
	}
	format = newFormat;		// done the conversion
    }
}


bool SkinPixels::setColorSpace(colorspace_t cs)
{
    double L, a, b, rgb[NUM_CHANS];

    if (colorSpace == cs)
	return true;			// No change, so was "successful"
    if (sorted)
	return false;			// Can't change if pixel coherency lost
    switch (cs) {
	case cs_rgb:			// converting from LAB -> sRGB
	    for (dindex_t i = 0; i < pixelCnt; i++) {
		// First convert to floating point and un-bias
		L = chans[0].at(i);
		a = static_cast<double>(chans[1].at(i) + 128);
		b = static_cast<double>(chans[2].at(i) + 128);
		
		// Do the conversion
		Lab2Rgb(&rgb[0], &rgb[1], &rgb[2], L, a, b);
		
		// Now convert rgb from [0.0, 1.0] -> [0, 255]
		for (auto chan = 0; chan < NUM_CHANS; chan++)
		    chans[chan].at(i) = static_cast<int>(round(rgb[i] * CHAN_MAX_INT_AS_DOUBLE));
	    }
	    break;
	    
	case cs_lab:			// converting from sRGB -> LAB
	    for (dindex_t i = 0; i < pixelCnt; i++) {
		// First convert [0, 255] to floating point in range [0.0, 1.0]
		for (auto chan = 0; chan < NUM_CHANS; chan++)
		    rgb[chan] = chans[chan].at(i) / 255.0;
		
		// Now do the conversion from sRGB to CIE-LAB
		Rgb2Lab(&L, &a, &b, rgb[0], rgb[1], rgb[2]);
		
		// L* value just needs to be rounded
		chans[0].at(i) = static_cast<int>(round(L));
		// a* and b* can be negative, bias by 128 to make positive
		chans[1].at(i) = static_cast<int>(round(a)) + 128;
		chans[2].at(i) = static_cast<int>(round(b)) + 128;
	    }
	    break;
    }
    colorSpace = cs;			// pixels changed to new color space
    return true;
}


void SkinPixels::sortChans()
{
    if (!sorted && (format == f_pixels || format == f_chans)) {
	for (auto chan = 0; chan < NUM_CHANS; chan++)
	    // Sort each vector from lowest to highest values in pixels
	    sort(chans[chan].begin(), chans[chan].end());
	format = f_chans;		// sorting destroys pixel ordering
    }					// if format was f_counts, already sorted
    sorted = true;
}


void SkinPixels::outVal(ChanValInt val)
{
    if (asFloat)
	cout << (static_cast<double>(val) / CHAN_MAX_INT_AS_DOUBLE);
    else
	cout << (unsigned)val;		// must explicitly cast in case ChanValInt is a char type
}


// getline -- read one line of data containing channel values
//
// One line is read from the input stream pixelFile.

void SkinPixels::ParseDataLine::getline()
{
    string chanLine;
    stringstream oneChan;
    int c;
    
    if (!pixelFile.getline(chanLine))
	throw KokkoException(pixelFile.fileMsg("Unreadable pixel data"));
    
    oneChan = stringstream(chanLine);
    if (chanLine.find('.') == string::npos)	    // No periods found in the input
	if (lineType == CountLine)
	    parseCountLine(oneChan);
	else
	    parseIntLine(oneChan);
	else if (lineType == CountLine)
	    throw KokkoException(pixelFile.fileMsg("Value Counts data must be all integers"));
	else {
	    floatingPoint = true;
	    parseFloatLine(oneChan);
	}
    
    // Skip any trailing whitespace and confirm we are at end of line
    do
	c = oneChan.get();
    while (isspace(c));
    if (c != EOF)
	throw KokkoException(pixelFile.fileMsg("Unexpected character '" + string(1, c) + "'"));
    reportErrors();
}


void SkinPixels::ParseDataLine::parseCountLine(stringstream& chanLine)
{
    unsigned startVal, count;
    
    
    if (!(chanLine >> startVal))
	throw KokkoException(pixelFile.fileMsg("Could not read pixel data"));
    if (startVal > CHAN_MAX_INT)
	throw KokkoException(pixelFile.fileMsg("initial value for channel (" + to_string(startVal)
				+ ") is  out of range"));
    vals.push_back(startVal);
    while (chanLine >> count) {
	valReadCnt += count;			// this makes error check work
	if (startVal > CHAN_MAX_INT)
	    outOfRange++;
	else if (startVal < minVal || startVal > maxVal)
	    clipped++;
	else
	    vals.push_back(count);
	startVal++;
    }
}


void SkinPixels::ParseDataLine::parseIntLine(stringstream& chanLine)
{
    DataLineVal iChanVal;
    
    while (chanLine >> iChanVal) {
	valReadCnt++;
	if (iChanVal > CHAN_MAX_INT)
	    outOfRange++;			// Value is invalid, ignore it
	else
	    addOneVal(iChanVal);
    }
}


void SkinPixels::ParseDataLine::parseFloatLine(stringstream& chanLine)
{
    double fChanVal;
    
    while (chanLine >> fChanVal) {
	valReadCnt++;
	if (fChanVal < 0.0 || fChanVal > CHAN_MAX_FLOAT)
	    outOfRange++;			// Value is invalid, ignore it
	else {				// convert to integer representation
	    double normal = fChanVal * CHAN_MAX_INT_AS_DOUBLE;
	    int iChanVal = static_cast<int>(round(normal));
	    
	    if (abs((static_cast<double>(iChanVal) - normal)) > 0.01)
		cerr << pixelFile.fileMsg("Converted " + to_string(fChanVal) +
					  " to " + to_string(normal) + " -- inexact\n");
	    addOneVal(iChanVal);
	}
    }
}


void SkinPixels::ParseDataLine::addOneVal(DataLineVal chanVal)
{
    // Clip values that are outside the range specified by the configuration options
    // "lowerLum" and "higherLum".
    if (chanVal < minVal || chanVal > maxVal)
	clipped++;				// Choosing to ignore these values
    else {
	if (vals.size() > 0 && chanVal < vals.back())
	    sorted = false;
	vals.push_back(chanVal);
    }
}


void SkinPixels::ParseDataLine::reportErrors()
{
    if (valReadCnt == 0)
	throw KokkoException(pixelFile.fileMsg("Unreadable pixel data"));
    
    if (lineType == UnknownLine) {
	if (valReadCnt != valsExpected && valReadCnt != NUM_CHANS)
	    throw KokkoException(pixelFile.fileMsg(to_string(valReadCnt) + " channel values on line; invalid"));
    } else {
	dindex_t expected;
	
	if (lineType == PixelLine)
	    expected = NUM_CHANS;
 	else
	    expected = valsExpected;
	
	if (valReadCnt < expected)
	    throw KokkoException(pixelFile.fileMsg("Only " + to_string(valReadCnt)
				 + " channel values found on line; "
			         + to_string(expected) + " expected"));
	
	if (valReadCnt > expected)
	    throw KokkoException(pixelFile.fileMsg("Too many channel values ("
			         + to_string(valReadCnt) + ") -- "
				 + to_string(expected) + " expected\n"));
    }
    
    if (outOfRange)
	cerr << pixelFile.fileMsg(to_string(outOfRange)
				  + " channel values were out of range -- ignored\n");
}
