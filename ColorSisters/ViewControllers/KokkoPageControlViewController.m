//
//  KokkoPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoPageControlViewController.h"

@interface KokkoPageControlViewController ()

@end

@implementation KokkoPageControlViewController
NSInteger intervalGettingStartedSeconds = 10;
NSUInteger currentIndex = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create the data model
    self.pageTitles = @[@"TODO description Page1.png", @"TODO description Page2.png", @"TODO description Page3.png"]; // TODO:  need strings
    self.pageImages = @[@"Page1.png", @"Page2.png", @"Page3.png"];
    
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor blueColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.backgroundColor = [UIColor blackColor];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:currentIndex];
    self.viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:self.viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    [NSTimer scheduledTimerWithTimeInterval:intervalGettingStartedSeconds
                                     target:self
                                   selector:@selector(scrollingTimer) userInfo:nil repeats:YES];
}

- (void) scrollingTimer {
    // TODO:  If the user initiates a scroll, then the action should be obeyed and the timer reset
    currentIndex = [self presentationIndexForPageViewController:self.pageViewController];
    
    switch (currentIndex) {
        case 0: {
            // Move from first to second page
            currentIndex = 1;
        break;
        }
        case 1: {
            // Move from second to third page
            currentIndex = 2;
            break;
        }
        case 2: {
            // Move from third to first page
            currentIndex = 0;
            break;
        }

        default:
        break;
    }

    self.viewControllers = @[[self viewControllerAtIndex:currentIndex]];
    [self.pageViewController setViewControllers:self.viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    }

- (void) viewDidAppear:(BOOL)animated {
    // For this view only, remove the Navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
    // Bring back the Navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return currentIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
