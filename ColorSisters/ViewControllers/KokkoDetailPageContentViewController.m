//
//  KokkoDetailPageContentViewController.m
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoDetailPageContentViewController.h"

@interface KokkoDetailPageContentViewController ()

@end

@implementation KokkoDetailPageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    
    NSString *html = @"<html><head></head><body>True Match Super Blendable Makeup SPF 17 is the best foundation for normal to very oily skin.  It has a fluid, silky feel and blends superbly, setting to a natural matte, slightly powedery finish that is translucent enough to let your skin show through, while still providing light coverage that diffuses minor flaws and redness.  The sunscreen is pure titanium dioxide, making this a gentle choice for skin (the forumula is also fragrance-free).</body></html>";
    
    [self.webView loadHTMLString:html baseURL:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
