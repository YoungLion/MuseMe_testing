//
//  FriendsViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface FriendsViewController : UITableViewController<UISearchBarDelegate, RKObjectLoaderDelegate>

@property (nonatomic, strong) NSArray *filteredListContent;

// The saved state of the search UI if a memory warning removed the view.
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
