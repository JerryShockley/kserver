//
//  KokkoGetProductImages.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoProductInfo.h"

@implementation KokkoProductInfo {
    NSBundle *prodImagesBundle;
}

- (id)initWithContentsOfBundle:(NSString *)bundleFilePath
{
    if (self = [super init]) {
	if (bundleFilePath != nil && [bundleFilePath length] > 0)
	    prodImagesBundle = [NSBundle bundleWithPath:bundleFilePath];
	else {
	    NSLog(@"Could not find bundle '%@'", bundleFilePath);
	    self = nil;
	}
    }
    return self;
}


- (NSString *)getDescriptionForBrand:(NSString *)brand
{
    NSString *brandDesc = nil;
    NSString *pathToDesc = [prodImagesBundle pathForResource:@"_line" ofType:@"txt" inDirectory:brand];
        
    if (pathToDesc != nil && [pathToDesc length] > 0) {
	brandDesc = [NSString stringWithContentsOfFile:pathToDesc
					      encoding:NSUTF8StringEncoding
						 error:NULL];
    }
    return brandDesc;
}


- (NSString *)getProductNameForBrand:(NSString *)brand withShade:(NSString *)shade
{
    NSString *shadeName = nil;
    NSString *pathToName = [prodImagesBundle pathForResource:shade ofType:@"txt" inDirectory:brand];
    
    if (pathToName != nil && [pathToName length] > 0) {
	shadeName = [NSString stringWithContentsOfFile:pathToName
					      encoding:NSUTF8StringEncoding
						 error:NULL];
    }
    return shadeName;
}


- (UIImage *)getProductImageForBrand:(NSString *)brand withShade:(NSString *)shade
{
    UIImage *prodImage = nil;
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
    return prodImage;
}

@end
