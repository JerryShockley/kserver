//
//  KokkoProductInfo.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoProductInfo : NSObject
- (id)initWithContentsOfBundle:(NSString *)pathToBundle;
- (NSString *)getDescriptionForBrand:(NSString *)brand;
- (NSString *)getProductNameForBrand:(NSString *)brand withShade:(NSString *)shade;
- (UIImage *)getProductImageForBrand:(NSString *)brand withShade:(NSString *)shade;

@end
