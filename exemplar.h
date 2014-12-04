//
//  exemplar.h
//  imagedb
//
//  Created by Scott Trappe on 8/27/14.
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#ifndef __imagedb__exemplar__
#define __imagedb__exemplar__

#include <iostream>
#include <memory>
#include <string>
#include <list>
#include <vector>
#include <set>
#include <map>
#include <unordered_map>
#include "skinpixels.h"

typedef std::string ImageID;

class Brand {
public:
    Brand(const std::string& brandName) : name_(brandName) {}
    
    const std::string&	    getName() const	    { return name_; }
    
private:
    std::string	    name_;
    // In the future may add additional information about the brand,
    // such as web sites where the brand can be purchased
};

typedef	std::shared_ptr<Brand>   BrandPtr;

typedef	std::map<std::string, BrandPtr> BrandTable;

class Shade {
public:
    Shade(const BrandPtr brand,
	  const std::string& code,
	  const std::string& desc = "") : brand_(brand), code_(code), desc_(desc) {}
    
    const std::string&	    getShadeCode() const    { return code_; }
    const std::string&	    getShadeDesc() const    { return desc_; }
    const std::string&	    getBrandName() const    { return brand_->getName(); }
    const Brand&	    getBrand() const	    { return *brand_; }
    const BrandPtr	    getBrandID() const	    { return brand_; }
    
private:
    BrandPtr	    brand_;		    // brand this shade is part of
    std::string	    code_;		    // code used to name shade, e.g., "NW40", "C3", "300"
    std::string	    desc_;		    // description of color, e.g., "Classic Ivory"
};

typedef	std::shared_ptr<Shade> ShadePtr;
typedef std::shared_ptr<const Shade> CShadePtr;
typedef std::unordered_multimap<std::string, ShadePtr> ShadeTable;
typedef std::list<CShadePtr> ShadeList;

class Exemplar {
public:
    Exemplar(ImageID ID,
	     const SkinPixels& pixels,
	     const ShadeList& shades = ShadeList()) :
    name_(ID), pixels_(pixels), shades_(shades) {}
    
    const ImageID&	getID() const	    { return name_; }
    const ShadeList&	getShades() const   { return shades_; }
    const SkinPixels&	getPixels() const   { return pixels_; }
    
    void		setShades(const ShadeList& shades) { shades_ = shades; }
    
private:
    ImageID	name_;
    SkinPixels	pixels_;
    ShadeList	shades_;
};

typedef std::shared_ptr<const Exemplar> ExemplarPtr;
typedef std::map<float, ExemplarPtr> FaceRank;
typedef std::set<std::string> BrandSet;
typedef std::map<std::string, ShadeList> Recommendations;

class ExemplarDB {
public:
    ExemplarDB() : nEvery(5), maxFaces(maxFacesToRank), maxShades(maxShadeRecsPerBrand) {}
    ExemplarDB(const std::string& skinPixelFile, const std::string& shadeDBFile = "") :
	nEvery(5), maxFaces(maxFacesToRank), maxShades(maxShadeRecsPerBrand) {
	load(skinPixelFile, shadeDBFile);
    }
    
    void load(const std::string& skinPixelFile, const std::string& shadeDBFile = "");
    
    FaceRank	match(const SkinPixels& pixels);
    FaceRank	match(const std::string& skinPixelFile);
    void	setCompareInterval(int n);
    
    Recommendations	recommend(const FaceRank& matches,  const BrandSet& theseBrands);
    Recommendations	recommend(const FaceRank& matches) { return recommend(matches, BrandSet()); }
    Recommendations	recommend(const SkinPixels& pixels, const BrandSet& theseBrands);
    Recommendations	recommend(const SkinPixels& pixels) { return recommend(pixels, BrandSet()); }
    void	setMaxFaces(unsigned n);
    void	setMaxRecShades(unsigned n);
    void	listDB();
    
private:
    typedef std::map<ImageID, std::shared_ptr<Exemplar>> ImageTable;
    
    void	loadSkinPixels(const std::string&  skinPixelFile);
    void	loadShades(const std::string& shadeCSVfile);
    
    ImageTable refImages;
    BrandTable brands;
    ShadeTable shades;
    unsigned nEvery;			// interval between pixel values to compare
    unsigned maxFaces;			// maximum # of faces to use in making recommendations
    unsigned maxShades;			// maximum # of shades to report per brand in recommendations
    static const unsigned maxFacesToRank = 3;
    static const unsigned maxShadeRecsPerBrand = 3;
};

#endif /* defined(__imagedb__exemplar__) */
