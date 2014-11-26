//
//  KokkoInterface.m
//  ColorSisters
//
//  Created by Rob Chohan on 11/24/14.
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
@end
