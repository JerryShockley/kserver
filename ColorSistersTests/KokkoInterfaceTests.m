//
//  KokkoInterfaceTests.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KokkoInterface.h"

@interface KokkoInterfaceTests : XCTestCase

@end

@implementation KokkoInterfaceTests
KokkoInterface* kokkoClass;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    kokkoClass = [KokkoInterface sharedKokkoInterface];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testSingleton {
    
    // To verify this test, check the log and see that the pointer address
    // for KokkoInterface is identical from the call in didFinish() & didFinishPickingMedia
    /* e.g, directly from the log from this test
     * ColorSisters[27071:3258787] KokkoInterface init in didFinish() = 0x7fac8bf057a0
     * ColorSisters[27071:3258747] KokkoInterface init in didFinishPickingMedia() = 0x7fac8bf057a0
     */
    
    // Simulatation of the call from within didFinishPickingMedia
    NSLog(@"KokkoInterface init in didFinishPickingMedia() = %p", kokkoClass);

}

- (void)testinitWithImage {
    // TODO:  add test with real images
    UIImage *img;
    [kokkoClass initWithImage:img];
}

- (void)testfindChart {
    CGRect *chart = [kokkoClass findChart];
    NSLog (@"chart = %@", chart);
}

- (void)testfindFace {
    CGRect *face = [kokkoClass findFace];
    NSLog (@"face = %@", face);
}

- (void)testgetRecommendations {
    NSArray *recommendations = [kokkoClass getRecommendations];
    NSLog (@"recommendtions = %@", recommendations[0]);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
