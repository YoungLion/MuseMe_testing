//
//  ProfileTableViewController.h
//  MuseMe
//
//  Created by Yong Lin on 7/13/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditingPollCell.h"
#import "OpenedPollCell.h"
#import "VotedPollCell.h"
#import "Utility.h"
#import "NewPollViewController.h"
#define FOLLOWING 0
#define FOLLOWERS 1

@interface ProfileTableViewController : UITableViewController<RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet HJManagedImageV *userPhoto;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *usernameLabel;
@property (strong, nonatomic) User* user;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *editingPollCountLabel;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *openedPollCountLabel;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *votedPollCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *editingPollButton;
@property (weak, nonatomic) IBOutlet UIButton *activePollButton;
@property (weak, nonatomic) IBOutlet UIButton *votedPollButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@end
