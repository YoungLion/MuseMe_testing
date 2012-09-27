//
//  NotificationCell.h
//  MuseMe
//
//  Created by Yong Lin on 9/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#define NOTIFICATION_CELL_HEIGHT 55

@interface NotificationCell : UITableViewCell
@property (nonatomic, weak) IBOutlet HJManagedImageV *userImage;
@property (weak, nonatomic) IBOutlet MultipartLabel *messageLabel;
@property (nonatomic, weak) IBOutlet SmallFormattedLabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet AppFormattedLabel *pollDescriptionLabel;

@end
