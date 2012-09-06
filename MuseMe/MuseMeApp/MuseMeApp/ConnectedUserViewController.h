//
//  ConnectedUserViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileTableViewController.h"
#import "Utility.h"

@interface ConnectedUserViewController : UITableViewController<RKObjectLoaderDelegate>
@property (nonatomic) int userConnectionType;
@property (nonatomic, strong) User* user;
@end
