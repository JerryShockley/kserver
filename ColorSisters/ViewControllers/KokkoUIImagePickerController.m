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
@property (nonatomic) BOOL imageReady;
@property (nonatomic) UIImage *image;
@property (nonatomic, strong) UIButton *findFoundationButton;

/// Matches dictionary to be passed to the table view via a segue
@property (nonatomic) NSDictionary *shadeMatches;
@end

@implementation KokkoUIImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self imagePicker];
}

- (void) imagePicker {
    // Once you touch “getting started” it should open the camera view (viewfinder mode), unless the camera is unavailable, in which case open in picker view.
    if (self.imageReady == NO) {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
	    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            self.imageReady = YES;
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            self.imageReady = YES;
        }
	// ST: The only other source type is PhotoAlbum, should that be supported as well?
    }
    // If neither camera nor photo roll is available, must handle this error case --
    // probably display a popup with "no camera or photo library available" message
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
	// Default case for us is the user taking a selfie, so use the
	// front-facing camera if it is available
	if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
	    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	// We don't want the user taking a photo with the flash--interferes
	// with the image color analysis. Unfortunately, because we want the
	// user to be able to choose between front and rear facing cameras,
	// we have to expose the Camera Controls, and that means they can turn
	// on the flash if they want. But at least we can set the default to
	// Off rather than Auto.
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        imagePickerController.showsCameraControls = YES;
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *imageToUse = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (imageToUse.imageOrientation != UIImageOrientationUp)
	NSLog(@"Original image orientation is %ld--adjust before use", imageToUse.imageOrientation);
    // Need code here to set the imageView window size
    self.image = [imageToUse orientImageUp];
    self.imageView.image = self.image;
    
    [self.view addSubview:self.showFindFoundationButton];

    // This will dismiss the picker sourceType
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Dynamic UI elements

- (UIButton*)showFindFoundationButton
{
    if (!_findFoundationButton) {
	self.findFoundationButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_findFoundationButton setTitle:@"Find Foundation" forState:UIControlStateNormal];
	_findFoundationButton.titleLabel.font = [UIFont systemFontOfSize:20];
	// ST: The '- 100' and '- 50' is a hack and needs to be fixed.
	_findFoundationButton.frame = CGRectMake(0,
						 self.imagePickerController.view.frame.size.height - 100,
						 self.imagePickerController.view.frame.size.width,
						 30);
	// ST: Not sure the background color should be set. Perhaps should be left as nil
	_findFoundationButton.backgroundColor = [UIColor blackColor];
	[_findFoundationButton addTarget:self action:@selector(findFoundation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _findFoundationButton;
}

- (void)hideFindFoundationButton
{
    if (_findFoundationButton) {
	[_findFoundationButton removeFromSuperview];
	_findFoundationButton = nil;
    }
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
//    [kokkoClass getRecommendations];
    self.shadeMatches = [kokkoClass getRecommendationsUIONLY];
    [self hideFindFoundationButton];

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
