//
//  CommentCell.m
//  MuseMe
//
//  Created by Yong Lin on 9/12/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell
@synthesize userPhoto;
@synthesize usernameLabel;
@synthesize commentLabel;

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
