//
//  KokkoPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoPageContentViewController.h"
#import "KokkoPageControlViewController.h"
#import "KokkoUIImagePickerController.h"
#import "KokkoCameraOverlayController.h"


// This constant defines the interval, in seconds, before the launch screen
// will automatically scroll to the next page. Any manual transition to a new
// page will reset the delay.
#define	INTERVAL_BEFORE_AUTO_PAGE_SCROLL    8


@interface KokkoPageControlViewController() <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CameraOverlayDelegate>

@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (nonatomic, strong) UIPageViewController *pvc;
@property (nonatomic, strong) UIButton *getStartedButton;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL comingBack;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) KokkoCameraOverlayController *covc;

@property (nonatomic, readonly) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, readonly) UIImagePickerControllerCameraDevice cameraDevice;

@end



@implementation KokkoPageControlViewController

#pragma mark - Accessors

- (CGFloat)buttonHeight
{
    return (self.view.frame.size.height<568) ? 30 : 80;
}

- (UIPageViewController *)pvc
{
    if (!_pvc) {
        self.pvc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                 options:nil];
        _pvc.dataSource = self;
        _pvc.delegate = self;
        _pvc.view.autoresizingMask = UIViewAutoresizingNone;
        _pvc.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-self.buttonHeight);
        [_pvc setViewControllers:@[[self viewControllerAtIndex:0]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    return _pvc;
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        _imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (KokkoCameraOverlayController*)covc
{
    if (!_covc) {
        self.covc = [[KokkoCameraOverlayController alloc] init];
        _covc.delegate = self;
    }
    return _covc;
}

- (UIButton*)getStartedButton
{
    if (!_getStartedButton) {
        self.getStartedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_getStartedButton setTitle:@"Get Started" forState:UIControlStateNormal];
        _getStartedButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _getStartedButton.frame = CGRectMake(0, self.pvc.view.frame.size.height, self.view.frame.size.width, self.buttonHeight);
        _getStartedButton.backgroundColor = [UIColor blackColor];
        [_getStartedButton addTarget:self action:@selector(tapGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getStartedButton;
}

- (UIImagePickerControllerSourceType)sourceType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *storedSourceType = [defaults objectForKey:@"lastImagePickerSourceType"];
    
    if (storedSourceType) {
        return (UIImagePickerControllerSourceType)[storedSourceType integerValue];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return UIImagePickerControllerSourceTypeCamera;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return 0;
}

- (UIImagePickerControllerCameraDevice)cameraDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *storedCameraDevice = [defaults objectForKey:@"lastCameraDevice"];
    
    if (storedCameraDevice) {
        // Use whatever we had last time, if available
        return (UIImagePickerControllerCameraDevice)[storedCameraDevice integerValue];
    }
    else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        // Else selfie is preferred
        return UIImagePickerControllerCameraDeviceFront;
    } else {
        return UIImagePickerControllerCameraDeviceRear;
    }
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentIndex = 0;
    
    // Create the data model
    self.pageTitles = @[@"Use your cell phone camera to find the perfect foundation for you.",
                        @"We match you skin tone to the ideal shade from our trusted brands.",
                        @"Just hold our Color Chart next to your face.  Use this App to take your picture -- that's it!"];
    self.pageImages = @[@"Page1.png", @"Page2.png", @"Page3.png"];
    
    // Attach the page view controller
    [self.view addSubview:self.pvc.view];
    [self.view addSubview:self.getStartedButton];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.comingBack) {
        self.comingBack = NO;
        [self showImagePickerAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initTimer];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.timer invalidate];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Actions

- (void)initTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL_BEFORE_AUTO_PAGE_SCROLL
                                                  target:self
                                                selector:@selector(scrollingTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)tapGetStarted:(id)sender
{
    [self showImagePickerAnimated:YES];
}

- (void)showImagePickerAnimated:(BOOL)animated
{
    [self switchToSourceType:self.sourceType];
    [self presentViewController:self.imagePicker animated:animated completion:nil];
}

- (void)hideImagePickerAnimated:(BOOL)animated
{
    [self dismissViewControllerAnimated:animated completion:^{
        // After dismissal, destroy the image picker and its view overlay
        self.imagePicker = nil;
        self.covc = nil;
    }];
}

- (void)showSelectedImage:(UIImage *)image
{
    self.comingBack = YES;

    KokkoUIImagePickerController *pvc = [[KokkoUIImagePickerController alloc] init];
    pvc.image = image;
    [self.navigationController pushViewController:pvc animated:NO];
}

- (void)switchToSourceType:(UIImagePickerControllerSourceType)sourceType
{
    // Make the change
    self.imagePicker.sourceType = sourceType;

    // Record for later use
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(sourceType) forKey:@"lastImagePickerSourceType"];

    // Additional setup when set to camera
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // Pick which camers
        [self switchToCameraDevice:self.cameraDevice];
        
        // Flash messes with the image processing, so turn it off
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        // Present custom controls for the camera
        //  --> Includes a small delay to allow for the above sourceType
        //      change to take effect before the overlay is assigned
        self.imagePicker.showsCameraControls = NO;
        [self.imagePicker performSelector:@selector(setCameraOverlayView:) withObject:self.covc.view afterDelay:0.1];
    }
}

- (void)switchToCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice
{
    // Make the change
    self.imagePicker.cameraDevice = cameraDevice;
    
    // Record for later use
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(cameraDevice) forKey:@"lastCameraDevice"];
}


#pragma mark - Image Picker delegate

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image.imageOrientation != UIImageOrientationUp) {
        NSLog(@"Original image orientation is %ld--adjust before use",
              (long)image.imageOrientation);
    }
    
    [self showSelectedImage:image];
    [self hideImagePickerAnimated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self switchToSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self hideImagePickerAnimated:YES];
    }
}


#pragma mark - Camera Overlay Delegate

- (void)cameraOverlayControllerCancel:(KokkoCameraOverlayController *)covc
{
    [self hideImagePickerAnimated:YES];
}

- (void)cameraOverlayControllerTakePicture:(KokkoCameraOverlayController *)covc
{
    [self.imagePicker takePicture];
}

- (void)cameraOverlayControllerRoll:(KokkoCameraOverlayController *)covc
{
    [self switchToSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)cameraOverlayControllerFlip:(KokkoCameraOverlayController *)covc
{
    if (self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        [self switchToCameraDevice:UIImagePickerControllerCameraDeviceFront];
    } else {
        [self switchToCameraDevice:UIImagePickerControllerCameraDeviceRear];
    }
}


#pragma mark - Page controls

- (void)scrollingTimer:(NSTimer*)timer
{
    NSLog(@"Timer fired");
    self.currentIndex = ([self presentationIndexForPageViewController:self.pvc]+1) % [self.pageTitles count];
    [self.pvc setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
}

- (KokkoPageContentViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count]) || (index<0)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KokkoPageContentViewController *pageContentViewController = [[KokkoPageContentViewController alloc] init];
    pageContentViewController.image = [UIImage imageNamed:self.pageImages[index]];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.view.tag = index;
    
    return pageContentViewController;
}


#pragma mark - UIPageViewControllerDataSource Protocol

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    self.currentIndex = viewController.view.tag;
    return [self viewControllerAtIndex:self.currentIndex-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    self.currentIndex = viewController.view.tag;
    return [self viewControllerAtIndex:self.currentIndex+1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentIndex;
}


#pragma mark - UIPageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    // Any manual page transition resets the timer
    [self.timer invalidate];
    [self initTimer];
}


@end
