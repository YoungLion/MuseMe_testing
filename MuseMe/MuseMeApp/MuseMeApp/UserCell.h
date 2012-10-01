//
//  UserCell.h
//  MuseMe
//
//  Created by Yong Lin on 9/5/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

#define USER_CELL_HEIGHT 50

@interface UserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet HJManagedImageV *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *userPhotoBackground;

@end
