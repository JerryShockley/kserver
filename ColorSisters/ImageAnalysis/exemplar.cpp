//
//  exemplar.cpp
//  imagedb
//
//  Created by Scott Trappe on 8/27/14.
//  Copyright (c) 2014, 2015 Kokko, Inc. All rights reserved.
//

#include <utility>
#include "exemplar.h"
#include "common.h"

using namespace std;

// The Kuiper test is used to determine the "distance" between two sets of
// face pixels, as a way of comparing how similar their coloring is. We
// calculate the kuiper distance on each channel of a pixel (pixel values have
// been normalized to [0.0, 1.0]) and then sum the distances across the three
// channels (representing RGB or Lab -- we don't care). Thus the value is in
// the range [0, 3].
//
// The two constants below limit whether a face being compared should be added
// to the ranked list of face matches (the list is ordered by increasing Kuiper
// distance). The upper bound is essentially an optimization to reduce the size
// of the list. As our exemplar (reference face) data set gets larger, we should
// be able to reduce this number. My goal is an upper limit of < 1.0. Currently
// it is set to 3.0 (put all images on the rank-ordered list) because there are
// some faces with no close exemplars, and we are using exemplars collected with
// one color chart but new images are corrected using a different color chart.
//
// The lower bound is not as obvious -- why do we need it? When running the
// test suite, we may be comparing a face to itself. If the pixel sets being
// compared are identical, the Kuiper distance would be 0. However, for reasons
// not understood, modifications to the code (not changing the image processing
// algorithms) will occasionally result in tiny differences in the pixel
// values--sometimes just one pixel out of 20,000. But this is enough to make
// the Kuiper distance > 0, and thus a face would match against itself. I
// empirically determined that a threshold of 0.025 is adequate to exclude these
// not-quite-identical-but-in-reality-the-same-face matches.

#define KUIPER_DIST_MIN 0.025
#define KUIPER_DIST_MAX	3.0	// maximum Kuiper distance to consider a match

// Forward references

static double KuiperCounts(const unsigned v1[], const unsigned v2[], int maxVal);
static	istream& safeGetLine(istream& is, string& t);


void ExemplarDB::load(const string& skinPixelFile, const string& shadeDBfile)
{
    // The file containing skin pixel data is always required
    loadSkinPixels(skinPixelFile);
    
    // The shadeDBfile is optional; if a name is provided, load its contents
    if (shadeDBfile != "")
	loadShades(shadeDBfile);
}

void ExemplarDB::setCompareInterval(int n)
{
    if (n < 1 || n > 100)
	throw KokkoException("Comparison interval '" + to_string(n) + "' is outside valid range 1...100");
    nEvery = n;
}


FaceRank ExemplarDB::match(const SkinPixels& candidateFace)
{
    FaceRank faces;
    
    if (refImages.size() == 0)
	throw KokkoException("Call to ExemplarDB::match() with empty Exemplar table");
    
    for (ImageTable::iterator rit = begin(refImages), rend = end(refImages); rit != rend; rit++) {
	// Calculate the Kuiper distance across each corresponding pair of channels and
	// sum the results to get an overall distance.
	double distanceKuiper = 0.0;
	for (auto i = 0; i < NUM_CHANS; i++)
	    distanceKuiper += KuiperCounts(rit->second->getPixels().getChanCnt(i),
					   candidateFace.getChanCnt(i), CHAN_MAX_INT);
	
	// Insert this comparison result into the ordered list of rankings for this reference face
	
	// Exclude nearly exact matches (distanceKuiper <= KUIPER_DIST_MIN),
	// because that almost certainly means that the two faces being
	// compared are the same image, and exclude really big distances to
	// keep the list shorter (essentially just an optimization).
	if (KUIPER_DIST_MIN < distanceKuiper && distanceKuiper <= KUIPER_DIST_MAX) {
	    faces.insert(FaceRank::value_type(distanceKuiper, rit->second));
	}
    }
    // max_faces == 0 means no limit on how many faces to return
    if (maxFaces > 0 && faces.size() > maxFaces) {
	FaceRank::iterator it = begin(faces);
	
	// skip over the first max_faces elements in the map
	for (unsigned f = 0; f < maxFaces; ++f)
	    it++;	 // Delete all entries past the first max_faces
	faces.erase(it, end(faces));
    }
    return faces;
}


