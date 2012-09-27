//
//  ConfigurationViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/26/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ConfigurationViewController.h"

@interface ConfigurationViewController (){
    User* currentUser;
    BOOL newMedia;
}
@property (strong, nonatomic) MuseMeActivityIndicator *spinner;
@end

@implementation ConfigurationViewController
@synthesize usernameLabel = _usernameLabel;
@synthesize profilePhoto = _profilePhoto;
@synthesize spinner = _spinner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    _usernameLabel.delegate = self;
    _spinner = [MuseMeActivityIndicator new];
    
    [Utility renderView:self.profilePhoto withCornerRadius:MEDIUM_CORNER_RADIUS andBorderWidth:MEDIUM_BORDER_WIDTH shadowOffSet:MEDIUM_SHADOW_OFFSET];
    self.profilePhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_LARGE];
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
}

#pragma User Acitons
- (IBAction)backgroundTouched:(id)sender {
    [self.usernameLabel resignFirstResponder];
}

#pragma RKObjectLoaderDelegate Methods
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{

}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
}

- (IBAction)changeProfilePicture {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture", @"Choose from existing", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showFromTabBar:self.tabBarController.tabBar];
	popupQuery = nil;
}

- (void) uploadPhoto
{
    [_spinner startAnimatingWithMessage:@"Uploading..." inView:self.view];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    currentUser.photo = UIImageJPEGRepresentation(self.profilePhoto.image, 1.0f);
    [[RKObjectManager sharedManager] putObject:currentUser usingBlock:^(RKObjectLoader *loader){
        RKParams* params = [RKParams params];
        [params setData:currentUser.photo MIMEType:@"image/jpeg" forParam:@"user[photo]"];
        NSLog(@"post to %@",loader.resourcePath);
        loader.resourcePath = @"/update_profile_photo";
        loader.params = params;
        loader.delegate = self;
    }];
}

#pragma mark - UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSString* username = [self.usernameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (username.length == 0)
    {
        [Utility showAlert:@"Your username can't be empty." message:nil];
    }else if (![textField.text isEqualToString:currentUser.username])
    {
        User* user = [User new];
        user.username = textField.text;
        user.userID = currentUser.userID;
        [[RKObjectManager sharedManager] putObject:user delegate:self];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)useCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker
                                animated:YES];
        newMedia = YES;
    }
}

- (void)useCameraRoll
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *cropped = [info
                            objectForKey:UIImagePickerControllerEditedImage];
        UIImage *small = [UIImage imageWithCGImage:cropped.CGImage scale:0.25 orientation:cropped.imageOrientation];
        
        self.profilePhoto.image = small;
        [self uploadPhoto];
        if (newMedia){
            UIImageWriteToSavedPhotosAlbum(small,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        [Utility showAlert:@"Save failed" message:@"Failed to save image"];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate Methods


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
                [self useCamera];
            break;
        case 1:
                [self useCameraRoll];
        default:
            break;
    }
    [actionSheet resignFirstResponder];
}

@end
