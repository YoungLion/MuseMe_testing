//
//  FeedsCell.h
//  MuseMe
//
//  Created by Yong Lin on 8/23/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

#define FEED_CELL_HEIGHT 400
#define CELL_BOTTOM_MARGIN 10

@interface FeedsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet HJManagedImageV *userImage;
@property (nonatomic, weak) IBOutlet UILabel *eventDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalVotes;
@property (nonatomic, weak) IBOutlet SmallFormattedLabel *timeStampLabel;
@property (nonatomic, weak) IBOutlet UIImageView
*categoryIcon;

@property (weak, nonatomic) IBOutlet MultipartLabel *usernameAndActionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *upperContainer;

@property (nonatomic, weak) IBOutlet HJManagedImageV *thumbnail0;
@property (nonatomic, weak) IBOutlet HJManagedImageV *thumbnail1;
@property (nonatomic, weak) IBOutlet HJManagedImageV *thumbnail2;
@property (nonatomic, weak) IBOutlet HJManagedImageV *thumbnail3;
@property (nonatomic, weak) IBOutlet HJManagedImageV *thumbnail4;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picContainerImageView;
@property (weak, nonatomic) IBOutlet UIView *picContainer;
@property (weak, nonatomic) IBOutlet UIView *background0;
@property (weak, nonatomic) IBOutlet UIView *background1;
@property (weak, nonatomic) IBOutlet UIView *background2;
@property (weak, nonatomic) IBOutlet UIView *background3;
@property (weak, nonatomic) IBOutlet UIView *userPhotoBackground;

//@property (weak, nonatomic) IBOutlet UIImageView *picFrameImageView;
@end
