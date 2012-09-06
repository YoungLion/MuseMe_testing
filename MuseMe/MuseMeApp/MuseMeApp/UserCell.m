//
//  UserCell.m
//  MuseMe
//
//  Created by Yong Lin on 9/5/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell
@synthesize userPhoto;
@synthesize usernameLabel;
@synthesize followButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
