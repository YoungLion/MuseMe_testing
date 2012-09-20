//
//  Comment.h
//  MuseMe
//
//  Created by Yong Lin on 7/9/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject
@property (nonatomic, strong) User *commenter;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *commentID,*itemID,*commenterID;
@property (nonatomic, strong) NSDate *timeStamp;
@end
