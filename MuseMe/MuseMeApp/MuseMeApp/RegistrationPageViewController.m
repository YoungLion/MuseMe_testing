//
//  RegistrationPageViewController.m
//  MuseMe
//
//  Created by Yong Lin on 7/10/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "RegistrationPageViewController.h"
#import "MuseMeDelegate.h"
#define AnimationType 3
#define degreesToRadians(degrees) (M_PI * degrees / 180.0)

@interface RegistrationPageViewController (){
}
@property (strong, nonatomic)  MuseMeActivityIndicator *spinner;
@end

@implementation RegistrationPageViewController
@synthesize spinner = _spinner;
@synthesize startButton, stopButton;

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)animate
{
    CGRect frame = CGRectMake(0, 183, 320, 53);
    self.logoImage.frame = frame;
    
#if AnimationType == 1
    frame.origin.y = 133;
    CGFloat transitionDuration = 0.4;
    [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.logoImage.frame = frame;
        self.logoImage.alpha = 0;
    } completion:^(BOOL finished){
        CGRect frame1 = self.logoImage.frame;
        frame1.origin.y = 70;
        self.logoImage.frame = frame1;
        frame1.origin.y = 20;
        [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.logoImage.frame = frame1;
            self.logoImage.alpha = 1;
        } completion:nil];
    }];
#elif AnimationType == 2
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 216);
    self.logoImage.transform = transform;
    [UIView commitAnimations];
    
#elif AnimationType == 3
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    self.logoImage.transform = CGAffineTransformIdentity;
    self.logoImage.transform = CGAffineTransformMakeRotation(degreesToRadians(359));
    [UIView commitAnimations];
#endif
}


#pragma User Actions


- (IBAction)startAnimation {
    [self animate];
    self.spinner = [MuseMeActivityIndicator new];
    [self.spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
}

- (IBAction)stopAnimation:(id)sender {
    CGRect frame = CGRectMake(0, 183, 320, 53);
    self.logoImage.frame = frame;
    [_spinner stopAnimating];
}
@end
