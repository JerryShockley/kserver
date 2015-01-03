//
//  KokkoDetailPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailPageControlViewController.h"
#import "KokkoDetailPageContentViewController.h"
#import "KokkoShareViewController.h"

@interface KokkoDetailPageControlViewController() <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pvc;

@end


@implementation KokkoDetailPageControlViewController


#pragma mark - Accessors

- (UIPageViewController *)pvc
{
    if (!_pvc) {
        self.pvc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                 options:nil];
        _pvc.dataSource = self;
        [_pvc setViewControllers:@[[self viewControllerAtIndex:0]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        _pvc.view.backgroundColor = [UIColor whiteColor];
    }
    return _pvc;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Nav bar
    self.navigationItem.title = [self.detailItem allKeys][0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(tapShare:)];
    // Ensure content sits below the navigation bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.pvc.view];
}

- (KokkoDetailPageContentViewController *)viewControllerAtIndex:(NSInteger)index
{
    // Test for out of bounds
    NSArray *images = [self.detailItem allValues][0];
    if (([images count] == 0) || (index >= [images count]) || (index < 0)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data
    KokkoDetailPageContentViewController *pageContentViewController = [[KokkoDetailPageContentViewController alloc] init];
    pageContentViewController.imageFile = images[index];
    pageContentViewController.titleText = @"Best Match";
    pageContentViewController.view.tag = index;
    return pageContentViewController;
}


#pragma mark - Actions

- (void)tapShare:(id)sender
{
    KokkoShareViewController *svc = [[KokkoShareViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}


#pragma mark - UIPageViewControllerDataSource Protocol

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((KokkoDetailPageControlViewController*) viewController).view.tag;
    return [self viewControllerAtIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((KokkoDetailPageControlViewController*) viewController).view.tag;
    return [self viewControllerAtIndex:index+1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [[self.detailItem allValues][0] count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
