//
//  KokkoDetailPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailPageControlViewController.h"
#import "KokkoDetailPageContentViewController.h"
#import "KokkoShareViewController.h"
#import "KokkoProductInfo.h"

@interface KokkoDetailPageControlViewController() <UIPageViewControllerDataSource,UIWebViewDelegate>

@property (strong, nonatomic) UIPageViewController *pvc;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) KokkoProductInfo *prodInfo;

@end


@implementation KokkoDetailPageControlViewController


#pragma mark - Accessors

- (KokkoProductInfo*)prodInfo
{
    if (!_prodInfo) {
        NSString *bundle = [NSString stringWithFormat:@"%@/product_images.bundle",[[NSBundle mainBundle] resourcePath]];
        self.prodInfo = [[KokkoProductInfo alloc] initWithContentsOfBundle:bundle];
    }
    return _prodInfo;
}

- (NSString *)brand
{
    return [self.detailItem allKeys][0];
}

- (NSArray *)shades
{
    return [self.detailItem allValues][0];
}

- (CGFloat)pagerHeight
{
    CGFloat h = 0;
    for (NSString *shade in self.shades) {
        UIImage *image = [self.prodInfo getProductImageForBrand:self.brand withShade:shade];
        if ((h==0) || (image.size.height<h)) {
            h = image.size.height;
        }
    }
    return h+77;
}

- (UIPageViewController *)pvc
{
    if (!_pvc) {
        self.pvc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                 options:nil];
        _pvc.dataSource = self;
        _pvc.view.autoresizingMask = UIViewAutoresizingNone;
        _pvc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.pagerHeight);
        [_pvc setViewControllers:@[[self viewControllerAtIndex:0]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    return _pvc;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        [_scrollView addSubview:self.contentView];
    }
    return _scrollView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        self.contentView = [[UIView alloc] init];
        [_contentView addSubview:self.pvc.view];
        [_contentView addSubview:self.webView];
    }
    return _contentView;
}

- (UIWebView *)webView
{
    if (!_webView) {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        [_webView loadHTMLString:[self.prodInfo getDescriptionForBrand:self.brand] baseURL:nil];
        _webView.scrollView.scrollEnabled = NO;
        _webView.delegate = self;
        _webView.scrollView.maximumZoomScale = 1.0;
        _webView.scrollView.minimumZoomScale = 1.0;
    }
    return _webView;
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
    
    [self.view addSubview:self.scrollView];
}

- (KokkoDetailPageContentViewController *)viewControllerAtIndex:(NSInteger)index
{
    // Test for out of bounds
    if (([self.shades count] == 0) || (index >= [self.shades count]) || (index < 0)) {
        return nil;
    }

    // Establish brand and shade
    NSString *shade = self.shades[index];

    // Get the product data
    UIImage *image = [self.prodInfo getProductImageForBrand:self.brand withShade:shade];
    
    NSString *prefix = @"";
    if ([self.shades count]==2) {
        if (index==0) {
            prefix = @"Best Match: ";
        } else {
            prefix = @"Alternative: ";
        }
    } else if ([self.shades count]>2) {
        if (index==0) {
            prefix = @"Best Match: ";
        } else {
            prefix = [NSString stringWithFormat:@"Alternative #%ld: ",(long)index];
        }
    }
    
    NSString *title = [NSString stringWithFormat:@"%@%@",prefix,shade];

    NSString *longname = [self.prodInfo getProductNameForBrand:self.brand withShade:shade];
    if (longname) {
        title = [title stringByAppendingFormat:@" - %@",longname];
    }
    
    // Create a new view controller and pass suitable data
    KokkoDetailPageContentViewController *pageContentViewController = [[KokkoDetailPageContentViewController alloc] init];
    pageContentViewController.image = image;
    pageContentViewController.titleText = title;
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat h = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue] + navHeight;
    CGFloat w = self.view.frame.size.width;

    webView.frame = CGRectMake(0, self.pagerHeight, w, h);
    webView.scrollView.frame = CGRectMake(0, 0, w, h);
    webView.scrollView.contentSize = CGSizeMake(w,h);
    
    self.contentView.frame = CGRectMake(0,0,w,h+self.pagerHeight);
    
    self.scrollView.contentSize = self.contentView.frame.size;
}



@end
