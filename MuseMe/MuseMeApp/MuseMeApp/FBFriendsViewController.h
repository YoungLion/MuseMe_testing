//
//  FBFriendsViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "UserCell.h"

@interface FBFriendsViewController : UITableViewController<RKObjectLoaderDelegate, UISearchBarDelegate, FBDialogDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
