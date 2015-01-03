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
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageFile]];
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

    NSString *html = @"<html><head></head><body>True Match Super Blendable Makeup SPF 17 is the best foundation for normal to very oily skin.  It has a fluid, silky feel and blends superbly, setting to a natural matte, slightly powedery finish that is translucent enough to let your skin show through, while still providing light coverage that diffuses minor flaws and redness.  The sunscreen is pure titanium dioxide, making this a gentle choice for skin (the forumula is also fragrance-free).</body></html>";
    
    [self.webView loadHTMLString:html baseURL:nil];

    // Constrain subviews
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:10]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_titleLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:5]];

}

@end
