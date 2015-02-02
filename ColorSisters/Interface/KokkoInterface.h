//
//  KokkoInterface.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KokkoInterfaceDelegate;



@interface KokkoInterface : NSObject

@property (nonatomic, weak) id <KokkoInterfaceDelegate> delegate;

+ (KokkoInterface *) sharedInstance;
- (void)initImageAnalysis;			// Should be called once at app init
- (void)analyzeImage:(UIImage *)image
            delegate:(id <KokkoInterfaceDelegate>)delegate;
- (void)cancelAnalysis;

@end



@protocol KokkoInterfaceDelegate <NSObject>

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundFaceRect:(CGRect)faceRect;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundChartRect:(CGRect)chartRect;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface analysisProgress:(CGFloat)progress;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundShadeMatches:(NSDictionary *)shadeMatches;

@end

