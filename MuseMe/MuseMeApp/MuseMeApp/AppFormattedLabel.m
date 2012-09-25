//
//  AppFormattedLabel.m
//  MuseMe
//
//  Created by Yong Lin on 8/12/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "AppFormattedLabel.h"
#import "Utility.h"

@implementation AppFormattedLabel
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"AmericanTypewriter" size:self.font.pointSize];
    self.textColor = BLACK_TEXT_COLOR;
    self.shadowColor = [UIColor whiteColor];
    self.shadowOffset =CGSizeMake(1, 1);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"AmericanTypewriter" size:self.font.pointSize];
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
