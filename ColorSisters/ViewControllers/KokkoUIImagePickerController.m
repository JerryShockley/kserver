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

@property (nonatomic) BOOL chartDone;
@property (nonatomic) BOOL faceReady;
@property (nonatomic) BOOL faceDone;
@property (nonatomic) CGRect faceRect;

@property (nonatomic, strong) UILabel *chartLabel;
@property (nonatomic, strong) UILabel *faceLabel;
@property (nonatomic, strong) UILabel *chartCheck;
@property (nonatomic, strong) UILabel *faceCheck;


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
        _faceBox.layer.borderColor = UIColor.greenColor.CGColor;
        _faceBox.layer.borderWidth = 3;
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
        _chartBox.layer.borderColor = UIColor.blueColor.CGColor;
        _chartBox.layer.borderWidth = 3;
    }
    return _chartBox;
}

- (CGFloat)imageScale
{
    return self.imageView.image.size.width / self.view.frame.size.width;
}

- (UILabel *)chartLabel
{
    if (!_chartLabel) {
        self.chartLabel = [[UILabel alloc] init];
        [_chartLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _chartLabel.font = [UIFont systemFontOfSize:20];
        _chartLabel.textColor = [UIColor whiteColor];
    }
    return _chartLabel;
}

- (UILabel *)faceLabel
{
    if (!_faceLabel) {
        self.faceLabel = [[UILabel alloc] init];
        [_faceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _faceLabel.font = [UIFont systemFontOfSize:20];
        _faceLabel.textColor = [UIColor whiteColor];
    }
    return _faceLabel;
}

- (UILabel *)chartCheck
{
    if (!_chartCheck) {
        self.chartCheck = [[UILabel alloc] init];
        [_chartCheck setTranslatesAutoresizingMaskIntoConstraints:NO];
        _chartCheck.font = [UIFont systemFontOfSize:20];
    }
    return _chartCheck;
}

- (UILabel *)faceCheck
{
    if (!_faceCheck) {
        self.faceCheck = [[UILabel alloc] init];
        [_faceCheck setTranslatesAutoresizingMaskIntoConstraints:NO];
        _faceCheck.font = [UIFont systemFontOfSize:20];
    }
    return _faceCheck;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.findFoundationButton];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.spinner];
    [self.view addSubview:self.chartLabel];
    [self.view addSubview:self.faceLabel];
    [self.view addSubview:self.chartCheck];
    [self.view addSubview:self.faceCheck];

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

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chartLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chartLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-30]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chartCheck
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.chartLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chartCheck
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.chartLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.faceLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.faceLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-30]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.faceCheck
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.faceLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.faceCheck
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.faceLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
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
                                                             toItem:self.findFoundationButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-35.0]];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.findFoundationButton.enabled = YES;
    self.chartLabel.text = @"";
    self.faceLabel.text = @"";
    self.chartCheck.text = @"";
    self.faceCheck.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[KokkoInterface sharedInstance] cancelAnalysis];

    // Start fresh when we return
    [self.faceBox removeFromSuperview];
    [self.chartBox removeFromSuperview];
}


#pragma mark - Actions

- (void)findFoundation:(UIButton *)sender
{
    // Busy
    [self.spinner startAnimating];

    // State
    self.findFoundationButton.enabled = NO;
    self.chartDone = NO;
    self.faceReady = NO;
    self.faceDone = NO;
    self.faceRect = CGRectZero;
    self.shadeMatches = nil;

    // Go
    [[KokkoInterface sharedInstance] analyzeImage:self.image delegate:self];
}

- (CGRect)scaleRect:(CGRect)r byFactor:(CGFloat)f
{
    return CGRectMake(r.origin.x/f, r.origin.y/f, r.size.width/f, r.size.height/f);
}

// Change the size of the rectangle but the center point stays at the same location
// the same center point on the screen
- (CGRect)resizeRect:(CGRect)r byFactor:(CGFloat)f
{
    CGFloat newWidth = r.size.width * f;
    CGFloat newHeight = r.size.height * f;
    return CGRectMake(r.origin.x - (newWidth - r.size.width)/2.0,
                      r.origin.y - (newHeight - r.size.height)/2.0,
                      newWidth,
                      newHeight);
}


- (void)animateBox:(UIView *)box
          fromRect:(CGRect)startRect
            toRect:(CGRect)finalRect
        completion:(void(^)(BOOL))completion
{
    box.frame = startRect;
    CGFloat wiggle = finalRect.size.width * WiggleScale;

    [UIView animateWithDuration:.4
                     animations:^{
                         box.frame = CGRectMake(finalRect.origin.x+wiggle,
                                                finalRect.origin.y+wiggle,
                                                finalRect.size.width-2*wiggle,
                                                finalRect.size.height-2*wiggle);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              box.frame = CGRectMake(finalRect.origin.x-wiggle/2.,
                                                                     finalRect.origin.y-wiggle/2.,
                                                                     finalRect.size.width+wiggle,
                                                                     finalRect.size.height+wiggle);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   box.frame = finalRect;
                                                               }
                                                               completion:completion
                                               ];
                                          }
                          ];
                     }
     ];
}

- (void)animateLabel:(UILabel*)label
             forPass:(BOOL)pass
          completion:(void(^)(BOOL finished))completion
{
    label.text = pass ? @"\u2713" : @"\u2717";
    label.textColor = pass ? UIColor.greenColor : UIColor.redColor;
    label.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         label.transform = CGAffineTransformMakeScale(2, 2);
                     }
                     completion:completion
     ];
}

