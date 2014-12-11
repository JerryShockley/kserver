//
//  KokkoData.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoData.h"

@implementation KokkoData

- (void) logRecommendationsDictionary:(NSDictionary *) shadeMatches {
    
    NSArray *shadeSorted = [[shadeMatches allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *brand in shadeSorted) {
        NSLog(@"Brand = %@", brand);
        
        NSArray *shadeImageArray = [shadeMatches objectForKey: brand];
        
        for(NSString *shadeImage in shadeImageArray) {
            NSLog(@"  %@", shadeImage);
        }
    }
}
@end
