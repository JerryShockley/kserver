//
//  UIImage+fixOrientation.m
//  ColorSisters
//
//  Created by Scott Trappe on 1/8/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//
//  The orientImageUp method was posted to StackOverflow by an0 on 5/16/2012:
//  https://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload/10611036#

#import "UIImage+fixOrientation.h"

@implementation UIImage (fixOrientation)

- (UIImage *) orientImageUp
{
    if (self.imageOrientation == UIImageOrientationUp)
	return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
