//
//  NameLabel.m
//  MuseMe
//
//  Created by Yong Lin on 8/26/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "NameLabel.h"
#import "Utility.h"

@implementation NameLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Calibri-Bold" size:self.font.pointSize];
    self.textColor = BLACK_TEXT_COLOR;
    self.shadowColor = [UIColor whiteColor];
    self.shadowOffset =CGSizeMake(1, 1);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"Calibri-Bold" size:self.font.pointSize];
        self.textColor = BLACK_TEXT_COLOR;
        self.shadowColor = [UIColor whiteColor];
        self.shadowOffset =CGSizeMake(1, 1);
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
