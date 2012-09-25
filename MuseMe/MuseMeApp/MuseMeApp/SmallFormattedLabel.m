//
//  SmallFormattedLabel.m
//  MuseMe
//
//  Created by Yong Lin on 8/15/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "SmallFormattedLabel.h"
#import "Utility.h"

@implementation SmallFormattedLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Helvetica" size:9];
    self.textColor = BLACK_TEXT_COLOR;
    self.shadowColor = [UIColor whiteColor];
    self.shadowOffset = CGSizeMake(1, 1);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"Helvetica" size:9];
        self.textColor = BLACK_TEXT_COLOR;
        self.shadowColor = [UIColor whiteColor];
        self.shadowOffset = CGSizeMake(1, 1);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
