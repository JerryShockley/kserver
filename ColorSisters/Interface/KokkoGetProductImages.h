//
//  KokkoGetProductImages.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoGetProductImages : NSObject

- (NSBundle *)prodImagesBundle;
- (NSString *)getDescription;
- (NSString *)getProductName;
- (UIImage*)getProductImage;

@end
