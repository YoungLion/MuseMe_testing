//
//  Relationship.h
//  MuseMe
//
//  Created by Yong Lin on 9/5/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Relationship : NSObject
@property (nonatomic, strong) NSNumber* followedID;
@property (nonatomic, strong) NSNumber* followerID;
@end
