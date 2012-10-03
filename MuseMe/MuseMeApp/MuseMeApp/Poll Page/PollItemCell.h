//
//  PollItemCell.h
//  MuseMe
//
//  Created by Yong Lin on 7/9/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Utility.h"
#import "FollowStyleButton.h"

@interface PollItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet HJManagedImageV *itemImage;
//@property (nonatomic, weak) IBOutlet AppFormattedLabel *descriptionOfItemLabel;
//@property (nonatomic, weak) IBOutlet AppFormattedLabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *votePercentageLabel;
@property (weak, nonatomic) IBOutlet FollowStyleButton *voteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIButton *itemOperationButton;
@property (weak, nonatomic) IBOutlet UIGlossyButton *addNewItemButton;
@property (weak, nonatomic) IBOutlet UIImageView *voteCountIconView;
@property (weak, nonatomic) IBOutlet UIImageView *commentCountIconView;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIImageView *votedMark;
@property (weak, nonatomic) IBOutlet FollowStyleButton *cancelButton;


@end