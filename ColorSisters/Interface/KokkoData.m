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



/*!
 * Pass in the entire NSDictionary, parse and log the components
 * @returns void
 */
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

/*!
 * Pass in the entire NSDictionary
 * @returns NSArray which is used to the set the data rows for the UITableView
 */
- (NSArray *) setRecommendationsArray:(NSDictionary *) shadeMatches {
    
    NSMutableArray *retValue = [[NSMutableArray alloc] init];
    
    // Iterate over brand, and create an Array
    for (NSString *brand in shadeMatches) {
        [retValue addObject:brand];
    }
    
    return (NSArray *) retValue;
}


/*!
 *
 * Pass in the entire NSDictionary
 * @returns NSDictionary, with only one key, which is just a slice of the original NSDictionary
 * For use by the UIDetailedTableView
 */
- (NSDictionary *) setRecommendationsArray:(NSDictionary *) shadeMatches :(NSInteger) index {

    // test iterator on shadeMatches
    
    /// looks like 'product_images.bundle/'
    NSString *pathDir = [NSString stringWithFormat:@"%@%@", imageBundlePath, @"/"];  // an incredible amount of code to append a '/', but generally safer than expecting it to be in the string
    
    /// looks like 'product_images.bundle/Dior/'
    NSString *pathDirWithBrand;
    
    /// looks like 'product_images.bundle/Dior/100.png'
    NSString *pathDirWithBrandAndImageFile;
    

    NSArray *values = [shadeMatches allValues];
    NSArray *keys = [shadeMatches allKeys];
    
    NSString *brand = keys[index];
    NSArray *detail = values[index];
    
    NSMutableArray *retValue = [[NSMutableArray alloc] init];
    
    // Iterate over brand, and create an Array
    for (NSString *brand in shadeMatches) {
        
    }
    
    pathDirWithBrand = [NSString stringWithFormat:@"%@%@%@", pathDir, brand, @"/"];
    
    for(NSString *shadeImage in detail) {
        
        pathDirWithBrandAndImageFile = [pathDirWithBrand stringByAppendingString:[NSString stringWithFormat:@"%@", shadeImage]];
        NSLog(@"  %@", pathDirWithBrandAndImageFile);
        [retValue addObject:pathDirWithBrandAndImageFile];
    }

    // New dict based on the ith row
    NSDictionary *dictDetailedRecommendation = [[NSDictionary alloc] initWithObjectsAndKeys:retValue, brand, nil];  // Note the order is values, keys
    return dictDetailedRecommendation;
}

@end
