//
//  MuseMeDelegate.h
//  MuseMe
//
//  Created by Yong Lin on 7/6/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Quartzcore/Quartzcore.h>
#import "MuseMeActivityIndicator.h"

#define KULER_YELLOW 0
#define KULER_BLACK 1
#define KULER_CYAN  2
#define KULER_WHITE 3
#define KULER_RED   4
#define BLACK_TEXT_COLOR [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1.0]


#define IDOfPollToBeShown @"IDOfPollToBeShown"
#define CURRENTUSERID @"currentUserID"
#define IS_OLD_USER @"isOldUser"
#define UNREAD_NOTIFICATION_COUNT_KEY @"unreadNotificationCount"
#define SINGLE_ACCESS_TOKEN_KEY @"singleAccessTokenKey"
#define DEVICE_TOKEN_KEY @"DeviceToken"
#define UNREAD_NOTIFICATION_COUNT_KEY @"unreadNotificationCount"



@interface MuseMeDelegate : UIResponder 

@property (strong, nonatomic) UIWindow *window;

@end
