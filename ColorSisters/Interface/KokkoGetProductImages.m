//
//  KokkoGetProductImages.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoGetProductImages.h"

@implementation KokkoGetProductImages

- (NSBundle *)prodImagesBundle
{
    NSString *prodImagesBundlePath = [[NSBundle mainBundle] pathForResource:@"product-images" ofType:@"bundle"];
    
    if (prodImagesBundlePath != nil && [prodImagesBundlePath length] > 0)
        return [NSBundle bundleWithPath:prodImagesBundlePath];
    NSLog(@"Could not find bundle 'product-images'");
    return nil;
}


- (NSString *)getDescription:(NSBundle *)prodImagesBundle forBrand:(NSString *)brand
{
    NSString *brandDesc = nil;
    
    if (prodImagesBundle != nil) {
        NSString *pathToDesc = [prodImagesBundle pathForResource:@"_line" ofType:@"txt" inDirectory:brand];
        
        if (pathToDesc != nil && [pathToDesc length] > 0) {
            brandDesc = [NSString stringWithContentsOfFile:pathToDesc
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
        }
    }
    return brandDesc;
}


- (NSString *)getProductName:(NSBundle *)prodImagesBundle forBrand:(NSString *)brand withShade:(NSString *)shade
{
    NSString *shadeName = nil;
    
    if (prodImagesBundle != nil) {
        NSString *pathToName = [prodImagesBundle pathForResource:shade ofType:@"txt" inDirectory:brand];
        
        if (pathToName != nil && [pathToName length] > 0) {
            shadeName = [NSString stringWithContentsOfFile:pathToName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
        }
    }
    return shadeName;
}


- (UIImage *)getProductImage:(NSBundle *)prodImagesBundle forBrand:(NSString *)brand withShade:(NSString *)shade
{
    UIImage *prodImage = nil;
    
    if (prodImagesBundle != nil) {
        NSString *pathToImage = [prodImagesBundle pathForResource:shade ofType:@"jpg" inDirectory:brand];
        
        if (pathToImage == nil || [pathToImage length] == 0)
            pathToImage = [prodImagesBundle pathForResource:shade ofType:@"png" inDirectory:brand];
                           if (pathToImage == nil || [pathToImage length] == 0)
                               pathToImage = [prodImagesBundle pathForResource:@"_default" ofType:@"png" inDirectory:brand];
                           if (pathToImage != nil && [pathToImage length] > 0) {
                               prodImage = [UIImage imageWithContentsOfFile:pathToImage];
                               
                               if (prodImage == nil)
                                   NSLog(@"Failed to load image");
                           } else
                           NSLog(@"Failed to find shade %@ for brand %@ inside the bundle", shade, brand);
                           }
                           return prodImage;
                           }

@end
