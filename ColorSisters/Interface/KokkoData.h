//
//  KokkoData.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KokkoData : NSObject
- (void) logRecommendationsDictionary:(NSDictionary *) shadeMatches;
- (NSArray *) setRecommendationsArray:(NSDictionary *) shadeMatches;
- (NSDictionary *) setRecommendationsArray:(NSDictionary *) shadeMatches :(NSInteger *) index;
@end
