//
//  KokkoDetailPageContentViewController.h
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoDetailPageContentViewController : UIViewController

@property NSString *titleText;
@property NSString *imageFile;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
