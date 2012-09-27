//
//  AppFormattedTextView.m
//  MuseMe
//
//  Created by Yong Lin on 9/26/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "AppFormattedTextView.h"

@implementation AppFormattedTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"AmericanTypewriter" size:self.font.pointSize];
    self.textColor = BLACK_TEXT_COLOR;
    self.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 1.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"AmericanTypewriter" size:self.font.pointSize];
        self.textColor = BLACK_TEXT_COLOR;
        self.layer.shadowColor = [[UIColor whiteColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.layer.shadowOpacity = 1.0f;
        self.layer.shadowRadius = 1.0f;
    }
    return self;
}

@end
