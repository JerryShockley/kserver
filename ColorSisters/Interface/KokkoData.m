//
//  KokkoData.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoData.h"

@implementation KokkoData

/// path to image bundle
NSString *imageBundlePath = @"product_images.bundle";



- (void) logRecommendationsDictionary:(NSDictionary *) shadeMatches {

    /// looks like 'product_images.bundle/'
    NSString *pathDir = [NSString stringWithFormat:@"%@%@", imageBundlePath, @"/"];  // an incredible amount of code to append a '/', but generally safer than expecting it to be in the string

    /// looks like 'product_images.bundle/Dior/'
    NSString *pathDirWithBrand;
    
    /// looks like 'product_images.bundle/Dior/100.png'
    NSString *pathDirWithBrandAndImageFile;
    
    // Sort Brands alphabetically
    NSArray *shadeSorted = [[shadeMatches allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    // Iterate over brand and images
    for (NSString *brand in shadeSorted) {
        NSLog(@"# Iterate over sorted Match shades for Brand = %@", brand);
        pathDirWithBrand = [NSString stringWithFormat:@"%@%@%@", pathDir, brand, @"/"];
        
        NSLog(@"  # Iterate through the images within Brand");
        NSLog(@"  %@", pathDirWithBrand);

        NSArray *shadeImageArray = [shadeMatches objectForKey: brand];
        for(NSString *shadeImage in shadeImageArray) {
            
            pathDirWithBrandAndImageFile = [pathDirWithBrand stringByAppendingString:[NSString stringWithFormat:@"%@", shadeImage]];
            NSLog(@"  %@", pathDirWithBrandAndImageFile);
        }
    }
}
@end