FaceRank ExemplarDB::match(const string& candidateFileName)
{
    SkinPixels candidateFace;
    
    candidateFace.loadFirstFace(candidateFileName);
    // force into counts format for KuiperCounts comparison. This is wrong
    // because I shouldn't have to know that deep down in the call chain I
    // will be calling a particular version of the Kuiper function that uses
    // data in counts format instead of "raw" pixel data. FIXME!!! 15/01/26.
    candidateFace.setFormat(SkinPixels::f_counts);
    
    return match(candidateFace);
}


Recommendations ExemplarDB::recommend(const FaceRank& matches, const BrandSet& justThisBrand)
{
    bool allBrands = (justThisBrand.size() == 0);
    unordered_map<CShadePtr, pair<int, int>> shadeCounts;
    int rank = 0;
    
    if (shades.size() == 0)
	throw KokkoException("ExemplarDB::recommend -- no shades loaded for exemplars");
    
    // For each exemplar (face), add its list of makeup shades to the map.
    for (auto mi = begin(matches), mend = end(matches); mi != mend; ++mi) {
	ExemplarPtr face = mi->second;
	const ShadeList& shades = face->getShades();

	for (auto si = shades.cbegin(), send = shades.cend(); si != send; ++si) {
	    CShadePtr curShade = *si;
	    const string shadeName = curShade->getShadeCode();
	    
	    if (allBrands || justThisBrand.count(curShade->getBrandName()) > 0) {
		auto& counts = shadeCounts[curShade];
		counts.first++;		    // One more occurence of this shade
		counts.second = rank;	    // the current rank will break ties
	    }
	}
	--rank;				    // subsequent faces will have lower ranks
    }
    // Now build a inverse map sorted by counts. It must be a multimap because shades
    // in different brands might have the same count.
    multimap<pair<int, int>, CShadePtr> freqOrder;
    for (auto sci = shadeCounts.cbegin(), scend = shadeCounts.cend(); sci != scend; ++sci) {
	freqOrder.emplace(sci->second, sci->first);
    }
    
    Recommendations out;
    // Walk the multimap in reverse order -- the entries with the highest counts will be at
    // the end. The key is a pair with the count in the first position (highest precedence)
    // with the rank in the second position, so two shades with the same count (typically 1)
    // will sort with the shade that was earlier in the FaceRank first (because it is a
    // "better" match
    //
    // At the same time, we will be breaking the map into multiple lists sorted by brand
    for (auto foi = freqOrder.crbegin(), foend = freqOrder.crend(); foi != foend; ++foi) {
	CShadePtr curShade = foi->second;
	ShadeList& curShadeList = out[curShade->getBrandName()];
	if (curShadeList.size() < maxShades)
	    curShadeList.push_back(curShade);
    }
    return out;
}


Recommendations ExemplarDB::recommend(const SkinPixels& pixels, const BrandSet& justThisBrand)
{
    // SRT 15/01/26. Perhaps add an assert() here that pixels.getFormat() == f_counts?
    return recommend(match(pixels), justThisBrand);
}


void ExemplarDB::setMaxFaces(unsigned n)
{
    if (n > 100)
	throw KokkoException("Maximum ranked faces of '" + to_string(n) + "' is outside valid range 0...100");
    maxFaces = n;
}


void ExemplarDB::setMaxRecShades(unsigned n)
{
    if (n < 1 || n > 100)
	throw KokkoException("Maximum Recommendations per Brand interval '" + to_string(n) + "' is outside valid range 1...100");
    maxShades = n;
}


