//
//  RegistrationPageViewController.m
//  MuseMe
//
//  Created by Yong Lin on 7/10/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "RegistrationPageViewController.h"
#import "Utility.h"
#define EmailField 0
#define PasswordField 1
#define PasswordConfirmationField 2

#define OpacityOfDimissButton 0.15

@interface RegistrationPageViewController (){
    User* user;
    BOOL choiceMade;
    BOOL loginMode;
    int currentPage;
}
@property (strong, nonatomic)  MuseMeActivityIndicator *spinner;
@end

@implementation RegistrationPageViewController
@synthesize dismissButton = _dismissButton;
@synthesize logoImage = _logoImage;

@synthesize emailField=_emailField;
@synthesize passwordField=_passwordField;
@synthesize passwordConfirmationField=_passwordConfirmationField;
@synthesize signupButton = _signupButton;
@synthesize spinner = _spinner;
@synthesize loginButton = _loginButton;
@synthesize background = _background;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    _emailField.delegate = self;
    _emailField.returnKeyType = UIReturnKeyNext;
    _emailField.tag = EmailField;
    _emailField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    _emailField.alpha = 0;

    
    _passwordField.delegate = self;
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.tag = PasswordField;
    _passwordField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    _passwordField.alpha = 0;

    
    _passwordConfirmationField.delegate = self;
    _passwordConfirmationField.returnKeyType =UIReturnKeyDone;
    _passwordConfirmationField.tag = PasswordConfirmationField;
    _passwordConfirmationField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    _passwordConfirmationField.alpha = 0;

    /*_emailField.inputAccessoryView = [Utility keyboardAccessoryToolBarWithButton:@"Dismiss" target:self action:@selector(dismissAll)];
    _passwordField.inputAccessoryView = [Utility keyboardAccessoryToolBarWithButton:@"Dismiss" target:self action:@selector(dismissAll)];    choiceMade = NO;
    _passwordConfirmationField.inputAccessoryView = [Utility keyboardAccessoryToolBarWithButton:@"Dismiss" target:self action:@selector(dismissAll)];*/
    
    self.loginButton.alpha = 0;
    self.signupButton.alpha = 0;
    self.dismissButton.alpha = 0;
    self.spinner = [MuseMeActivityIndicator new];
    

    /*_scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * kNumberOfPages, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;

    //_pageControl.numberOfPages = kNumberOfPages;
    //_pageControl.currentPage = 0;
    currentPage = 0;
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    _scrollView.alpha = 0;*/
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([Utility getObjectForKey:CURRENTUSERID]){
        [self performSegueWithIdentifier:@"show home" sender:self];
    }else{
        [self animateOpening];
    }
}

-(void)animateOpening
{
    CGRect frame = CGRectMake(0, 183, 320, 53);
    self.logoImage.frame = frame;
    self.logoImage.image = [UIImage imageNamed:LOGO_IN_LANDING_PAGE];
    frame.origin.y = 133;
    CGFloat transitionDuration = 0.4;
    [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.logoImage.frame = frame;
        self.logoImage.alpha = 0;
    } completion:^(BOOL finished){
        CGRect frame1 = self.logoImage.frame;
        frame1.origin.y = 70;
        self.logoImage.frame = frame1;
        frame1.origin.y = 20;
        [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.logoImage.frame = frame1;
            self.logoImage.alpha = 1;
        } completion:nil];
    }];
    
    
    
    [UIView animateWithDuration:0.5 delay:transitionDuration*2 options:UIViewAnimationCurveEaseInOut animations:^{
        self.loginButton.alpha = 1;
        self.signupButton.alpha = 1;
    } completion:nil];
    
    [Utility setObject:[Utility getObjectForKey:DEVICE_TOKEN_KEY]?[Utility getObjectForKey:DEVICE_TOKEN_KEY]:@"111052f6a5afde35f4b6f4376f29d913c1211b117529593a3c97f6b539195046" forKey:DEVICE_TOKEN_KEY];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.emailField.text=nil;
    self.passwordField.text=nil;
    self.passwordConfirmationField.text=nil;
    [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
}

- (void)viewDidUnload
{
    self.emailField = nil;
    [self setPasswordField:nil];
    [self setPasswordConfirmationField:nil];
    [self setSignupButton:nil];
    [self setSpinner:nil];
    [self setLoginButton:nil];
    [self setBackground:nil];
    [self setDismissButton:nil];
    [self setLogoImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

#pragma User Actions

/*- (IBAction)loginWithFacebook:(id)sender {

    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    MuseMeDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [appDelegate sessionStateChanged:session state:state error:error];
                                             if ((!error) && FB_ISSESSIONOPENWITHSTATE(state)) {
                                                 [self performSegueWithIdentifier:@"show home" sender:self];
                                             }
                                         }];
}*/

- (IBAction)loginButtonPressed {
    if (choiceMade){
        [self login];
    }else{
        loginMode = YES;
        choiceMade = YES;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.signupButton.alpha = 0;
            self.emailField.alpha = 1;
            self.passwordField.alpha = 1;
            self.dismissButton.alpha = OpacityOfDimissButton;
        } completion:nil];
        [self.emailField becomeFirstResponder];
    }
}

