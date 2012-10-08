//
//  MuseMeActivityIndicator.m
//  MuseMe
//
//  Created by Yong Lin on 9/14/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "MuseMeActivityIndicator.h"
@interface MuseMeActivityIndicator()
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@property (nonatomic, strong) UILabel* messageDisplay;
@end

@implementation MuseMeActivityIndicator
@synthesize spinner = _spinner;
@synthesize messageDisplay = _messageDisplay;

-(void)startAnimatingWithMessage:(NSString*)message
                          inView:(UIView*)parentView
{
    self.frame = CGRectMake(0, 0, 110, 100);
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.center = CGPointMake(160, 300);
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.4);
    [_spinner startAnimating];
    [self addSubview:_spinner];
    
    _messageDisplay = [[UILabel alloc] initWithFrame:CGRectMake(21, 65, 90, 21)];
    _messageDisplay.text = message;
    _messageDisplay.font = [UIFont fontWithName:@"AmericanTypewriter" size:16.0];
    _messageDisplay.textColor  = [UIColor whiteColor];
    _messageDisplay.textAlignment = NSTextAlignmentCenter;
    _messageDisplay.adjustsFontSizeToFitWidth = YES;
    _messageDisplay.center = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.75);
    _messageDisplay.backgroundColor = [UIColor clearColor];
    [self addSubview:_messageDisplay];
    
    [parentView addSubview:self];
}

-(void)stopAnimating
{
    [UIView animateWithDuration:0.2
                     animations:^{self.alpha = 0;}
                     completion:^(BOOL finised){
                         [_spinner stopAnimating];
                         [self removeFromSuperview];
                         _spinner = nil;
                         _messageDisplay = nil;
                     }];

}

-(void)dealloc
{
    _spinner = nil;
    _messageDisplay = nil;
}
@end
