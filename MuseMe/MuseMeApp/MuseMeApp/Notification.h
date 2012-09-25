//
//  Notification.h
//  MuseMe
//
//  Created by Yong Lin on 9/23/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Poll.h"

#define BEING_FOLLOWED_NOTIFICATION 1001
#define RECEIVED_VOTES_NOTIFICATION 1002
#define RECEIVED_COMMENTS_NOTIFICATION 1003

@interface Notification : NSObject
@property (nonatomic, strong) NSNumber* notificationID;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Poll* poll;
@property (nonatomic, strong) NSNumber* type;
@property (nonatomic, strong) NSDate* timeStamp;
@end
