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

@interface KokkoInterface ()

@property (nonatomic) bool stopAnalysis;

@end

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
	sharedKokkoInterface->analysisQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    });
    return sharedKokkoInterface;
}


/*
 * Start the Imaging Library class
 * load the Imaging Library has a big data set loaded from files
 */
-(void) initImageAnalysis
{
    if (initDone)
	return;		    // only initialize once
    NSDictionary *resources = @{@"chart-config" : @[@"chart_v16_ini", @"cht" ],
				@"face-model" : @[@"haarcascade_frontalface_default", @"xml"],
				@"exemplar-DB" : @[@"FacePixels.fpdb", @"txt"],
				@"face-shades-DB" : @[@"FaceShades", @"csv"]};
    dispatch_async(analysisQ, ^{
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
    self.stopAnalysis = false;
    
    // Construct a unique image name for each analysis run
    NSString *imageName = [NSString stringWithFormat:@"CSimage%d", ++imageCnt];
    NSLog(@"KokkoInterface: analyzeImage queuing");
    
    dispatch_async(analysisQ, ^{
	NSLog(@"KokkoInterface analyzeImage STARTED");
	if (self.stopAnalysis)
	    return;			    // user cancelled the analysis
	kia = [[KokkoImageWrapper alloc] initWithImage:[imageToAnalyze orientImageUp]
						 named:imageName];
	
	if (self.stopAnalysis)
	    return;			    // user cancelled the analysis
	// Get the chart location in the image
	NSValue *chartRect = [NSValue valueWithCGRect: [kia findChart]];
	
	if (self.stopAnalysis)
	    return;			    // user cancelled the analysis
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundChartRect:)]) {
	    [self performSelectorOnMainThread:@selector(foundChart:) withObject:chartRect waitUntilDone:NO];
	}
	
	// Find the face in the image
	NSValue *faceRect = [NSValue valueWithCGRect:[kia findFace]];
	
	if (self.stopAnalysis)
	    return;			    // user cancelled the analysis
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundFaceRect:)]) {
	    [self performSelectorOnMainThread:@selector(foundFace:) withObject:faceRect waitUntilDone:NO];
	}
	
	// Run the matching routine
	NSDictionary *shadeMatches = [kia getRecommendations];
	
	if (self.stopAnalysis)
	    return;			    // user cancelled the analysis
	// Return result to the delegate
	if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundShadeMatches:)]) {
	    [self performSelectorOnMainThread:@selector(foundMatches:) withObject:shadeMatches waitUntilDone:NO];
	}
	kia = nil;				// release analysis object
	NSLog(@"KokkoInterface analyzeImage DONE");
    });
    NSLog(@"KokkoInterface: analyzeImage -- done queuing");
}


- (void)cancelAnalysis
{
    self.stopAnalysis = true;
}

#pragma mark - helper methods to pass results between threads

- (void)foundChart:(NSValue *)chartRect
{
    [self.delegate kokkoInterface:self foundChartRect:[chartRect CGRectValue]];
}

- (void)foundFace:(NSValue *)faceRect
{
    [self.delegate kokkoInterface:self foundFaceRect:[faceRect CGRectValue]];
}

- (void)foundMatches:(NSDictionary *)shadeMatches
{
    [self.delegate kokkoInterface:self foundShadeMatches:shadeMatches];
}


@end
