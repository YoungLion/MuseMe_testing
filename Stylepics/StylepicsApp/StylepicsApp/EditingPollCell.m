//
//  EditingPollCell.m
//  MuseMe
//
//  Created by Yong Lin on 8/23/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "EditingPollCell.h"

@implementation EditingPollCell
@synthesize pollDescriptionLabel;
@synthesize itemCountLabel;
@synthesize startTimeLabel;

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
