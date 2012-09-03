//
//  ItemVoterCell.h
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@interface ItemVoterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HJManagedImageV *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end
