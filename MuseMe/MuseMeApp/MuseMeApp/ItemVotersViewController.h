//
//  ItemVotersViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "UserCell.h"

@interface ItemVotersViewController : UITableViewController<RKObjectLoaderDelegate>
@property (nonatomic, strong) Item* item;
@end
