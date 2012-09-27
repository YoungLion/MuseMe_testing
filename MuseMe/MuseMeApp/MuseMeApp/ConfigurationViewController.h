//
//  ConfigurationViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/26/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utility.h"
@interface ConfigurationViewController : UIViewController<RKObjectLoaderDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet HJManagedImageV *profilePhoto;
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@end
