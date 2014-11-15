//
//  ViewController.h
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KokkoUIImagePickerController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)showCamera:(UIBarButtonItem *)sender;
- (IBAction)showPhotoPicker:(UIBarButtonItem *)sender;

@end
