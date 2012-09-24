//
//  SettingsTableViewController.m
//  MuseMe
//
//  Created by Yong Lin on 8/8/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "SettingsTableViewController.h"
#define Choose_Picture_Source_ActionSheet 0
#define Logout_Confirmaion_ActionSheet 1


@interface SettingsTableViewController (){
    User* currentUser;
    BOOL newMedia;
}
@property (strong, nonatomic) MuseMeActivityIndicator *spinner;
@end

@implementation SettingsTableViewController
@synthesize username=_username;
@synthesize profilePhoto=_profilePhoto;
@synthesize spinner = _spinner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[self.navigationItem.rightBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _username.delegate = self;
    _spinner = [MuseMeActivityIndicator new];
    
    [Utility renderView:self.profilePhoto withCornerRadius:MEDIUM_CORNER_RADIUS andBorderWidth:MEDIUM_BORDER_WIDTH];
    self.profilePhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_LARGE];
    
    currentUser = [User new];
    currentUser.userID = [Utility getObjectForKey:CURRENTUSERID];
    
	[self.logoutButton setNavigationButtonWithColor:[UIColor redColor]];
    self.logoutButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.logoutButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self.logoutButton.titleLabel setShadowColor:[UIColor blackColor]];
    self.logoutButton.buttonCornerRadius = 12.0f;
    
    [[RKObjectManager sharedManager] getObject:currentUser delegate:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setProfilePhoto:nil];
    [self setProfilePhoto:nil];
    [self setSpinner:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    ((CenterButtonTabController*)self.tabBarController).cameraButton.alpha = 0;
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma User Acitons

-(IBAction)logoutButtonPressed
{
    UIActionSheet* logoutConfirmationSheet = [[UIActionSheet alloc] initWithTitle:@"Log out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
    logoutConfirmationSheet.tag = Logout_Confirmaion_ActionSheet;
    [logoutConfirmationSheet showFromTabBar:self.tabBarController.tabBar];
    logoutConfirmationSheet = nil;
}

- (void)Logout {
    User* user = [User new];
    user.singleAccessToken = [Utility getObjectForKey:SINGLE_ACCESS_TOKEN_KEY];
    user.deviceToken = [Utility getObjectForKey:DEVICE_TOKEN_KEY];
    [[RKObjectManager sharedManager] postObject:user usingBlock:^(RKObjectLoader *loader) {
        loader.delegate = self;
        loader.resourcePath = @"/logout";
        loader.serializationMapping = [[RKObjectManager sharedManager].mappingProvider serializationMappingForClass:[User class]];
    }];
    [Utility setObject:nil forKey:CURRENTUSERID];
    [[self.navigationController presentingViewController] dismissModalViewControllerAnimated:YES];

}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backgroundTouched:(id)sender {
    [self.username resignFirstResponder];
}

#pragma RKObjectLoaderDelegate Methods
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
    if ([objectLoader wasSentToResourcePath:@"/logout"]){
        NSLog(@"Server side destroies session successfully!");
    }else if (objectLoader.method == RKRequestMethodGET){
        self.username.text = currentUser.username;
        self.profilePhoto.url = [NSURL URLWithString: currentUser.profilePhotoURL];
        [HJObjectManager manage:self.profilePhoto];
    }else if (objectLoader.method == RKRequestMethodPUT){
        [self.spinner stopAnimating];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 1))
    {
        [self changeProfilePicture];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSString* username = [self.username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (username.length == 0)
    {
        [Utility showAlert:@"Your username can't be empty." message:nil];
    }else if (![textField.text isEqualToString:currentUser.username])
    {
        currentUser.username = textField.text;
        currentUser.isFollowed = nil;
        [[RKObjectManager sharedManager] putObject:currentUser delegate:self];
    }
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)changeProfilePicture {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture", @"Choose from existing", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag = Choose_Picture_Source_ActionSheet;
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
- (void) TestOnSimulator
{
    self.profilePhoto.image = [UIImage imageNamed:@"user3.png"];
    [self uploadPhoto];
}//when testing on devices, reconnect useCamera method below

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
            if (actionSheet.tag == Choose_Picture_Source_ActionSheet)
            {
                [self useCamera];
            }else{
                [self Logout];
            }
            break;
        case 1:
            if (actionSheet.tag == Choose_Picture_Source_ActionSheet)
            {
                [self useCameraRoll];
            }
            break;
        default:
            break;
    }
    [actionSheet resignFirstResponder];
}

@end
