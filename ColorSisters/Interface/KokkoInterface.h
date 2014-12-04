//
//  KokkoInterface.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoInterface : NSObject
+ (KokkoInterface*) sharedKokkoInterface;
+ (void) init;
- (void) initWithImage:(UIImage *)imageToAnalyze;
- (CGRect *) findChart;
- (CGRect *) findFace;
- (NSDictionary *) getRecommendations;
@end
