//
//  UIImage+Match.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "UIImage+Match.h"

@implementation UIImage (Match)

// TODO  This may not be needed, design is such that we
// extended UIImage using 'category'
- (void) imageToAnalyze {
    
}

- (CGRect) findChart {

    NSLog(@"findChart");
    return CGRectMake(0, 0, 10, 20);  // TODO:   return call to C++ chart
}

- (CGRect) findFace {

    return CGRectMake(0, 0, 5, 15);  // TODO:   return call to C++ face
}

- (NSString*) getRecommendations {
    
    return @"matches";  // TODO:   return call to C++ Recommendations
}

-(UIImage*)scaleToCGSize:(CGSize)size {
    
    // UIKit way to scale a UIImage - demo only
    
    // Creates a bitmap-based graphics context and makes it the current context
    UIGraphicsBeginImageContext(size);
    
    // Draws the attributed string inside the specified bounding rectangle in the current graphics context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Returns an image based on the contents of the current bitmap-based graphics context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Removes the current bitmap-based graphics context from the top of the stack
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
