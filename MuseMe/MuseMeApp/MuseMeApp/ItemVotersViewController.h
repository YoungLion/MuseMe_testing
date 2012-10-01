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
#import "CommentCell.h"

@interface ItemVotersViewController : UITableViewController<RKObjectLoaderDelegate, UIInputToolbarDelegate>
@property (nonatomic, strong) Item* item;
@property (weak, nonatomic) IBOutlet HJManagedImageV *itemImageView;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *votesCount;
@end
