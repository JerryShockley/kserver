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

@property (nonatomic) BOOL killThread;

@end

@implementation KokkoInterface {
    KokkoImageWrapper *kia;
}

+ (KokkoInterface*)sharedKokkoInterface {
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
    NSDictionary *resources = @{@"chart-config" : @[@"chart_v16_ini", @"cht" ],
                                @"face-model" : @[@"haarcascade_frontalface_default", @"xml"],
                                @"exemplar-DB" : @[@"FacePixels.fpdb", @"txt"],
                                @"face-shades-DB" : @[@"FaceShades", @"csv"]};
#ifdef	THREADED
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"KokkoInterface async via Grand Central Dispatch");
#endif	// THREADED
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
        
#ifdef	THREADED
    });
#endif	// THREADED
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

- (void)analyzeImage:(UIImage *)imageToAnalyze
            delegate:(id <KokkoInterfaceDelegate>)delegate
{
    static int imageCnt = 0;
    
    // Register the recipient of our results
    self.delegate = delegate;
    
    // Give opportunities to kill the thread activity
    self.killThread = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Construct a unique image name for each analysis run
        NSString *imageName = [NSString stringWithFormat:@"CSimage%d", ++imageCnt];
        
        // Construct the image wrapper
        kia = [[KokkoImageWrapper alloc] initWithImage:[imageToAnalyze orientImageUp]
                             named:imageName];
        
        // Get the chart location in the image
        if (!self.killThread) {
            [self performSelectorOnMainThread:@selector(reportChartRect:)
                                   withObject:[NSValue valueWithCGRect:[kia findChart]]
                                waitUntilDone:NO];
        }
        
        // Find the face in the image
        if (!self.killThread) {
            [self performSelectorOnMainThread:@selector(reportFaceRect:)
                                   withObject:[NSValue valueWithCGRect:[kia findFace]]
                                waitUntilDone:NO];
        }
        
        // Run the matching routine
        if (!self.killThread) {
            [self performSelectorOnMainThread:@selector(reportShadeMatches:)
                                   withObject:[kia getRecommendations]
                                waitUntilDone:NO];
        }
        
        // We are done with the image wrapper
        kia = nil;
    });
}

- (void)reportChartRect:(NSValue *)chartRect
{
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundChartRect:)]) {
        [self.delegate kokkoInterface:self foundChartRect:[chartRect CGRectValue]];
    }
}

- (void)reportFaceRect:(NSValue *)faceRect
{
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundFaceRect:)]) {
        [self.delegate kokkoInterface:self foundFaceRect:[faceRect CGRectValue]];
    }
}

- (void)reportShadeMatches:(NSDictionary *)shadeMatches
{
    if ([self.delegate respondsToSelector:@selector(kokkoInterface:foundShadeMatches:)]) {
        [self.delegate kokkoInterface:self foundShadeMatches:shadeMatches];
    }
}

- (void)cancelAnalysis
{
    self.killThread = YES;
    self.delegate = nil;
}


@end
