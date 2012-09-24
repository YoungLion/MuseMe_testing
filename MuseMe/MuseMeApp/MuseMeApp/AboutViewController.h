//
//  AboutViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/23/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Tools.h"
#import "UIView+Layout.h"
#import "FTCoreTextView.h"
#import "Utility.h"
#import <CoreText/CoreText.h>

@interface AboutViewController : UIViewController<FTCoreTextViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end
