//
//  ItemVotersViewController.h
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "ItemVoterCell.h"

@interface ItemVotersViewController : UITableViewController
@property (nonatomic, strong) NSArray* voters;
@end
