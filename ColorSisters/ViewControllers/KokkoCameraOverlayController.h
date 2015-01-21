//
//  KokkoCameraOverlayController.h
//  ColorSisters
//
//  Created by Paul Lettieri on 1/20/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraOverlayDelegate;



@interface KokkoCameraOverlayController : UIViewController

@property (nonatomic, weak) id <CameraOverlayDelegate> delegate;

@end



@protocol CameraOverlayDelegate <NSObject>

@optional
- (void)cameraOverlayControllerTakePicture:(KokkoCameraOverlayController*)covc;
- (void)cameraOverlayControllerCancel:(KokkoCameraOverlayController*)covc;
- (void)cameraOverlayControllerFlip:(KokkoCameraOverlayController*)covc;
- (void)cameraOverlayControllerRoll:(KokkoCameraOverlayController*)covc;
@end

