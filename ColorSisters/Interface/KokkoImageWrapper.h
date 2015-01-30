//
//  KokkoImageWrapper.h
//  ColorSisters
//
//  Created by Scott Trappe on 1/28/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//

#ifndef ColorSisters_kokkoImageWrapper_h
#define ColorSisters_kokkoImageWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KokkoImageWrapper : NSObject

+ (bool) initOneTime:(NSDictionary *)resources;
+ (void) setIntermediateFilePath:(NSString *)path;
- (id) initWithImage:(UIImage *)imageToAnalyze;
- (id) initWithImage:(UIImage *)imageToAnalyze named:(NSString *)name;
- (CGRect) findChart;
- (CGRect) findFace;
- (NSDictionary *) getRecommendations;

@end

#endif
