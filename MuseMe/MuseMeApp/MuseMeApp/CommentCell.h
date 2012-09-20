//
//  CommentCell.h
//  MuseMe
//
//  Created by Yong Lin on 9/12/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HJManagedImageV *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet SmallFormattedLabel *timeStampLabel;
@end
