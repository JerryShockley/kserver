//
//  UIImage+Match.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Match)

- (void) imageToAnalyze;
- (CGRect) findChart;
- (CGRect) findFace;
- (NSString*) getRecommendations;

// TODO:  sample method, remove eventually
-(UIImage*)scaleToCGSize:(CGSize)size;


@end
