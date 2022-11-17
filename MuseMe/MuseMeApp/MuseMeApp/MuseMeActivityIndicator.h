//
//  MuseMeActivityIndicator.h
//  MuseMe
//
//  Created by Yong Lin on 9/14/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface MuseMeActivityIndicator : UIView

-(void)startAnimatingWithMessage:(NSString*)message
                          inView:(UIView*)parentView;
-(void)stopAnimating;
@end