- (IBAction)signupButtonPressed:(id)sender {
    if (choiceMade){
        [self signup];
    }else{
        loginMode = NO;
        choiceMade = YES;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.loginButton.alpha = 0;
            self.emailField.alpha = 1;
            self.passwordField.alpha = 1;
            self.passwordConfirmationField.alpha = 1;
            self.dismissButton.alpha = OpacityOfDimissButton;
        } completion:nil];
        [self.emailField becomeFirstResponder];
    }
}

-(IBAction)backgroundTouched:(id)sender
{
    if (choiceMade){
        [self dismissAll];
    }
}

-(void)dismissAll
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.passwordConfirmationField resignFirstResponder];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.emailField.alpha = 0;
        self.passwordField.alpha = 0;
        self.passwordConfirmationField.alpha = 0;
        self.dismissButton.alpha = 0;
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.loginButton.alpha = 1;
        self.signupButton.alpha = 1;
    } completion:nil];
    choiceMade = NO;
}

- (void)signup {
    if (_passwordField.text.length < 6){
        [Utility showAlert:@"Password is too short!" message:@"Password should be longer than 6 characters"];
    }else if (![_passwordConfirmationField.text isEqualToString:_passwordField.text]){
        [Utility showAlert:@"Password Confirmation Mismatch!" message:@"Your password and password confirmation should be exactly the same."];
    }else {
        [self.emailField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self.passwordConfirmationField resignFirstResponder];
        user = [User new];
        if ([self.emailField.text rangeOfString:@"@"].location != NSNotFound){
            user.username = [self.emailField.text substringToIndex:[self.emailField.text rangeOfString:@"@"].location];
        }
        user.email = self.emailField.text;
        user.password = self.passwordField.text;
        user.passwordConfirmation = self.passwordConfirmationField.text;        
        user.deviceToken = [Utility getObjectForKey:DEVICE_TOKEN_KEY];
        [self.spinner startAnimatingWithMessage:@"Signing up..." inView:self.view];
        [[RKObjectManager sharedManager] postObject:user delegate:self];
    }
}

- (void)login {
    if ([self.emailField.text length] == 0 ||[self.emailField.text length] == 0 ){
        [Utility showAlert:@"Sorry!" message:@"Neither email nor password can be empty."];
    }else{
        [self.emailField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        user = [User new];
        user.email = self.emailField.text;
        user.password = self.passwordField.text;
        user.deviceToken = [Utility getObjectForKey:DEVICE_TOKEN_KEY];
        NSLog(@"device token sent:%@", user.deviceToken);
        [self.spinner startAnimatingWithMessage:@"Authenticating..." inView:self.view];
        [[RKObjectManager sharedManager] postObject:user usingBlock:^(RKObjectLoader* loader){
            loader.resourcePath = @"/login";
            loader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[User class]];
            loader.serializationMapping =[[RKObjectManager sharedManager].mappingProvider serializationMappingForClass:[User class]];
            loader.delegate = self;
        }];
    }
}

#pragma RKObjectLoader Delegate Methods
- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    // signup was successful
    if ([objectLoader wasSentToResourcePath:@"/signup"]){
        [Utility setObject:user.singleAccessToken forKey:SINGLE_ACCESS_TOKEN_KEY];
        [Utility setObject:user.userID forKey:CURRENTUSERID];
        [Utility setObject:[NSNumber numberWithInt:0] forKey:UNREAD_NOTIFICATION_COUNT_KEY];
        ConfigurationViewController* VC = [self.storyboard  instantiateViewControllerWithIdentifier:@"account setup VC"];
        VC.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
        [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:nav animated:YES completion:nil];
        
    }else if ([objectLoader wasSentToResourcePath:@"/login"]){
        [Utility setObject:user.singleAccessToken forKey:SINGLE_ACCESS_TOKEN_KEY];
        [Utility setObject:user.userID forKey:CURRENTUSERID];
        [Utility setObject:[NSNumber numberWithInt:0] forKey:UNREAD_NOTIFICATION_COUNT_KEY];
        [self performSegueWithIdentifier:@"show home" sender:self];
    }
    [self.spinner stopAnimating];
    [self dismissAll];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    //show errors: existent email and invalid password
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
    NSLog(@"Encountered an error: %@", error);
    [self.spinner stopAnimating];
}

#pragma UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (!loginMode){
        switch (textField.tag) {
            case EmailField:{
                [_passwordField becomeFirstResponder];
                return NO;
            }
            case PasswordField:{
                [self.passwordConfirmationField becomeFirstResponder];
                return NO;
            }
            case PasswordConfirmationField:{
                [self signup];
                return NO;
            }
            default:
                break;
        }
    }else{
        if (textField.tag == EmailField)
        {
            [_passwordField becomeFirstResponder];
            return NO;
        }else {
            [self login];
            return NO;
        }
    }
    return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)configurationViewControllerDidSetup:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"show home" sender:self];
    }];
}

@end
