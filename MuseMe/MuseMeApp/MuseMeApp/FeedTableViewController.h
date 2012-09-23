//
//  FeedTableViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "FeedsCell.h"
#import "NewPollViewController.h"

@interface FeedTableViewController : UITableViewController<RKObjectLoaderDelegate, NewPollViewControllerDelegate>

@end
