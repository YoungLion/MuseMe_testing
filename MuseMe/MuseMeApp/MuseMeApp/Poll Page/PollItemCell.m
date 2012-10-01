//
//  PollItemCell.m
//  MuseMe
//
//  Created by Yong Lin on 7/9/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "PollItemCell.h"

@implementation PollItemCell
@synthesize votePercentageLabel = _votePercentageLabel;
@synthesize voteButton = _voteButton;
@synthesize deleteButton = _deleteButton;
@synthesize voteCountLabel = _voteCountLabel;
@synthesize commentCountLabel = _commentCountLabel;
@synthesize brandLabel = _brandLabel;

@synthesize itemImage=_itemImage;
@synthesize timeStampLabel = _timeStampLabel;
@synthesize background;


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
