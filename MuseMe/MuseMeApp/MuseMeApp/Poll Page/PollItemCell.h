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

@interface PollItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet HJManagedImageV *itemImage;
//@property (nonatomic, weak) IBOutlet AppFormattedLabel *descriptionOfItemLabel;
//@property (nonatomic, weak) IBOutlet AppFormattedLabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *votePercentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *voteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
//@property (weak, nonatomic) IBOutlet AppFormattedLabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

@end