//
//  KokkoPageContentViewController.m
//  PageViewDemo
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoPageContentViewController.h"

@interface KokkoPageContentViewController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation KokkoPageContentViewController

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
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[image]-[title]|"
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:self.image.size.height/self.image.size.width
                                                           constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

}

@end
