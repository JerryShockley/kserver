//
//  KokkoPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoPageControlViewController.h"

@interface KokkoPageControlViewController() <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pvc;
@property (nonatomic, strong) UIButton *getStartedButton;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSInteger intervalGettingStartedSeconds;

@end


@implementation KokkoPageControlViewController

#pragma mark - Accessors

- (UIPageViewController *)pvc
{
    if (!_pvc) {
        self.pvc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                 options:nil];
        _pvc.dataSource = self;
        _pvc.delegate = self;
        _pvc.view.autoresizingMask = UIViewAutoresizingNone;
        _pvc.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-66);
        [_pvc setViewControllers:@[[self viewControllerAtIndex:0]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    return _pvc;
}

- (UIButton*)getStartedButton
{
    if (!_getStartedButton) {
        self.getStartedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_getStartedButton setTitle:@"Get Started" forState:UIControlStateNormal];
        _getStartedButton.frame = CGRectMake(0, self.pvc.view.frame.size.height, self.view.frame.size.width, 66);
        [_getStartedButton addTarget:self action:@selector(tapGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getStartedButton;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentIndex = 0;
    self.intervalGettingStartedSeconds = 10;
    
    // Create the data model
    self.pageTitles = @[@"Use your cell phone camera to find the perfect foundation for you.",
                        @"We match you skin tone to the ideal shade from our trusted brands.",
                        @"Just hold our Color Chart next to your face.  Use this App to take your picture -- that's it!"];
    self.pageImages = @[@"Page1.png", @"Page2.png", @"Page3.png"];
    
    // Attach the page view controller
    [self.view addSubview:self.pvc.view];
    [self.view addSubview:self.getStartedButton];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (void)initTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.intervalGettingStartedSeconds
                                                  target:self
                                                selector:@selector(scrollingTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Actions

- (void)tapGetStarted:(id)sender
{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"KokkoUIImagePickerController"] animated:YES];
}


#pragma mark - Page controls

- (void) scrollingTimer:(NSTimer*)timer {
    NSLog(@"Timer fired");
    self.currentIndex = ([self presentationIndexForPageViewController:self.pvc]+1)%3;
    [self.pvc setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
}

- (KokkoPageContentViewController *)viewControllerAtIndex:(NSInteger)index {
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    self.currentIndex = viewController.view.tag;
    return [self viewControllerAtIndex:self.currentIndex-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.currentIndex = viewController.view.tag;
    return [self viewControllerAtIndex:self.currentIndex+1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return self.currentIndex;
}


#pragma mark - UIPageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    [self.timer invalidate];
    [self initTimer];
}


@end
