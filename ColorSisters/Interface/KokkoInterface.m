//
//  KokkoInterface.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoInterface.h"
#import "kokkoProductInfo.h"
#import "KokkoImageWrapper.h"
#import "UIImage+fixOrientation.h"

@implementation KokkoInterface {
    dispatch_queue_t analysisQ;
    bool initDone;
    KokkoImageWrapper *kia;
}


+(KokkoInterface *)sharedInstance
{
    static dispatch_once_t once;
    static KokkoInterface* sharedKokkoInterface = nil;

    dispatch_once(&once, ^{
	sharedKokkoInterface = [[self alloc] init];
	sharedKokkoInterface->analysisQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    });
    return sharedKokkoInterface;
}


/*
 * Start the Imaging Library class
 * load the Imaging Library has a big data set loaded from files
 */
-(void) initImageAnalysis
{
    NSDictionary *resources = @{@"chart-config" : @[@"chart_v16_ini", @"cht" ],
				@"face-model" : @[@"haarcascade_frontalface_default", @"xml"],
				@"exemplar-DB" : @[@"FacePixels.fpdb", @"txt"],
				@"face-shades-DB" : @[@"FaceShades", @"csv"]};
    dispatch_async(analysisQ, ^{
	if (initDone)
	    return;		    // only initialize once
	NSLog(@"KokkoInterface initImageAnalysis started Grand Central Dispatch");
	NSMutableDictionary *rsrcs = [[NSMutableDictionary alloc] init];
	for (NSString *key in [resources allKeys]) {
	    NSArray *resource = resources[key];
	    rsrcs[key] = [[NSBundle mainBundle] pathForResource:resource[0] ofType:resource[1]];
	}
	[KokkoImageWrapper initOneTime:rsrcs];
	
#if TARGET_IPHONE_SIMULATOR
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
							     NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//make a file name to write the data to using the documents directory:
	NSLog(@"Debug files will be stored in: '%@'", documentsDirectory);
	// Only generate debug output if running on the simulator
	NSString *outFilePath = [documentsDirectory stringByAppendingString:@"/"];
	[KokkoImageWrapper setIntermediateFilePath:outFilePath];
#endif
	initDone = true;
	NSLog(@"KokkoInterface initImageAnalysis DONE");
    });
}


#pragma mark - Group all the activity into one call

- (void)analyzeImage:(UIImage *)imageToAnalyze
            delegate:(id <KokkoInterfaceDelegate>)delegate
{
    static int imageCnt = 0;
    
    // Register the recipient of our results
    self.delegate = delegate;
    
    // Construct a unique image name for each analysis run
    NSString *imageName = [NSString stringWithFormat:@"CSimage%d", ++imageCnt];
    NSLog(@"KokkoInterface: analyzeImage queuing");
    
    dispatch_async(analysisQ, ^{
	NSLog(@"KokkoInterface analyzeImage STARTED");
	if (self.delegate == nil)
	    return;			    // user cancelled the analysis
	kia = [[KokkoImageWrapper alloc] initWithImage:[imageToAnalyze orientImageUp]
						 named:imageName];
	
	if (self.delegate == nil)
	    return;			    // user cancelled the analysis
	// Get the chart location in the image
	CGRect chartRect = [kia findChart];
	
	if (self.delegate == nil)
	    return;			    // user cancelled the analysis
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundChartRect:)]) {
	    //        [self.delegate kokkoInterface:self foundChartRect:CGRectMake(10,100,20,20)];
	    [self.delegate kokkoInterface:self foundChartRect:chartRect];
	}
	
	// Find the face in the image
	CGRect faceRect = [kia findFace];
	
	if (self.delegate == nil)
	    return;			    // user cancelled the analysis
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundFaceRect:)]) {
	    //        [self.delegate kokkoInterface:self foundFaceRect:CGRectMake(100,200,20,20)];
	    [self.delegate kokkoInterface:self foundFaceRect:faceRect];
	}
	
	// Run the matching routine
	NSDictionary *shadeMatches = [kia getRecommendations];
	
	// Return result to the delegate
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundShadeMatches:)]) {
	    [self.delegate kokkoInterface:self foundShadeMatches:shadeMatches];
	}
	NSLog(@"KokkoInterface analyzeImage DONE");
    });
    NSLog(@"KokkoInterface: analyzeImage -- done queuing");
}

- (void)cancelAnalysis
{
    self.delegate = nil;
    // In a background thread world, kill the thread. Here we just release
    // the memory for the KokkoImage object.
    kia = nil;
}


@end
