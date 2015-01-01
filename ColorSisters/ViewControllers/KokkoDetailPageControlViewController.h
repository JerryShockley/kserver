//
//  KokkoDetailPageControlViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoDetailPageControlViewController : UIViewController <UIPageViewControllerDataSource>

/// For the Pageview
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSArray *pageImages;

/// For passing in data from the Segue
@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
