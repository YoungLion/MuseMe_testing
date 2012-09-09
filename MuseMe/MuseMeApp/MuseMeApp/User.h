//
//  User.h
//  BasicApp
//
//  Created by Yong Lin on 7/6/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSNumber *userID, *isFollowed, *fbID;
@property (nonatomic, strong) NSString *username, *password, *passwordConfirmation, *email, *singleAccessToken;
@property (nonatomic, strong) NSString *profilePhotoURL;
@property (nonatomic, strong) NSNumber *numberOfFollowing, *numberOfFollowers;
@property (nonatomic, strong) NSData *deviceToken;
@end
