//
//  KokkoInterface.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoInterface.h"
#import "kokkoProductInfo.h"
#import "pipeline.h"
#import	"opencv2/opencv.hpp"
#import "opencv2/highgui/ios.h"

@implementation KokkoInterface {
    cv::Mat cvImage;
}

KokkoInterface* kokkoClass = [KokkoInterface sharedKokkoInterface];

// The C++ class that represents the image pipeline
SkinToneMatcher imagePipe(false);



+(KokkoInterface*)sharedKokkoInterface {
    static KokkoInterface* sharedKokkoInterface = nil;
    if(!sharedKokkoInterface) {
        sharedKokkoInterface = [[KokkoInterface alloc] init];
    }
    return sharedKokkoInterface;
}

/*
 * Start the Imaging Library class
 * load the Imaging Library has a big data set loaded from files
 */
+(void) init{
#ifdef	THREADED
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"KokkoInterface async via Grand Central Dispatch");
#endif	// THREADED
	//get the documents directory:
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//make a file name to write the data to using the documents directory:
	NSString *outFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"image"];
	
	NSString* faceCascade = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	NSString* chartLayout = [[NSBundle mainBundle] pathForResource:@"chart_v16_ini" ofType:@"cht"];
	NSString* exemplarsDB = [[NSBundle mainBundle] pathForResource:@"FacePixels" ofType:@"fpdb.txt"];
	NSString* faceShadeDB = [[NSBundle mainBundle] pathForResource:@"FaceShades" ofType:@"csv"];
	try {
	    imagePipe.init([chartLayout UTF8String], [faceCascade UTF8String]);
	    imagePipe.loadExemplarDB([exemplarsDB UTF8String], [faceShadeDB UTF8String]);
	    imagePipe.setIntermediateFilePath([outFilePath UTF8String]);
	}
	catch (KokkoException e) {
	    NSLog(@"Kokko Exception: %s\n", e.get_message().c_str());
	    // need some way to record this exception and prevent app from continuing
	}
        NSLog(@"KokkoInterface init in didFinish() = %p", kokkoClass);
#ifdef	THREADED
    });
#endif	// THREADED
}

- (void) initWithImage:(UIImage *)imageToAnalyze {
    
    UIImageToMat(imageToAnalyze, cvImage);
}

- (CGRect *) findChart {

    CGRect *chart;
    
    @try {
        // TODO:   return call to C++ chart
        // chart =
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        return chart;
    }
}

- (CGRect *) findFace {
    
    CGRect *face;
    
    @try {
        // TODO:   return call to C++ findFace
        // face =
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        return face;
    }
}

/**
 * the data returned is a list of lists: the top level list is the brands, and each element in that list has a list of matching shades.
 * an NSArray, with each element being a <brand-name, Array> pair.
 */
- (NSDictionary *)getRecommendations {
    
    Recommendations brshades;
    try {
	brshades = imagePipe.recommend(cvImage);
    }
    catch (KokkoException e) {
	NSLog(@"Kokko Exception: %s\n", e.get_message().c_str());
	return nil;
    }
	
    NSMutableDictionary *matches = [[NSMutableDictionary alloc] init];
    
    for (auto bi = brshades.cbegin(), bend = brshades.cend(); bi != bend; ++bi) {
	const ShadeList& theShades = bi->second;
	NSMutableArray *shades = [[NSMutableArray alloc] init];
	for (auto si = theShades.cbegin(), siend = theShades.cend(); si != siend; ++si) {
	    NSString *shadeName = [NSString stringWithUTF8String:(*si)->getShadeCode().c_str()];
	    [shades addObject:shadeName];
	}
	NSString *brandName = [NSString stringWithUTF8String:bi->first.c_str()];
	matches[brandName] = [shades copy];		// store immutable list of shades in Brand table
    }

    return [matches copy];
}

- (NSDictionary *)getRecommendationsUIONLY {
    NSArray *dior = [NSArray arrayWithObjects: @"301", @"200", @"400", nil];
    NSArray *loreal = [NSArray arrayWithObjects: @"C4", @"N4", @"C5", nil];
    NSArray *mac = [NSArray arrayWithObjects: @"NC15", nil];
    NSArray *maybelline = [NSArray arrayWithObjects: @"D4", @"D2", nil];
    NSArray *revlon = [NSArray arrayWithObjects: @"250", @"240", @"220", nil];
    NSDictionary *brands = @{@"Dior" : dior, @"L'Oreal" : loreal, @"MAC" : mac, @"Maybelline": maybelline, @"Revlon": revlon};
    return brands;
}

#ifdef FOR_THE_FUTURE
#ifdef SAVE_DEBUG_INFO
// Write out the pixel values if there is no further processing
// or if the debug flag is set.
skin.setImageID([[imageName stringByAppendingString: @".ppm"] UTF8String]);
skin.setFloat(true);
skin.save([[outFilePath stringByAppendingString: @".fpix.txt"] UTF8String]);
skin.sortChans();
#endif // SAVE_DEBUG_INFO

FaceRank matches = imagePipe.matchFaces(skin);

#ifdef SAVE_DEBUG_INFO
std::ofstream myCout([[outFilePath stringByAppendingString: @".iout.txt"] UTF8String]);
// Each line is in the form:
//    K-dist: <Kuiper-distance> <imagename>
for (FaceRank::const_iterator mi = matches.cbegin(), mend = matches.cend(); mi != mend; mi++) {
    myCout << "K-dist: " << mi->first << ' ' << mi->second->getID() << std::endl;
}
#endif // SAVE_DEBUG_INFO

KokkoProductInfo *prodData = [[KokkoProductInfo alloc] initWithContentsOfBundle:@""];
// Each line is of the form:
// Brand: <brand-name> <shade-1> <shade-2> ...
for (auto bi = brshades.cbegin(), bend = brshades.cend(); bi != bend; ++bi) {
#ifdef SAVE_DEBUG_INFO
    myCout << "Brand: " << bi->first;
#endif // SAVE_DEBUG_INFO
    
    const ShadeList& theShades = bi->second;
    NSString *brandName = [NSString stringWithUTF8String:bi->first.c_str()];
    NSString *shadeName = [NSString stringWithUTF8String:(*(theShades.cbegin()))->getShadeCode().c_str()];
    UIImage *prodImage = [prodData getProductImageForBrand:brandName withShade:shadeName];
    if (prodImage != nil) {
	UIImage *displayImage = prodImage;
	NSLog(@"Matched brand '%@' for shade '%@'", brandName, shadeName);
	NSString *desc = [prodData getDescriptionForBrand:brandName];
	if (desc != nil)
	    NSLog(@"Brand description = '%@'", desc);
	NSString *shadedesc = [prodData getProductNameForBrand:brandName withShade:shadeName];
	NSString *prodInfo;
	
	if (shadedesc != nil)
	    NSLog(@"Shade name is '%@'", shadedesc);
	if (desc != nil)
	    prodInfo = desc;
	else
	    prodInfo = brandName;
	if (shadedesc != nil)
	    prodInfo = [prodInfo stringByAppendingFormat:@" %@", shadedesc];
	else
	    prodInfo = [prodInfo stringByAppendingFormat:@" %@", shadeName];
    }
#ifdef SAVE_DEBUG_INFO
    for (auto si = theShades.cbegin(), siend = theShades.cend(); si != siend; ++si)
	myCout << ' ' << (*si)->getShadeCode();
    myCout << std::endl;
#endif // SAVE_DEBUG_INFO
}
#ifdef SAVE_DEBUG_INFO
myCout.close();
#endif // SAVE_DEBUG_INFO

#endif	// FOR_THE_FUTURE

@end
