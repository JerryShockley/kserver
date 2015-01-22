//
//  ViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "UIImage+fixOrientation.h"
#import "KokkoUIImagePickerController.h"
#import "KokkoInterface.h"
#import "KokkoTableViewController.h"

@interface KokkoUIImagePickerController () <UIAlertViewDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *findFoundationButton;

// Matches dictionary to be passed to the table view
@property (nonatomic) NSDictionary *shadeMatches;

@end

@implementation KokkoUIImagePickerController


#pragma mark - Accessors

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.image];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _imageView;
}

- (UIButton*)findFoundationButton
{
    if (!_findFoundationButton) {
        self.findFoundationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_findFoundationButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_findFoundationButton setTitle:@"Find Foundation" forState:UIControlStateNormal];
        _findFoundationButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _findFoundationButton.backgroundColor = [UIColor blackColor];
        [_findFoundationButton addTarget:self action:@selector(findFoundation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _findFoundationButton;
}

- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _spinner;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.spinner];
    [self.view addSubview:self.findFoundationButton];
    [self.view addSubview:self.imageView];

    self.navigationItem.title = @"Selected Photo";
    
    // Constrain subviews

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:10]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:self.image.size.height/self.image.size.width
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-30]];
    
}


#pragma mark - Actions

- (void)findFoundation:(UIButton *)sender
{
    // Busy
    [self.spinner startAnimating];
    
    KokkoInterface* kokkoClass = [KokkoInterface sharedKokkoInterface];
    [kokkoClass initWithImage:self.image];
    self.shadeMatches = [kokkoClass getRecommendations];
    //    self.shadeMatches = [kokkoClass getRecommendationsUIONLY];

    // Done
    [self.spinner stopAnimating];
    [self showMatchesAlert];
}

- (void)showMatchesAlert {
    int brandCnt = 0, shadeCnt = 0;
    
    NSString *brandName, *title, *message;
    for (brandName in self.shadeMatches) {
        brandCnt++;
        shadeCnt += [[self.shadeMatches objectForKey: brandName] count];
    }
    if (brandCnt == 0) {
        title = NSLocalizedString(@"No Matches Found", nil);
        message = NSLocalizedString(@"Either retake the photo or select a different photo from the Camera Roll", nil);
        self.findFoundationButton.enabled = NO;
    } else {
        title = NSLocalizedString(@"Match Found", nil);
        message = [NSString stringWithFormat:NSLocalizedString(@"Found %lu shades across %lu brands", @"Found {total number of shades} across {number of brands} brands"), shadeCnt, brandCnt];
    }
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.shadeMatches count]>0) {
        KokkoTableViewController *tvc = [[KokkoTableViewController alloc] init];
        tvc.detailItem = self.shadeMatches;
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

@end