void ExemplarDB::loadSkinPixels(const string& skinPixelFile)
{
    TextInput faceData(skinPixelFile);
    SkinPixels facePixels;
    
    refImages.clear();
    if (!faceData.is_open())
	throw KokkoException("Could not open file: \"" + skinPixelFile + "\": " + strerror(errno));
    
    while (facePixels.loadOneFace(faceData)) {
	 // force into counts format for KuiperCounts comparison
	facePixels.setFormat(SkinPixels::f_counts);
	
	// Strip off any filename extension at the end of the image ID
	// We should standardize on NOT including extensions in any of the image
	// names; this code should eventually be removed. !!FIXME!!
	string imageName = facePixels.getImageID();
	string::size_type extStart = imageName.find('.');
	if (extStart != string::npos)
	    imageName.erase(extStart);
	
	shared_ptr<Exemplar> new_face = make_shared<Exemplar>(imageName, facePixels);
	refImages.emplace(imageName, new_face);
    }
    
    if (refImages.size() == 0)
	throw KokkoException(skinPixelFile + ": no valid faces found");
}


void ExemplarDB::loadShades(const string& shadesCSVfile)
{
    ifstream shadef(shadesCSVfile);
    string line;
    int line_cnt = 0;
    bool header_line = true;
    vector <BrandPtr> brandList;
    
    brands.clear();
    shades.clear();
    
    if (!shadef.good())
	throw KokkoException("Unable to open Shade Table '" + shadesCSVfile + "'.");
    
    // Read each line in the CSV file, parsing individual cells
    while (safeGetLine(shadef, line)) {
	istringstream row(line);
	string cell, imageID;
	ShadeList exemplar_shades;
	ImageTable::iterator curImage;		// reference to Exemplar for this line
	int col_cnt = 0;
	
	line_cnt++;
	if (line.length() == 0 || line[0] == '#' || line.find(',') == string::npos)
	    continue;
	
	while (getline(row, cell, ',')) {
	    if (header_line) {		// First non-blank, non-comment line
		if (col_cnt > 0) {	// ignore the column 1 name, we know that is the exemplar
		    if (cell.length() == 0)
			throw KokkoException(shadesCSVfile + ": Missing brand name in column " +
					     to_string(col_cnt + 1) + " on line " + to_string(line_cnt));
		    
		    BrandPtr newb = make_shared<Brand>(cell);
		    // std::pair<BrandTable::iterator, bool> ret;
		    auto ret = brands.emplace(cell, newb);
		    if (!ret.second)
			throw KokkoException(shadesCSVfile + ": Duplicate brand name in column " +
					     to_string(col_cnt + 1) + " on line " + to_string(line_cnt));
		    // Save the iterator as a reference to the brand
		    brandList.push_back(ret.first->second);
		}
	    } else {
		if (col_cnt == 0) {
		    curImage = refImages.find(cell);
		    if (curImage == refImages.end())
			// This row is for an image not in the Face Skin database -- just skip it
			break;

		} else if (cell.length() > 0) {
		    if ((size_t)col_cnt > brandList.size())
			throw KokkoException(shadesCSVfile + ": Shade name in column " +
					     to_string(col_cnt + 1) + " on line " + to_string(line_cnt) +
					     " but no brand name present in column header");
		    
		    auto br = brandList.at(col_cnt - 1);
		    ShadeTable::iterator sh = shades.end();	    // No matching entry found yet
		    auto range = shades.equal_range(cell);
		    for (auto it = range.first; it != range.second; ++it) {
			if (it->second->getBrandID() == br) {
			    sh = it;
			    break;
			}
		    }
		    if (sh == shades.end()) {
			ShadePtr newc = make_shared<Shade>(br, cell);
			sh = shades.emplace(cell, newc);
		    }
		    // Save a pointer to the shade
		    exemplar_shades.push_back(sh->second);
		}
	    }
	    col_cnt++;
	}
	if (header_line) {
	    header_line = false;
	} else if (curImage != refImages.end() && exemplar_shades.size() > 0)
	    curImage->second->setShades(exemplar_shades);
    }
    shadef.close();
}