- (void)startChartAnimationWithRect:(CGRect)chartRect
{
    self.chartLabel.text = @"Chart Found";
    
    // Need a block safe version of self to guard against retain cycles
    __block KokkoUIImagePickerController *blockSelf = self;
    
    // If the result was vanishingly small, take that as a failure and skip
    if ((chartRect.size.height>1) && (chartRect.size.width>1)) {
        
        // Put the chart rect into the view
        [self.imageView addSubview:self.chartBox];
        
        // Animate the chart rect
        [self animateBox:self.chartBox
                fromRect:self.imageView.frame
                  toRect:[self scaleRect:chartRect byFactor:self.imageScale]
              completion:^(BOOL finished){
                  
                  // Set the label
                  [self animateLabel:self.chartCheck
                             forPass:YES
                          completion:^(BOOL finished) {
                              
                                       // Indicate that the chart animation is complete
                                       blockSelf.chartDone = YES;
                                       
                                       // Start the face animation if the faceRect has been populated
                                       if (blockSelf.faceReady) {
                                           [blockSelf startFaceAnimationWithRect:blockSelf.faceRect];
                                       }
                                       
                                   }];
              }];
    } else {
        [self animateLabel:self.chartCheck
                   forPass:NO
                completion:^(BOOL finished) {
                    
                    // Indicate that the chart animation is complete
                    blockSelf.chartDone = YES;
                    
                    // Start the face animation if the faceRect has been populated
                    if (blockSelf.faceReady) {
                        [blockSelf startFaceAnimationWithRect:blockSelf.faceRect];
                    }
                }];
    }
}

- (void)startFaceAnimationWithRect:(CGRect)faceRect
{
    [self.faceLabel setText:@"Face Found"];

    // Need a block safe version of self to guard against retain cycles
    __block KokkoUIImagePickerController *blockSelf = self;
    
    // If the result was vanishingly small, take that as a failure and skip
    if ((faceRect.size.height>1) && (faceRect.size.width>1)) {
        
        // Put the face rect into the view
        [self.imageView addSubview:self.faceBox];

        // Animate the face rect, and show matches on completion, if ready
        CGRect finalRect = [self scaleRect:faceRect byFactor:self.imageScale];
        self.faceWipe.frame = CGRectMake(0, -WipeHeight, self.view.frame.size.width,WipeHeight);
        [self animateBox:self.faceBox
                fromRect:self.imageView.frame
                  toRect:finalRect
              completion:^(BOOL finished) {
                  
                  // Set the label
                  [self animateLabel:self.faceCheck
                             forPass:YES
                          completion:^(BOOL finished) {
                              [UIView animateWithDuration:2
                                               animations:^{
                                                   CGRect frame = blockSelf.faceWipe.frame;
                                                   frame.origin = CGPointMake(0,finalRect.size.height + WipeHeight);
                                                   blockSelf.faceWipe.frame = frame;
                                               }
                                               completion:^(BOOL finished){
                                                   // Indicate that the face animation is complete
                                                   blockSelf.faceDone = YES;
                                                   
                                                   // Show any ready matches (a non-nil value means it is ready)
                                                   if (blockSelf.shadeMatches) {
                                                       [blockSelf showMatches];
                                                   }
                                               }
                               ];
                          }];
                  
              }
         ];
    } else {
        [self animateLabel:self.faceCheck
                   forPass:NO
                completion:^(BOOL finished) {
                    // Indicate that the face animation is complete
                    blockSelf.faceDone = YES;
                    
                    // Show any ready matches (a non-nil value means it is ready)
                    if (blockSelf.shadeMatches) {
                        [blockSelf showMatches];
                    }
                }
         ];
    }
}

- (void)showMatches
{
    [self.spinner stopAnimating];
    
    int brandCnt = 0, shadeCnt = 0;
    
    NSString *brandName, *title, *message;
    for (brandName in self.shadeMatches) {
        brandCnt++;
        shadeCnt += [[self.shadeMatches objectForKey: brandName] count];
    }
    NSLog(@"kokkoInterface foundShadeMatches found %d", shadeCnt);
    
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
    
    
    // I don't think you need it, but in case you wanted to add more delay before
    //  the alert shows, you could replace the above line with one like this:
//    [alert performSelector:@selector(show) withObject:nil afterDelay:.5];
    
    
}


#pragma mark - Kokko Image Processing Delegate

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
        foundChartRect:(CGRect)chartRect
{
    
    NSLog(@"Found chart at (%.1f,%.1f) with size (%.1f,%.1f)",
          chartRect.origin.x,
          chartRect.origin.y,
          chartRect.size.width,
          chartRect.size.height);
    
    chartRect = [self resizeRect:chartRect byFactor:1.1];
    
    NSLog(@"Resized chart rectangle: at (%.1f,%.1f) with size (%.1f,%.1f)",
          chartRect.origin.x,
          chartRect.origin.y,
          chartRect.size.width,
          chartRect.size.height);
    
    // Chart should go whenever it can, as it is first
    [self startChartAnimationWithRect:chartRect];
}

- (void)kokkoInterface:(KokkoInterface *)kokkoInterface
         foundFaceRect:(CGRect)faceRect
{
    NSLog(@"Found face at (%.1f,%.1f) with size (%.1f,%.1f)",
          faceRect.origin.x,
          faceRect.origin.y,
          faceRect.size.width,
          faceRect.size.height);
    
    // Face should only start if the chart is done, else just store the result
    //  to be used after the chart completes
    if (self.chartDone) {
        [self startFaceAnimationWithRect:faceRect];
    } else {
        self.faceReady = YES;
        self.faceRect = faceRect;
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
    // Record the result
    self.shadeMatches = shadeMatches;
    
    // If the face animation is complete, show the result; else the stored
    //  results will be used by the face animation completion block
    if (self.faceDone) {
        [self showMatches];
    }
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
