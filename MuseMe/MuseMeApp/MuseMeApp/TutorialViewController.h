//
//  TutorialViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/28/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController
@property (nonatomic) int pageNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end
