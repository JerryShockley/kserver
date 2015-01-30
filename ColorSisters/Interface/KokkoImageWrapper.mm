//
//  KokkoImageWrapper.mm
//  ColorSisters
//
//  Created by Scott Trappe on 1/28/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//
// This is just a thin Objective-C wrapper around the C++ class KokkoImage.
// At the moment, it only exports the subset of the class used in the App;
// it also (mostly) hides the SharedImageResources global variable. This could
// be made to better fit the Objective-C paradigm; we could create a separate
// wrapper class for SharedImageResources as well. It should act as the
// factory for KokkoImage objects which would then be automatically tied to
// the global resources.

#import "KokkoImageWrapper.h"
#import "kokko_image.h"
#import	"opencv2/opencv.hpp"
#import "opencv2/highgui/ios.h"

// Private Global Variables
static SharedImageResources AnalysisDB;

// Forward references
static	cv::Mat UIImageToMat8UC3(const UIImage* image);
inline	CGRect cvRectToCGRect(const cv::Rect& inRect)
{
    return CGRectMake(inRect.x, inRect.y, inRect.width, inRect.height);
}


@implementation KokkoImageWrapper {
    KokkoImage *kImage;
}

// initOneTime is not a wrapper around the KokkoImage class, it really
// wraps the SharedImageResources class, and it changes the interface as
// well, taking a dictionary of resources as an argument. This seemed like
// a better model for Objective-C; it's easy to extend the interface by
// just adding additional key-value pairs to the dictionary.

+ (bool) initOneTime:(NSDictionary *)resources
{
    @try {
	AnalysisDB.init([resources[@"chart-config"] UTF8String],
			[resources[@"face-model"] UTF8String]);
	AnalysisDB.loadExemplarDB([resources[@"exemplar-DB"] UTF8String],
				  [resources[@"face-shades-DB"] UTF8String]);
    }
    @catch (NSException *exception) {
	NSLog(@"exception %@", exception);
	return false;			// signal to caller init failed
    }
    return true;			// init succeeded
}


+ (void) setIntermediateFilePath:(NSString *)path
{
    AnalysisDB.setIntermediateFilePath([path UTF8String]);
}


- (id) initWithImage:(UIImage *)imageToAnalyze
{
    return [self initWithImage:imageToAnalyze named:@""];
}

- (id) initWithImage:(UIImage *)imageToAnalyze named:(NSString *)name
{
    kImage = new KokkoImage(&AnalysisDB,
			    UIImageToMat8UC3(imageToAnalyze),
			    [name UTF8String]);
    return self;
}


- (CGRect) findChart
{
    CGRect chart;
    
    @try {
	chart = cvRectToCGRect(kImage->getChartRect());
    }
    @catch (NSException *exception) {
	NSLog(@"exception %@", exception);
	// Signal to caller that no chart was found is a zero-sized rectangle
	chart = CGRectMake(0, 0, 0, 0);
    }
    @finally {
	return chart;
    }
}


- (CGRect) findFace
{
    CGRect face;
    
    @try {
	face = cvRectToCGRect(kImage->getFaceRect());
    }
    @catch (NSException *exception) {
	NSLog(@"exception %@", exception);
	// Signal to caller that no face was found is a zero-sized rectangle
	face = CGRectMake(0, 0, 0, 0);
    }
    @finally {
	return face;
    }
}


/*
 * The Dictionary returned has brand names as the keys; each value is an
 * immutable array of shade names.
 */
- (NSDictionary *) getRecommendations
{
    NSMutableDictionary *matches = [[NSMutableDictionary alloc] init];
    @try {
	const Recommendations& brshades = kImage->getRecommendations();
	
	for (auto bi = brshades.cbegin(), bend = brshades.cend(); bi != bend; ++bi) {
	    const ShadeList& theShades = bi->second;
	    NSMutableArray *shades = [[NSMutableArray alloc] init];
	    for (auto si = theShades.cbegin(), siend = theShades.cend(); si != siend; ++si) {
		NSString *shadeName = [NSString stringWithUTF8String:(*si)->getShadeCode().c_str()];
		[shades addObject:shadeName];
	    }
	    NSString *brandName = [NSString stringWithUTF8String:bi->first.c_str()];
	    matches[brandName] = [shades copy];	// store immutable list of shades in Brand table
	}
    }
    @catch (NSException *exception) {
	NSLog(@"exception %@", exception);
	// matches will be the empty set, which should be an unambiguous
	// signal to the caller that no matches were found!
    }
    @finally {
	return [matches copy];
    }
}


#pragma mark - Utility functions internal to the interface

static	cv::Mat UIImageToMat8UC3(const UIImage* image)
{
    // mixChannels() takes uses an array to specify the mapping of input
    // channels to output channels. Although declared as a single dimensioned
    // array of integers; the interepretation is really an array of pairs;
    // the first element (lower-indexed) is the channel number in the input
    // array, and the second (index + 1) is the channel number in the output
    // array to copy to. So the array below is saying:
    //	IN-CHAN    OUT-CHAN
    //   0 (R)  ->    2
    //   1 (G)  ->    1
    //   2 (B)  ->    0
    //   3 (A)  -> <not copied>
    const static int rgba2bgr[] = { 0, 2,
	1, 1,
	2, 0 };
    
    cv::Mat rgba;
    UIImageToMat(image, rgba);
    
    // UIImageToMat converts a UIImage into a OpenCV Mat, with 4 channels
    // in the order R, G, B, A. the IA library expects a 3-channel Mat with
    // the channel order B, G, R. mixChannels will fortunately do all the hard
    // work for us.
    cv::Mat bgr(rgba.size(), CV_8UC3);
    mixChannels( &rgba, 1, &bgr, 1, rgba2bgr, 3 );
    return bgr;
}


@end