//
//  KokkoTableViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface KokkoTableViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSArray *titleMatchesArray;
@property (nonatomic, retain) NSArray *subtitleMatchesArray;
@property (nonatomic, retain) NSArray *imageMatchesArray;
@property (nonatomic, retain) UIImage *tableViewImage;
@end
