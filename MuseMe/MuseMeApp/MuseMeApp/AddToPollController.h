//
//  AddToPollController.h
//  MuseMe
//
//  Created by Yong Lin on 8/26/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utility.h"
#import "NewPollViewController.h"

@interface AddToPollController : UIViewController<RKObjectLoaderDelegate,UIPickerViewDataSource, UIPickerViewDelegate,NewPollViewControllerDelegate>
@property (nonatomic, strong) UIImage *capturedItemImage;
@property (strong, nonatomic) Item *item;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

@end
