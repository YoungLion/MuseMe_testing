//
//  CenterButtonTabController.h
//  MuseMe
//
//  Created by Yong Lin on 8/17/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utility.h"
//#import "AddToPollController.h"

@interface CenterButtonTabController : UITabBarController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, RKObjectLoaderDelegate>
@property (nonatomic, weak) UIButton* cameraButton;
@end
