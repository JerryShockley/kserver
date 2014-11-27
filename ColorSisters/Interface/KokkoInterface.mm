//
//  KokkoInterface.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoInterface.h"

@implementation KokkoInterface

KokkoInterface* kokkoClass = [KokkoInterface sharedKokkoInterface];


+(KokkoInterface*)sharedKokkoInterface {
    static KokkoInterface* sharedKokkoInterface = nil;
    if(!sharedKokkoInterface) {
        sharedKokkoInterface = [[KokkoInterface alloc] init];
    }
    return sharedKokkoInterface;
}

/*
 * Start the Imaging Library class
 * load the Imaging Library has a big data set loaded from files
 */
+(void) init{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"KokkoInterface async via Grand Central Dispatch");
        
        NSLog(@"KokkoInterface init in didFinish() = %p", kokkoClass);
    });
}

- (void) initWithImage:(UIImage *)imageToAnalyze {
    
    @try {
        // TODO:   return call to C++ imageToAnalyze
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        
    }
}

- (CGRect *) findChart {

    CGRect *chart;
    
    @try {
        // TODO:   return call to C++ chart
        // chart =
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        return chart;
    }
}

- (CGRect *) findFace {
    
    CGRect *face;
    
    @try {
        // TODO:   return call to C++ findFace
        // face =
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        return face;
    }
}

/**
 * the data returned is a list of lists: the top level list is the brands, and each element in that list has a list of matching shades.
 * an NSArray, with each element being a <brand-name, Array> pair.
 */
- (NSArray*) getRecommendations {
    
    NSArray *recommendations;
    
    @try {
        // TODO:   return call to C++ Recommendations
        // recommendations =
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
    @finally {
        return recommendations;
    }

}
@end
