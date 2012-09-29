//
//  InfoDisplayViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/28/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import "InfoDisplayViewController.h"

@interface InfoDisplayViewController ()

@end

@implementation InfoDisplayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
