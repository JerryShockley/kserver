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
@synthesize detailedMatch = _detailedMatch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.imageView.image = _detailedMatch;
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
