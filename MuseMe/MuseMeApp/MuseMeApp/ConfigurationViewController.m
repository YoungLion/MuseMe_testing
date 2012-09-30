//
//  ConfigurationViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/26/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "TutorialViewController.h"

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
@synthesize delegate = _delegate;


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
    
    currentUser = [User new];
    currentUser.userID = [Utility getObjectForKey:CURRENTUSERID];
    [[RKObjectManager sharedManager] getObject:currentUser delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setUsernameLabel:nil];
    self.spinner = nil;
    self.delegate = nil;
    [super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.spinner stopAnimating];
    [super viewDidDisappear:animated];
}

#pragma User Acitons
- (IBAction)backgroundTouched:(id)sender {
    [self.usernameLabel resignFirstResponder];
}

- (IBAction)showAbout:(id)sender {
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    [self performSegueWithIdentifier:@"show about" sender:self];
}

- (void)startMuseMe {
    NSLog(@"Start Muse me clicked");
    [self.delegate configurationViewControllerDidSetup:self];
}

- (IBAction)changeProfilePicture {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"How would you like to set your picture?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture", @"Choose from existing", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.view];
	popupQuery = nil;
}

- (void) uploadPhoto
{
    [_spinner startAnimatingWithMessage:@"Uploading..." inView:self.view];
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

#pragma RKObjectLoaderDelegate Methods
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
    if ([objectLoader.resourcePath hasPrefix:@"/users"] && (objectLoader.method == RKRequestMethodGET))
    {
        self.usernameLabel.text = currentUser.username;
    }
    [self.spinner stopAnimating];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
#if ENVIRONMENT == ENVIRONMENT_DEVELOPMENT
    [Utility showAlert:[error localizedDescription] message:nil];
#endif
}

#pragma mark - UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"text end editting");
    NSString* username = [self.usernameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (username.length == 0)
    {
        [Utility showAlert:@"Your username can't be empty." message:nil];
        self.usernameLabel.text = currentUser.username;
    }else if (![textField.text isEqualToString:currentUser.username])
    {
        User* user = [User new];
        user.userID = currentUser.userID;
        user.username = textField.text;
        [_spinner startAnimatingWithMessage:@"Updating..." inView:self.view];
        [[RKObjectManager sharedManager] putObject:user delegate:self];
    }
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
        [self presentViewController:imagePicker
                                animated:YES completion:nil];
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
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = NO;
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *cropped = [info
                            objectForKey:UIImagePickerControllerEditedImage];
        UIImage *small = [UIImage imageWithCGImage:cropped.CGImage scale:1 orientation:cropped.imageOrientation];
        
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
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show tutorial"])
    {
        TutorialViewController* VC = segue.destinationViewController;
        VC.pageNumber = 0;
    }
}
@end
