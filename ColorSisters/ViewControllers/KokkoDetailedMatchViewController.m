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

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Detail Item is a dictionary, extract the keys and values into appropriate structures
        NSString *title = [self.detailItem allKeys][0];  // extract the 'key', whcih is a string
        NSArray *images = [self.detailItem allValues][0]; // extract the 'value', which is an array
        
        self.detailDescriptionLabel.text = title;
        self.detailImage.image = [UIImage imageNamed:images[0]];  // TODO need to pass off to PageView Controller, not just 0th image

        self.backgroundImageView.image = [UIImage imageNamed:images[0]];
        self.titleLabel.text = title;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
