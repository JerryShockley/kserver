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

+ (KokkoInterface*) sharedKokkoInterface;
+ (void) init;

- (void)analyzeImage:(UIImage *)image
            delegate:(id <KokkoInterfaceDelegate>)delegate;
- (NSDictionary *)getRecommendationsUIONLY;

@end



@protocol KokkoInterfaceDelegate <NSObject>

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundFaceRect:(CGRect)faceRect;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundChartRect:(CGRect)chartRect;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface analysisProgress:(CGFloat)progress;
- (void)kokkoInterface:(KokkoInterface *)kokkoInterface foundShadeMatches:(NSDictionary *)shadeMatches;

@end

