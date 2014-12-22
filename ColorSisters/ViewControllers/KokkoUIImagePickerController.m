//
//  ViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoUIImagePickerController.h"
#import "KokkoInterface.h"
#import "KokkoTableViewController.h"

@interface KokkoUIImagePickerController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) BOOL imageReady;
@property (nonatomic) UIImage *image;

/// Matches dictionary to be passed to the table view via a segue
@property (nonatomic) NSDictionary *shadeMatches;
@end

@implementation KokkoUIImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self imagePicker];
}

- (void) imagePicker {
    // Once you touch “getting started” it should open the camera view (viewfinder mode), unless the camera is unavailable, in which case open in picker view.
    if(self.imageReady == NO) {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            self.imageReady = YES;
        } else {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            self.imageReady = YES;
        }
    }

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        imagePickerController.showsCameraControls = YES;
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = self.image;
    

    // This will dismiss the picker sourceType
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button event handlers

- (IBAction)showCamera:(UIBarButtonItem *)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showPhotoPicker:(UIBarButtonItem *)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)findFoundation:(UIButton *)sender {
    KokkoInterface* kokkoClass = [KokkoInterface sharedKokkoInterface];
    [kokkoClass initWithImage:self.image];
    self.shadeMatches = [kokkoClass getRecommendations];

    // TODO - add popup with results from kokkoClass
    [self showMatchesAlert];

    [self performSegueWithIdentifier:@"segueToMatches" sender:self];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // Cancel should take you back to the launch pages
    // TODO:  a better way to dismiss back to launcher page
    // This will dismiss the imagePicker
    [self dismissViewControllerAnimated:YES completion:nil];
    // This should take us back to the launcher page
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    //    self.imageReady = NO;
}

- (void)showMatchesAlert {
    int brandCnt = 0, shadeCnt = 0;
    
    NSString *brandName;
    for (brandName in self.shadeMatches) {
        brandCnt++;
        shadeCnt += [[self.shadeMatches objectForKey: brandName] count];
    }
    NSString *title = NSLocalizedString(@"Match Found", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Found %lu shades across %lu brands", @"Found {total number of shades} across {number of brands} brands"), shadeCnt, brandCnt];
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    KokkoTableViewController *tableView = (KokkoTableViewController*)[segue destinationViewController];
    [tableView setDetailItem:self.shadeMatches];
}


@end
