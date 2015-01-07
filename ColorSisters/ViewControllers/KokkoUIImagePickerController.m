//
//  ViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoUIImagePickerController.h"
#import "KokkoInterface.h"
#import "KokkoTableViewController.h"

@interface KokkoUIImagePickerController () <UIAlertViewDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) BOOL imageReady;
@property (nonatomic) UIImage *image;

/// Matches dictionary to be passed to the table view via a segue
@property (nonatomic) NSDictionary *shadeMatches;
@end

@implementation KokkoUIImagePickerController

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
//    [kokkoClass initWithImage:self.image];
//    [kokkoClass getRecommendations];
    self.shadeMatches = [kokkoClass getRecommendationsUIONLY];

    [self showMatchesAlert];
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
    
    NSString *brandName, *title, *message;
    for (brandName in self.shadeMatches) {
        brandCnt++;
        shadeCnt += [[self.shadeMatches objectForKey: brandName] count];
    }
    if (brandCnt == 0) {
	title = NSLocalizedString(@"No Matches Found", nil);
	message = NSLocalizedString(@"Either retake the photo or select a different photo from the Camera Roll", nil);;
    } else {
	title = NSLocalizedString(@"Match Found", nil);
	message = [NSString stringWithFormat:NSLocalizedString(@"Found %lu shades across %lu brands", @"Found {total number of shades} across {number of brands} brands"), shadeCnt, brandCnt];
    }
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    KokkoTableViewController *tableView = (KokkoTableViewController*)[segue destinationViewController];
    [tableView setDetailItem:self.shadeMatches];
}


#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.shadeMatches count] > 0)
	[self performSegueWithIdentifier:@"segueToMatches" sender:self];
}

@end
