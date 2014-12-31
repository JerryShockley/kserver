//
//  KokkoDetailPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailPageControlViewController.h"

@interface KokkoDetailPageControlViewController ()
@end

@implementation KokkoDetailPageControlViewController
NSString *title;
NSArray *images;

#pragma mark - Managing the detail item

/*!
 * Extract Data passed over from the Segue
 */
- (void)setDetailItem:(NSDictionary *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Detail Item is a dictionary, extract the keys and values into appropriate structures
        title = [self.detailItem allKeys][0];  // extract the 'key', whcih is a string
        images = [self.detailItem allValues][0]; // extract the 'value', which is an array
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the data model
    self.pageTitle = title;
    self.pageImages = images;
    
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor blueColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPageViewController"];
    self.pageViewController.dataSource = self;
    
    KokkoDetailPageControlViewController *startingViewController = [self viewControllerAtIndex:0];
    self.viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:self.viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];


    NSLog(@"setting detail page view %@ to image %@", title, images[self.pageIndex]);
    self.backgroundImageView.image = [UIImage imageNamed:images[self.pageIndex]];
    self.titleLabel.text = title;
}

- (KokkoDetailPageControlViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KokkoDetailPageControlViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KokkoDetailPageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitle;
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - UIPageViewControllerDataSource Protocol

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KokkoDetailPageControlViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KokkoDetailPageControlViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
