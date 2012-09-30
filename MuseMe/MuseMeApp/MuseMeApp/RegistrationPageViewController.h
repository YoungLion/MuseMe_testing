//
//  RegistrationPageViewController.h
//  MuseMe
//
//  Created by Yong Lin on 7/10/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "ConfigurationViewController.h"
@interface RegistrationPageViewController : UIViewController<UITextFieldDelegate,RKObjectLoaderDelegate, ConfigurationViewControllerDelegate> //FBLoginViewDelegate

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIControl *background;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@end
