//
//  FollowStyleButton.m
//  MuseMe
//
//  Created by Yong Lin on 9/23/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FollowStyleButton.h"
#import "Utility.h"

@implementation FollowStyleButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setNavigationButtonWithColor:[Utility colorFromKuler:KULER_CYAN alpha:1]];
    self.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:14];
    self.titleLabel.textColor = BLACK_TEXT_COLOR;
    self.titleLabel.shadowColor = [UIColor whiteColor];
    self.titleLabel.shadowOffset =CGSizeMake(1, 1);
    self.buttonCornerRadius = 12.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setNavigationButtonWithColor:[Utility colorFromKuler:KULER_CYAN alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:14];
        self.titleLabel.textColor = BLACK_TEXT_COLOR;
        self.titleLabel.shadowColor = [UIColor whiteColor];
        self.titleLabel.shadowOffset =CGSizeMake(1, 1);
        self.buttonCornerRadius = 12.0f;
    }
    return self;
}

@end
