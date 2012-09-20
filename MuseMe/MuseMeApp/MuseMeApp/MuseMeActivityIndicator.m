//
//  MuseMeActivityIndicator.m
//  MuseMe
//
//  Created by Yong Lin on 9/14/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "MuseMeActivityIndicator.h"
#import "Utility.h"
@interface MuseMeActivityIndicator()
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@property (nonatomic, strong) UILabel* messageDisplay;
@property (nonatomic, strong) UIView* screenForBlockingUI;
@end

@implementation MuseMeActivityIndicator
@synthesize spinner = _spinner;
@synthesize messageDisplay = _messageDisplay;
@synthesize screenForBlockingUI = _screenForBlockingUI;

-(void)startAnimatingWithMessage:(NSString*)message
                          inView:(UIView*)parentView
{
    self.frame = CGRectMake(0, 0, 110, 100);
    self.backgroundColor = [Utility colorFromKuler:KULER_BLACK alpha:0.7];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.center = CGPointMake(160, 208);
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.4);
    [_spinner startAnimating];
    [self addSubview:_spinner];
    
    _messageDisplay = [[UILabel alloc] initWithFrame:CGRectMake(21, 65, 90, 21)];
    _messageDisplay.text = message;
    _messageDisplay.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    _messageDisplay.textColor  = [UIColor whiteColor];
    _messageDisplay.adjustsFontSizeToFitWidth = YES;
    _messageDisplay.center = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.75);
    _messageDisplay.backgroundColor = [UIColor clearColor];
    [self addSubview:_messageDisplay];
    

    
    _screenForBlockingUI = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    [parentView addSubview:self];
    [parentView addSubview:_screenForBlockingUI];
}

-(void)stopAnimating
{
    [_spinner stopAnimating];
    [self removeFromSuperview];
    [_screenForBlockingUI removeFromSuperview];
    _spinner = nil;
    _messageDisplay = nil;
    _screenForBlockingUI = nil;
}

-(void)dealloc
{
    _spinner = nil;
    _messageDisplay = nil;
    _screenForBlockingUI = nil;
}
@end
