//
//  VotedPollCell.m
//  MuseMe
//
//  Created by Yong Lin on 8/23/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "VotedPollCell.h"

@implementation VotedPollCell
@synthesize pollDescriptionLabel;
@synthesize votesCountLabel;
@synthesize username;
@synthesize userPhoto;
@synthesize userPhotoBackground;

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
