//
//  KokkoCameraOverlayController.m
//  ColorSisters
//
//  Created by Paul Lettieri on 1/20/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//

#import "KokkoCameraOverlayController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface KokkoCameraOverlayController ()

@property (nonatomic, strong) UIView *topRect;
@property (nonatomic, strong) UIButton *shutterButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *rollButton;


@end

@implementation KokkoCameraOverlayController


#pragma mark - Accessors

- (UIView *)topRect
{
    if (!_topRect) {
        self.topRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _topRect.backgroundColor = [UIColor whiteColor];
    }
    return _topRect;
}

- (UIButton *)shutterButton
{
    if (!_shutterButton) {
        self.shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_shutterButton setImage:[UIImage imageNamed:@"ShutterRelease"] forState:UIControlStateNormal];
        [_shutterButton setImage:[UIImage imageNamed:@"ShutterReleaseDown"] forState:UIControlStateHighlighted];
        [_shutterButton addTarget:self action:@selector(tapShutter:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shutterButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(tapCancel:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cancelButton;
}

- (UIButton *)flipButton
{
    if (!_flipButton) {
        self.flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flipButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_flipButton setTintColor:[UIColor whiteColor]];
        [_flipButton setImage:[UIImage imageNamed:@"Flip"] forState:UIControlStateNormal];
        [_flipButton addTarget:self action:@selector(tapFlip:) forControlEvents:UIControlEventTouchUpInside];
        _flipButton.hidden = ! ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
                                && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]
                                && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]);
    }
    return _flipButton;
}

- (UIButton *)rollButton
{
    if (!_rollButton) {
        self.rollButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rollButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_rollButton addTarget:self action:@selector(tapRoll:) forControlEvents:UIControlEventTouchUpInside];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // Chooses the photo at the last index
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[alAsset thumbnail]];
                    [_rollButton setImage:latestPhoto forState:UIControlStateNormal];
                    
                    // Stop the enumerations
                    *stop = YES; *innerStop = YES;
                }
            }];
        } failureBlock: ^(NSError *error) {
            
        }];
    }

    
    return _rollButton;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.topRect];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.shutterButton];
    [self.view addSubview:self.flipButton];
    [self.view addSubview:self.rollButton];

    // Constrain subviews
    const CGFloat shutterScale = 0.25;
    const CGFloat secondaryScale = 0.18;


    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shutterButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:-20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shutterButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:shutterScale
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shutterButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:shutterScale
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shutterButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rollButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.shutterButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rollButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:.375
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rollButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:secondaryScale
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rollButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:secondaryScale
                                                           constant:0]];
    

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flipButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.shutterButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flipButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.625
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flipButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:secondaryScale
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flipButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:secondaryScale
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:25]];

    
}


#pragma mark - Actions

- (void)tapShutter:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraOverlayControllerTakePicture:)]) {
        [self.delegate cameraOverlayControllerTakePicture:self];
    }
}

- (void)tapCancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraOverlayControllerCancel:)]) {
        [self.delegate cameraOverlayControllerCancel:self];
    }
}

- (void)tapFlip:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraOverlayControllerFlip:)]) {
        [self.delegate cameraOverlayControllerFlip:self];
    }
}

- (void)tapRoll:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraOverlayControllerRoll:)]) {
        [self.delegate cameraOverlayControllerRoll:self];
    }
}


@end
