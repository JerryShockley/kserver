//
//  KokkoDetailedMatchViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoDetailedMatchViewController : UIViewController <UIPageViewControllerDataSource>

// For the Pageview
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property /*(strong, nonatomic)*/ NSString *pageTitle;
@property /*(strong, nonatomic)*/ NSArray *pageImages;


@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

/// For passing in data from the Segue
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
