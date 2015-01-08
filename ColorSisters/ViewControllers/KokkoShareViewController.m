//
//  KokkoShareViewController.m
//  ColorSisters
//
//  Created by Paul Lettieri on 1/3/15.
//  Copyright (c) 2015 Kokko, Inc. All rights reserved.
//

#import "KokkoShareViewController.h"
#import "KokkoUIImagePickerController.h"

@interface KokkoShareViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,strong) UILabel *footerLabel;
@property (nonatomic,strong) UITextField *firstNameField;
@property (nonatomic,strong) UITextField *lastNameField;
@property (nonatomic,strong) UITextField *emailField;
@property (nonatomic,strong) UIButton *signupButton;
@property (nonatomic) CGPoint center;

@end

@implementation KokkoShareViewController

- (CGFloat)labelMargin { return 10.; }
- (CGFloat)fieldMargin { return 20.; }
- (CGFloat)vMargin { return 15.; }

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"Thank you for using ColorSisters.";
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        self.messageLabel = [[UILabel alloc] init];
        _messageLabel.text = @"Want to know more? Give us your e-mail address and we will send you tips on choosing the right formulation for your skin and links to videos showing how to apply foundation perfectly every time.";
        [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0; // Grow as needed
        _messageLabel.font = [UIFont systemFontOfSize:15];
    }
    return _messageLabel;
}

- (UITextField *)firstNameField
{
    if (!_firstNameField) {
        self.firstNameField = [[UITextField alloc] init];
        [_firstNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
        _firstNameField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _firstNameField.borderStyle = UITextBorderStyleRoundedRect;
        _firstNameField.placeholder = @"First Name";
        _firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _firstNameField.delegate = self;
    }
    return _firstNameField;
}

- (UITextField *)lastNameField
{
    if (!_lastNameField) {
        self.lastNameField = [[UITextField alloc] init];
        [_lastNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
        _lastNameField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _lastNameField.borderStyle = UITextBorderStyleRoundedRect;
        _lastNameField.placeholder = @"Last Name (optional)";
        _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _lastNameField.delegate = self;
    }
    return _lastNameField;
}

- (UITextField *)emailField
{
    if (!_emailField) {
        self.emailField = [[UITextField alloc] init];
        [_emailField setTranslatesAutoresizingMaskIntoConstraints:NO];
        _emailField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emailField.borderStyle = UITextBorderStyleRoundedRect;
        _emailField.placeholder = @"Email";
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailField.delegate = self;
    }
    return _emailField;
}

- (UIButton *)signupButton
{
    if (!_signupButton) {
        self.signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_signupButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        _signupButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_signupButton addTarget:self action:@selector(tapSignup:) forControlEvents:UIControlEventTouchUpInside];
        [_signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    }
    return _signupButton;
}

- (UILabel *)footerLabel
{
    if (!_footerLabel) {
        self.footerLabel = [[UILabel alloc] init];
        _footerLabel.text = @"Color Sisters cares about your privacy. Your results will not be shared with anyone without your permission. See our complete privacy policy at www.colorsisters.com/privacy.";
        [_footerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _footerLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _footerLabel.numberOfLines = 0; // Grow as needed
        _footerLabel.font = [UIFont systemFontOfSize:11];
    }
    return _footerLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ensure content sits below the navigation bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New Photo"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(tapNewPhoto:)];

    // Let us know when the keyboard will show
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];

    // Child views
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.messageLabel];
    [self.view addSubview:self.footerLabel];
    [self.view addSubview:self.firstNameField];
    [self.view addSubview:self.lastNameField];
    [self.view addSubview:self.emailField];
    [self.view addSubview:self.signupButton];

    // Constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.labelMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:self.vMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.titleLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.labelMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.labelMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailField
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.messageLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.fieldMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailField
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.fieldMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameField
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.emailField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.fieldMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameField
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.fieldMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameField
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.firstNameField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.fieldMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameField
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.fieldMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.signupButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.lastNameField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.signupButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.fieldMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.signupButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.fieldMargin]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.footerLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.signupButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.vMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.footerLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:self.labelMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.footerLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-self.labelMargin]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.center = self.view.center;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)tapSignup:(id)sender
{
    // Do something here
}

- (void)tapNewPhoto:(id)sender
{
    for (UIViewController *vc in [self.navigationController viewControllers]) {
        if ([vc isKindOfClass:[KokkoUIImagePickerController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.view.frame;
        CGFloat y = -theTextField.frame.origin.y + self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 10;
        frame.origin = CGPointMake(frame.origin.x,y);
        self.view.frame = frame;
    }];
}

- (void) keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.center = self.center;
    }];
}



@end
