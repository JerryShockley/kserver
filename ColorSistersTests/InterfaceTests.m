//
//  InterfaceTests.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIImage+Match.h"

@interface InterfaceTests : XCTestCase

@end

@implementation InterfaceTests

UIImage *image = nil;


- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testfindChart {
    CGRect chart = [image findChart];
}

- (void)testfindFace {
    CGRect face = [image findFace];
}

- (void)testgetRecommendations {
    
}

- (void)testScaleToSize {
    
    UIImage *image = [UIImage imageNamed:@"image.jpg"];
    UIImage *scaledImage = [image scaleToCGSize:CGSizeMake(25.0f, 35.0f)];
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