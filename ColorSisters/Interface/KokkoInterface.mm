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
	NSLog(@"Debug files will be stored in: '%@'", documentsDirectory);
	
	NSString* faceCascade = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	NSString* chartLayout = [[NSBundle mainBundle] pathForResource:@"chart_v16_ini" ofType:@"cht"];
	NSString* exemplarsDB = [[NSBundle mainBundle] pathForResource:@"FacePixels" ofType:@"fpdb.txt"];
	NSString* faceShadeDB = [[NSBundle mainBundle] pathForResource:@"FaceShades" ofType:@"csv"];
	try {
	    imagePipe.init([chartLayout UTF8String], [faceCascade UTF8String]);
	    imagePipe.loadExemplarDB([exemplarsDB UTF8String], [faceShadeDB UTF8String]);
#if TARGET_IPHONE_SIMULATOR
	    // Only generate debug output if running on the simulator
	    NSString *outFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"image"];
	    imagePipe.setIntermediateFilePath([outFilePath UTF8String]);
#endif
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

- (void) initWithImage:(UIImage *)imageToAnalyze
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
    UIImageToMat(imageToAnalyze, rgba);

    // UIImageToMat converts a UIImage into a OpenCV Mat, with 4 channels
    // in the order R, G, B, A. the IA library expects a 3-channel Mat with
    // the channel order B, G, R. mixChannels will fortunately do all the hard
    // work for us.
    cv::Mat bgr(rgba.size(), CV_8UC3);
    mixChannels( &rgba, 1, &bgr, 1, rgba2bgr, 3 );
    cvImage = bgr;
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

- (CGRect *) findFace
{
    
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

/*
 * The Dictionary returned has brand names as the keys; each value is an
 * immutable array of shade names.
 */
- (NSDictionary *)getRecommendations
{
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
        matches[brandName] = [shades copy];	// store immutable list of shades in Brand table
    }
    
    return [matches copy];	// return immutable Dictionary of brands & shades
}

/*!
 * Hardcoded data for testing User Interface
 */
- (NSDictionary *)getRecommendationsUIONLY
{
    return @{
             @"Dior"        :@[@"301", @"200", @"400"],
             @"L'Oreal"     :@[@"C4", @"N4", @"C5"],
             @"MAC"         :@[@"NC15"],
             @"Maybelline"  :@[@"D4", @"D2"],
             @"Revlon"      :@[@"250", @"240", @"220"],
             };
}


#pragma mark - Group all the activity into one call

- (void)analyzeImage:(UIImage *)image
            delegate:(id <KokkoInterfaceDelegate>)delegate
{
    // Register the recipient of our results
    self.delegate = delegate;
    
    // Initialize
    [self initWithImage:image];
    
    // Bogus call to "found chart"
    //  TODO: This should come from some bit of code that actually has the rectangle
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundChartRect:)]) {
        [self.delegate kokkoInterface:self foundChartRect:CGRectMake(10,100,20,20)];
    }
    
    // Bogus call to "found face"
    //  TODO: This should come from some bit of code that actually has the rectangle
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundFaceRect:)]) {
        [self.delegate kokkoInterface:self foundFaceRect:CGRectMake(100,200,20,20)];
    }
    
    // Run the matching routine
    NSDictionary *shadeMatches = [self getRecommendations];
    
    // Return result to the delegate
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundShadeMatches:)]) {
        [self.delegate kokkoInterface:self foundShadeMatches:shadeMatches];
    }
}


@end
