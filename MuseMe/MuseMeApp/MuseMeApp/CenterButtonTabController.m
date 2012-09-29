//
//  CenterButtonTabController.m
//  MuseMe
//
//  Created by Yong Lin on 8/17/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "CenterButtonTabController.h"
#import "AddNewItemController.h"
#define UPDATE_BADGE_PERIOD 30

@interface CenterButtonTabController ()
{
    BOOL newMedia;
    NSTimer* getNotificationCountTimer;
}
@property (strong, nonatomic) SingleValue* notificationCount;
@end

@implementation CenterButtonTabController

@synthesize cameraButton = _cameraButton;
@synthesize notificationCount = _notificationCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tabBar setBackgroundImage:[UIImage imageNamed:TAB_BAR_BG]];

    [super viewDidLoad];
    [self addCenterButtonWithImage:[UIImage imageNamed:CAMERA_ICON] highlightImage:[UIImage imageNamed:CAMERA_ICON_HL]];
    
    //set color of text in UITabBarItem
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      BLACK_TEXT_COLOR, UITextAttributeTextColor,
      [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11], UITextAttributeFont,
      nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      BLACK_TEXT_COLOR, UITextAttributeTextColor,
      [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11], UITextAttributeFont,
      nil]
                                             forState:UIControlStateHighlighted];
    //custom tab bar icons
    UIImage *selectedImage0 = [UIImage imageNamed:POPULAR_ICON_HL];
    UIImage *unselectedImage0 = [UIImage imageNamed:POPULAR_ICON];
    
    UIImage *selectedImage1 = [UIImage imageNamed:FEEDS_ICON_HL];
    UIImage *unselectedImage1 = [UIImage imageNamed:FEEDS_ICON];
    
    UIImage *selectedImage3 = [UIImage imageNamed:NEWS_ICON_HL];
    UIImage *unselectedImage3 = [UIImage imageNamed:NEWS_ICON];
    
    UIImage *selectedImage4 = [UIImage imageNamed:PROFILE_ICON_HL];
    UIImage *unselectedImage4 = [UIImage imageNamed:PROFILE_ICON];
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    UITabBarItem *item4 = [tabBar.items objectAtIndex:4];
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
    [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
    [item4 setFinishedSelectedImage:selectedImage4 withFinishedUnselectedImage:unselectedImage4];
	// Do any additional setup after loading the view.
    
    getNotificationCountTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_BADGE_PERIOD target:self selector:@selector(updateNotificationCount) userInfo:nil repeats:YES];
    [getNotificationCountTimer fire];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [getNotificationCountTimer invalidate];
    // Release any retained subviews of the main view.
}


// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _cameraButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [_cameraButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_cameraButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        _cameraButton.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        _cameraButton.center = center;
    }
    [_cameraButton addTarget:self action:@selector(cameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)cameraButtonClicked:(UIButton*)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture", @"Choose from existing", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showFromTabBar:self.tabBar];
	popupQuery = nil;
}

- (void) TestOnSimulator
{    
    [self addNewItemViewWithPhoto:[UIImage imageNamed:@"user3.png"]];
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
    [self dismissModalViewControllerAnimated:NO];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *itemImage = [info
                          objectForKey:UIImagePickerControllerEditedImage];
        if (newMedia){
            UIImageWriteToSavedPhotosAlbum(itemImage,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        }
        [self addNewItemViewWithPhoto:itemImage];
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

-(void)addNewItemViewWithPhoto:(UIImage*)image
{
    AddNewItemController *addNewItemController = [self.storyboard  instantiateViewControllerWithIdentifier:@"add new item VC"];
    addNewItemController.capturedItemImage = image;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addNewItemController];
    [nav setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:nav animated:YES];
    
}

#pragma mark - UIActionSheetDelegate Methods


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
#if ENVIRONMENT == ENVIRONMENT_DEVELOPMENT
            [self useCamera];
#elif ENVIRONMENT == ENVIRONMENT_STAGING
            [self useCamera];
#elif ENVIRONMENT == ENVIRONMENT_PRODUCTION
            [self useCamera];
#endif
            break;
        case 1:[self useCameraRoll];
            break;
        case 2:[actionSheet resignFirstResponder];
            break;
        default:
            break;
    }
}

-(void)updateNotificationCount
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/unread_notification_count" delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    /*if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }*/
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    _notificationCount = (SingleValue*)object;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_notificationCount.number.integerValue];
    if (_notificationCount.number.integerValue >0 ) {
        ((UITabBarItem*)[self.tabBar.items objectAtIndex:3]).badgeValue = [_notificationCount.number stringValue];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
}
@end
