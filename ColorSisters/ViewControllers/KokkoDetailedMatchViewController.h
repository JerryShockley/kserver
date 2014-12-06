//
//  KokkoDetailedMatchViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoDetailedMatchViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
