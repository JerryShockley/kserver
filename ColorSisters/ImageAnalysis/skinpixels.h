//
//  skinpixels.h
//
//  Created by Scott Trappe on 5/20/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#ifndef __skinpixels__
#define __skinpixels__

#include <fstream>
#include <vector>
#include <string>

#include <opencv2/opencv.hpp>




#define NUM_CHANS	3
#define CHAN_MAX_INT	255
#define	CHAN_MAX_INT_AS_DOUBLE	(static_cast<double>(CHAN_MAX_INT))
#define CHAN_MAX_FLOAT	(1.0)



class TextInput;

class SkinPixels {
private:
    class ParseDataLine;
    
    typedef unsigned	DataLineVal;
    typedef std::vector<DataLineVal> Dataline;  // must be no smaller than an unsigned short
    typedef Dataline::size_type dindex_t;
    
public:
    typedef unsigned char		ChanValInt;	    // consider making unsigned short or unsigned char
    typedef std::vector<ChanValInt>	Channel;
    typedef enum {f_any, f_chans, f_counts, f_pixels} format_t;
    typedef enum {cs_rgb, cs_lab} colorspace_t;
    
    SkinPixels() : imageID(""), shadeName(""), pixelCnt(0), format(f_any),
		    colorSpace(cs_rgb), asFloat(false), sorted(true) {
	memset(valCnts, 0, sizeof(valCnts));
    }
    void	clear();
    void	load(const cv::Mat& image);
    bool    	loadOneFace(TextInput& pixelFile,
			    ChanValInt minVal = 0,
			    ChanValInt maxVal = CHAN_MAX_INT);
    void	loadFirstFace(const std::string& inface,
			      ChanValInt minVal = 0,
			      ChanValInt maxVal = CHAN_MAX_INT);
    void    	save(const std::string& outfile);
    
    // Information requests
    const std::string& getImageID() const   { return imageID; }
    const std::string& getShadeName() const { return shadeName; }
    dindex_t	getPixelCnt() const	    { return pixelCnt; }
    format_t    getFormat() const	    { return format; }
    colorspace_t getColorSpace() const	    { return colorSpace; }
    bool	getFloat() const	    { return asFloat; }
    bool	getSorted() const	    { return sorted; }
    const Channel& getChan(unsigned c) const  { return chans[c]; }
    const DataLineVal *getCntChan(unsigned c) const { return valCnts[c]; }
    
    // Change dataset
    void	setShadeName(const std::string& name)	{ shadeName = name; }
    void	setImageID(const std::string& name)	{ imageID = name; }
    void	setFloat(bool f)	    { asFloat = f; }
    void	setFormat(format_t fmt);
    bool	setColorSpace(colorspace_t cs);
    void	sortChans();
    
private:
    void	outVal(ChanValInt val);
    
    std::string	imageID;		    // name of the image (original file name)
    std::string	shadeName;		    // shade of makeup chosen for this face
    dindex_t	pixelCnt;		    // # of pixels in the image data
    format_t	format;
    colorspace_t colorSpace;
    bool	asFloat;		    // data was read/should be written in floating point
    bool	sorted;			    // input data was sorted (iff format == f_chans)
    Channel	chans[NUM_CHANS];
    DataLineVal	valCnts[NUM_CHANS][CHAN_MAX_INT + 1];
    
    typedef enum {
	UnknownLine,
	PixelLine,
	ChanLine,
	CountLine
    } linetype_t;
    
    class ParseDataLine {
    public:
	ParseDataLine(TextInput& pfile, dindex_t pixelCnt, linetype_t line = UnknownLine,
		      DataLineVal limLow = 0, DataLineVal limHi = CHAN_MAX_INT) :
		    pixelFile(pfile), lineType(line), minVal(limLow), maxVal(limHi),
		    valsExpected(pixelCnt), sorted(true), floatingPoint(false),
		    valReadCnt(0), clipped(0), outOfRange(0) {
	    getline();
	}
	
	inline bool	isSorted() const	    { return sorted; }
	inline bool	isFloat() const		    { return floatingPoint; }
	inline dindex_t	valsRead() const	    { return valReadCnt; }
	inline dindex_t	valsOutOfRange() const	    { return outOfRange; }
	inline dindex_t	valsClipped() const	    { return clipped; }
	inline dindex_t	size() const	 	    { return vals.size(); }
	inline unsigned& at(dindex_t i)		    { return vals.at(i); }
	inline unsigned& operator[](dindex_t i)	    { return vals[i]; }
	inline Dataline& data()			    { return vals; }
	void	reportErrors();
	
    private:
	TextInput&	pixelFile;
	Dataline	vals;			    // actual values read
	linetype_t	lineType;		    // expected input line format
	DataLineVal	minVal, maxVal;		    // low and high limits -- values outside are ignored
	dindex_t	valsExpected;		    // How many values should be present
	bool		sorted;			    // were input values in non-decreasing order?
	bool		floatingPoint;		    // were input values floating point or integers?
	dindex_t	valReadCnt;		    // how many values were actually read
	dindex_t	clipped;		    // # input values outside range of minVal..maxVal
	dindex_t	outOfRange;		    // # input values < 0 or > CHAN_MAX
	
	void	addOneVal(DataLineVal chanVal);
	void    getline();
	void	parseCountLine(std::stringstream& chanLine);
	void	parseIntLine(std::stringstream& chanLine);
	void	parseFloatLine(std::stringstream& chanLine);
    };
    
};

class TextInput {
public:
    TextInput(const std::string& textFileName) : fileName(textFileName), lineCnt(0) {
	textFile.open(textFileName);
    }
    
    ~TextInput() {
	textFile.close();
    }
    
    inline void open(const std::string& textFileName) {
	textFile.open(textFileName);
	fileName = textFileName;
	lineCnt = 0;
    }
    
    inline void close() {
	textFile.close();
    }
    
    inline bool is_open() {
	return textFile.is_open();
    }
    
    inline bool atEOF() {
	return (textFile.peek(), textFile.eof());
    }
    
    inline std::istream& getline(std::string& il) {
	lineCnt++; return std::getline(textFile, il); }
    
    inline std::istream& getline(std::string& il, char dlm)  {
	lineCnt++; return std::getline(textFile, il, dlm);
    }
    
    inline const std::string name() const {
	return fileName;
    }
    
    inline int lineNum() const {
	return lineCnt;
    }
    const std::string fileMsg(const std::string& msg) const {
	return fileName + ": line " + std::to_string(lineCnt) + ": " + msg;
    }
    
private:
    std::ifstream   textFile;
    std::string	    fileName;
    int		    lineCnt;
};

#endif /* defined(__skinpixels__) */