void ExemplarDB::listDB()
{
    for (auto ri = refImages.begin(), rend = refImages.end(); ri != rend; ++ri) {
	cout << "Exemplar '" << ri->first << ":\n";
	ExemplarPtr ex = ri->second;
	cout << "\t# Pixels = " << ex->getPixels().getPixelCnt() << "\n\tShades =";
	for (auto si = ex->getShades().begin(), send = ex->getShades().end(); si != send; ++si)
	    cout << ' ' << (*si)->getShadeCode();
	cout << endl;
    }
}


// Kuiper -- calculate the Kuiper "distance" for two data sets
//
// This version of Kuiper operates off two arrays of frequency counts; the
// element v1[i] is the count of the number of occurences of the value 'i'
// in the data set. This representation requires far less memory and is much
// faster to compare; 160x improvement was seen in testing. This version
// also uses only integer operations in the loop which improve the consistency
// of results reported.
//
// The return value is always in the range [0.0, 1.0]; 0.0 means the two data
// sets were identical; 1.0 means they are uncorrelated.
//
// To understand how this algorithm works, refer to:
//	venus/trunk/Kuiper/main.cpp
// That file has multiple versions of the Kuiper algorithm and describes how
// how each version works.

static double KuiperCounts(const unsigned v1[], const unsigned v2[], int maxVal)
{
    unsigned n1 = 0, n2 = 0;		// Number of elements being compared
    
    // Find the total number of values represented by each counts array
    for (auto i = 0; i <= maxVal; i++) {
	n1 += v1[i];
	n2 += v2[i];
    }
    if (n1 == 0 || n2 == 0)
	return 0.0;
    
    uint_least64_t dplus = 0, dminus = 0;
    uint_least64_t j1_scaled = n2, j2_scaled = n1;
    unsigned c1 = 0, c2 = 0;		// count of how many occurences of val
    int d1 = -1, d2 = -1;		// the values being compared
    
    for (;;) {
	while (c1 == 0) {		// advance to the next data value
	    if (d1 >= maxVal)
		goto done;		// no more data values
	    d1++;			// next data value
	    c1 = v1[d1];		// # of occurences of this data value
	}
	while (c2 == 0) {
	    if (d2 >= maxVal)
		goto done;		// no more data values
	    d2++;
	    c2 = v2[d2];
	}
	
	unsigned consumed;
	if (d1 < d2)
	    consumed = c1;
	else if (d2 < d1)
	    consumed = c2;
	else
	    consumed = min(c1, c2);
	if (d1 <= d2) {
	    c1 -= consumed;
	    j1_scaled += consumed * n2;
	}
	if (d2 <= d1) {
	    c2 -= consumed;
	    j2_scaled += consumed * n1;
	}
	if (j2_scaled >= j1_scaled) {
	    uint_least64_t dtplus = j2_scaled - j1_scaled;
	    if (dtplus > dplus)
		dplus = dtplus;
	} else {
	    uint_least64_t dtminus = j1_scaled - j2_scaled;
	    if (dtminus > dminus)
		dminus = dtminus;
	}
    }
done:
    return (double)(dplus + dminus) / (n1 * n2);
}



static std::istream& safeGetLine(std::istream& is, std::string& t)
{
    t.clear();
    
    // The characters in the stream are read one-by-one using a std::streambuf.
    // That is faster than reading them one-by-one using the std::istream.
    // Code that uses streambuf this way must be guarded by a sentry object.
    // The sentry object performs various tasks,
    // such as thread synchronization and updating the stream state.
    
    std::istream::sentry se(is, true);
    std::streambuf* sb = is.rdbuf();
    
    for(;;) {
        int c = sb->sbumpc();
        switch (c) {
	    case '\n':
		return is;
	    case '\r':
		if(sb->sgetc() == '\n')
		    sb->sbumpc();
		return is;
	    case EOF:
		// Also handle the case when the last line has no line ending
		if(t.empty())
		    is.setstate(std::ios::eofbit);
		return is;
	    default:
		t += (char)c;
        }
    }
}


