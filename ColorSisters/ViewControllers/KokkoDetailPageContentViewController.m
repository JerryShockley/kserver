//
//  KokkoDetailPageContentViewController.m
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailPageContentViewController.h"

@interface KokkoDetailPageContentViewController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation KokkoDetailPageContentViewController

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:self.image];
        [_backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _backgroundImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.text = self.titleText;
    }
    return _titleLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add subviews
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.titleLabel];

    // Constrain subviews
    NSDictionary *views = @{@"title": self.titleLabel,
                            @"image": self.backgroundImageView,
                            };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[title]-5-[image]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
}


@end
