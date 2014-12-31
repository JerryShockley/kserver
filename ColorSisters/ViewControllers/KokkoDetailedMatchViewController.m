//
//  KokkoDetailedMatchViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailedMatchViewController.h"

@interface KokkoDetailedMatchViewController ()
@end

@implementation KokkoDetailedMatchViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem   // TODO convert from id to NSDictionary *
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Detail Item is a dictionary, extract the keys and values into appropriate structures
        NSString *title = [self.detailItem allKeys][0];  // extract the 'key', whcih is a string
        NSArray *images = [self.detailItem allValues][0]; // extract the 'value', which is an array

        self.pageTitle = title;
        self.pageImages = images;
        
        self.detailDescriptionLabel.text = title;
        self.detailImage.image = [UIImage imageNamed:images[0]];  // TODO need to pass off to PageView Controller, not just 0th image

        self.backgroundImageView.image = [UIImage imageNamed:images[0]];
        self.titleLabel.text = title;
        
        KokkoDetailedMatchViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detail Item is a dictionary, extract the keys and values into appropriate structures
    NSString *title = [self.detailItem allKeys][0];  // extract the 'key', whcih is a string
    NSArray *images = [self.detailItem allValues][0]; // extract the 'value', which is an array

    self.backgroundImageView.image = [UIImage imageNamed:images[0]];
    self.titleLabel.text = title;
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPageViewController"];
    self.pageViewController.dataSource = self;
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (KokkoDetailedMatchViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KokkoDetailedMatchViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KokkoDetailedMatchViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitle;
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - UIPageViewControllerDataSource Protocol

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KokkoDetailedMatchViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KokkoDetailedMatchViewController*) viewController).pageIndex;
    
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
