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

@interface KokkoUIImagePickerController () <UIAlertViewDelegate,KokkoInterfaceDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *findFoundationButton;

@property (nonatomic, strong) UIView *faceBox;
@property (nonatomic, strong) UIView *faceWipe;
@property (nonatomic, strong) UIView *chartBox;
@property (nonatomic, readonly) CGFloat imageScale;


// Matches dictionary to be passed to the table view
@property (nonatomic) NSDictionary *shadeMatches;

@end

@implementation KokkoUIImagePickerController


static const CGFloat WiggleScale = 0.075;
static const CGFloat WipeHeight = 50;


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


- (UIView *)faceBox
{
    if (!_faceBox) {
        self.faceBox = [[UIView alloc] init];
        _faceBox.layer.borderColor = UIColor.whiteColor.CGColor;
        _faceBox.layer.borderWidth = 2;
        _faceBox.clipsToBounds = YES;
        [_faceBox addSubview:self.faceWipe];
    }
    return _faceBox;
}

- (UIView *)faceWipe
{
    if (!_faceWipe) {
        self.faceWipe = [[UIView alloc] initWithFrame:CGRectMake(-WipeHeight, 0, self.view.frame.size.width, WipeHeight)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _faceWipe.bounds;
        gradient.colors = @[(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:1].CGColor];
        [_faceWipe.layer insertSublayer:gradient atIndex:0];
    }
    return _faceWipe;
}

- (UIView *)chartBox
{
    if (!_chartBox) {
        self.chartBox = [[UIView alloc] init];
        _chartBox.layer.borderColor = UIColor.whiteColor.CGColor;
        _chartBox.layer.borderWidth = 2;
    }
    return _chartBox;
}

- (CGFloat)imageScale
{
    return self.imageView.image.size.width / self.view.frame.size.width;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.findFoundationButton];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.spinner];

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

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-30]];

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
                                                             toItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.findFoundationButton.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[KokkoInterface sharedKokkoInterface] cancelAnalysis];

    // Start fresh when we return
    [self.faceBox removeFromSuperview];
    [self.chartBox removeFromSuperview];
}


#pragma mark - Actions

- (void)findFoundation:(UIButton *)sender
{
    // Busy
    [self.spinner startAnimating];
<<<<<<< HEAD
    [[KokkoInterface sharedInstance] analyzeImage:self.image delegate:self];
=======
    self.findFoundationButton.enabled = NO;
    [[KokkoInterface sharedKokkoInterface] analyzeImage:self.image delegate:self];
>>>>>>> aa81f37efe067c274a7c78ca8f60b188158de7d5
}

- (CGRect)scaleRect:(CGRect)r byFactor:(CGFloat)f
{
    return CGRectMake(r.origin.x/f, r.origin.y/f, r.size.width/f, r.size.height/f);
}

- (void)animateBox:(UIView *)box
          fromRect:(CGRect)startRect
            toRect:(CGRect)finalRect
          withWipe:(UIView *)wipe
{
    box.frame = startRect;
    if (wipe) {
        wipe.frame = CGRectMake(0, -WipeHeight, self.view.frame.size.width,WipeHeight);
    }
    CGFloat wiggle = finalRect.size.width * WiggleScale;

    [UIView animateWithDuration:.4
                     animations:^{
                         box.frame = CGRectMake(finalRect.origin.x+wiggle,
                                                finalRect.origin.y+wiggle,
                                                finalRect.size.width-2*wiggle,
                                                finalRect.size.height-2*wiggle);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              box.frame = CGRectMake(finalRect.origin.x-wiggle/2.,
                                                                     finalRect.origin.y-wiggle/2.,
                                                                     finalRect.size.width+wiggle,
                                                                     finalRect.size.height+wiggle);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.3
                                                               animations:^{
                                                                   box.frame = finalRect;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:2
                                                                                    animations:^{
                                                                                        if (wipe) {
                                                                                            CGRect frame = wipe.frame;
                                                                                            frame.origin = CGPointMake(0,finalRect.size.height + WipeHeight);
                                                                                            wipe.frame = frame;
                                                                                        }
                                                                                    }
                                                                                    completion:^(BOOL finished){}
                                                                    ];
                                                              }];
                                          }
                          ];
                     }
     ];
}

#pragma mark - Kokko Image Processing Delegate

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
         foundFaceRect:(CGRect)faceRect
{
    NSLog(@"Found face at (%.1f,%.1f) with size (%.1f,%.1f)",
          faceRect.origin.x,
          faceRect.origin.y,
          faceRect.size.width,
          faceRect.size.height);

    if ((faceRect.size.height>1) && (faceRect.size.width>1)) {
        [self.imageView addSubview:self.faceBox];
        [self animateBox:self.faceBox
                fromRect:self.imageView.frame
                  toRect:[self scaleRect:faceRect byFactor:self.imageScale]
                withWipe:self.faceWipe];
    }
}

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
        foundChartRect:(CGRect)chartRect
{
    NSLog(@"Found chart at (%.1f,%.1f) with size (%.1f,%.1f)",
          chartRect.origin.x,
          chartRect.origin.y,
          chartRect.size.width,
          chartRect.size.height);

    if ((chartRect.size.height>1) && (chartRect.size.width>1)) {
        [self.imageView addSubview:self.chartBox];
        [self animateBox:self.chartBox
                fromRect:self.imageView.frame
                  toRect:[self scaleRect:chartRect byFactor:self.imageScale]
                withWipe:nil];
    }
}

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
      analysisProgress:(CGFloat)progress
{
    NSLog(@"Analaysis progress is %.2f",progress);
}

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
     foundShadeMatches:(NSDictionary *)shadeMatches
{
    self.shadeMatches = shadeMatches;
    [self.spinner stopAnimating];

    int brandCnt = 0, shadeCnt = 0;
    
    NSString *brandName, *title, *message;
    for (brandName in self.shadeMatches) {
        brandCnt++;
        shadeCnt += [[self.shadeMatches objectForKey: brandName] count];
    }

    NSLog(@"found %d shade matches", shadeCnt);
    
    if (brandCnt == 0) {
        // Make sure we are not showing these
        [self.faceBox removeFromSuperview];
        [self.chartBox removeFromSuperview];
        
        title = NSLocalizedString(@"No Matches Found", nil);
        message = NSLocalizedString(@"Either retake the photo or select a different photo from the Camera Roll", nil);
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
