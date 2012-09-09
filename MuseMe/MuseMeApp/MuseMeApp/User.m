//
//  User.m
//  BasicApp
//
//  Created by Yong Lin on 7/6/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize userID=_userID;
@synthesize fbID = _fbID;
@synthesize username=_username;
@synthesize password=_password;
@synthesize email=_email;
@synthesize passwordConfirmation = _passwordConfirmation;
@synthesize profilePhotoURL=_profilePhotoURL;
@synthesize singleAccessToken = _singleAccessToken;
@synthesize numberOfFollowers = _numberOfFollowers;
@synthesize numberOfFollowing = _numberOfFollowing;
@synthesize isFollowed = _isFollowed;
@synthesize deviceToken = _deviceToken;
@end
