//
//  KokkoPageControlViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoPageControlViewController.h"

@interface KokkoPageControlViewController ()
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImageView *currentView;

@end

@implementation KokkoPageControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageControl.pageIndicatorTintColor = [UIColor blueColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];


    
    self.imageView.animationImages = @[
                                  [UIImage imageNamed:@"Page1"],
                                  [UIImage imageNamed:@"Page2"],
                                  [UIImage imageNamed:@"Page3"],
                                  ];
    

    self.imageView.image = self.imageView.animationImages[0];

    
    // We want the image to be scaled to the correct aspect ratio within imageView's bounds.
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // If the image does not have the same aspect ratio as imageView's bounds, then imageView's backgroundColor will be applied to the "empty" space.
    self.imageView.backgroundColor = [UIColor whiteColor];
}


- (IBAction)pageControlChanged:(id)sender {
    [self.currentView setHidden:YES];
    NSInteger selectedPage = self.pageControl.currentPage;
    
    self.imageView.image = self.imageView.animationImages[selectedPage];
//    [self.currentView setHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
