//
//  KokkoTableViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface KokkoTableViewController : UITableViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) UIImage *tableViewImage;
@end
