//
//  TutorialViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/28/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import "TutorialViewController.h"
#import "ConfigurationViewController.h"
#import "Utility.h"
static NSUInteger kNumberOfPages = 6;

@interface TutorialViewController ()

@end

@implementation TutorialViewController
@synthesize pageNumber = _pageNumber;
@synthesize imageView = _imageView;
@synthesize nextButton = _nextButton;
@synthesize previousButton = _previousButton;
@synthesize startButton = _startButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    if (_pageNumber == kNumberOfPages - 1){
        self.nextButton.hidden = YES;
    }else {
        if (_pageNumber == 0) {
            self.previousButton.hidden = YES;
            /*[UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                _scrollView.alpha = 1;
            } completion:nil];*/
        }
        self.startButton.hidden = YES;
    }
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"instruction-page-%d", _pageNumber]];
}


- (IBAction)nextPage:(id)sender {
    TutorialViewController* VC= [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial VC"];
    VC.pageNumber = _pageNumber + 1;
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)previousPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)endTutorial:(id)sender {
    [(ConfigurationViewController*)[[self.navigationController viewControllers] objectAtIndex:0] startMuseMe];
}
@end
