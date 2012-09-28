//
//  MuseMeDelegate.m
//  MuseMe
//
//  Created by Yong Lin on 7/6/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import "MuseMeDelegate.h"

NSString *const FBSessionStateChangedNotification =
@"com.museme.MuseMeDev:FBSessionStateChangedNotification";

@implementation MuseMeDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    // Initialize the RestKit Object Manager
	[RKObjectManager managerWithBaseURLString:BaseURL];
    [RKObjectManager sharedManager].serializationMIMEType = RKMIMETypeJSON;
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    
    // Class:SingleValue
    RKObjectMapping* valueMapping = [RKObjectMapping mappingForClass:[SingleValue class]];
    [valueMapping mapAttributes:@"string", @"number",nil];
    
    [[RKObjectManager sharedManager].mappingProvider registerMapping:valueMapping withRootKeyPath:@"single_value"];
    
    // Class:User
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping mapKeyPathsToAttributes:
     @"id", @"userID",
     @"fb_id", @"fbID",
     @"user_name", @"username",
     @"password", @"password",
     @"email", @"email",
     @"password_confirmation", @"passwordConfirmation",
     @"profile_photo_url", @"profilePhotoURL",
     @"single_access_token", @"singleAccessToken",
     @"number_of_following", @"numberOfFollowing",
     @"number_of_followers", @"numberOfFollowers",
     @"is_followed",@"isFollowed",
     @"device_token", @"deviceToken",
     @"photo", @"photo",
     nil];
    
    [[RKObjectManager sharedManager].mappingProvider registerMapping:userMapping withRootKeyPath:@"user"];
    
    // Class:UserGroup
    RKObjectMapping* userGroupMapping = [RKObjectMapping mappingForClass:[UserGroup class]];
    [userGroupMapping mapRelationship:@"users" withMapping:userMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:userGroupMapping withRootKeyPath:@"users"];
    
    // Class:PollRecord
    RKObjectMapping* pollRecordMapping = [RKObjectMapping mappingForClass:[PollRecord class]];
    [pollRecordMapping setPreferredDateFormatter:dateFormatter];
    [pollRecordMapping mapKeyPathsToAttributes:
     @"poll_id", @"pollID",
     @"user_id", @"userID",
     @"total_votes", @"totalVotes",
     @"poll_record_type", @"pollRecordType",
     @"title", @"title",
     @"state", @"state",
     @"start_time", @"startTime",
     @"end_time", @"endTime",
     @"open_time", @"openTime",
     @"items_count", @"itemsCount",
     nil];
    [pollRecordMapping mapRelationship:@"owner" withMapping:userMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:pollRecordMapping withRootKeyPath:@"poll_record"];
    
    // Class:Audience
    RKObjectMapping* audienceMapping = [RKObjectMapping mappingForClass:[Audience class]];
    //userMapping.primaryKeyAttribute = @"userID";
    audienceMapping.setDefaultValueForMissingAttributes = YES; // clear out any missing attributes (token on logout)
    [audienceMapping mapKeyPathsToAttributes:
     @"id", @"audienceID",
     @"user_id", @"userID",
     @"has_voted", @"hasVoted",
     @"is_following", @"isFollowing",
     @"user_name", @"username",
     @"profile_Photo_url", @"profilePhotoURL",
     @"poll_id", @"pollID",
     nil];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:audienceMapping withRootKeyPath:@"audience"];
    
    // Class:Comment
    RKObjectMapping* commentMapping = [RKObjectMapping mappingForClass:[Comment class]];
    [commentMapping mapKeyPathsToAttributes:
     @"id", @"commentID",
     @"item_id", @"itemID",
     @"content", @"content",
     @"created_at", @"timeStamp",
     @"commenter_id", @"commenterID",
     nil];
    [commentMapping mapRelationship:@"commenter" withMapping:userMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:commentMapping withRootKeyPath:@"comment"];
    
    // Class:Item
    RKObjectMapping* itemMapping = [RKObjectMapping mappingForClass:[Item class]];
    [itemMapping mapKeyPathsToAttributes:
     @"id", @"itemID",
     @"description", @"description",
     @"price", @"price",
     @"number_of_votes", @"numberOfVotes",
     @"photo_url", @"photoURL",
     @"poll_id", @"pollID",
     @"brand", @"brand",
     @"created_at", @"addedTime",
     @"photo", @"photo",
     @"number_of_comments", @"numberOfComments",
     nil];
    [itemMapping mapRelationship:@"comments" withMapping:commentMapping];
    [itemMapping mapRelationship:@"voters" withMapping:userMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:itemMapping withRootKeyPath:@"item"];
    
    // Class:Poll
    RKObjectMapping* pollMapping = [RKObjectMapping mappingForClass:[Poll class]];
    [pollMapping setPreferredDateFormatter:dateFormatter];
    [pollMapping mapKeyPathsToAttributes:
     @"id", @"pollID",
     @"user_id", @"ownerID",
     @"total_votes", @"totalVotes",
     @"title", @"title",
     @"state", @"state",
     @"start_time", @"startTime",
     @"end_time", @"endTime",
     @"category", @"category",
     @"open_time", @"openTime",
     nil];
    [pollMapping mapRelationship:@"user" withMapping:userMapping];
    [pollMapping mapRelationship:@"items" withMapping:itemMapping];
    [pollMapping mapRelationship:@"audiences" withMapping:audienceMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:pollMapping withRootKeyPath:@"poll"];
    
    // Class:Notification
    RKObjectMapping* notificationMapping = [RKObjectMapping mappingForClass:[Notification class]];
    [notificationMapping setPreferredDateFormatter:dateFormatter];
    [notificationMapping mapKeyPathsToAttributes:
     @"id", @"notificationID",
     @"created_at", @"timeStamp",
     @"notification_type", @"type",
     nil];
    [notificationMapping mapRelationship:@"user" withMapping:userMapping];
    [notificationMapping mapRelationship:@"poll" withMapping:pollMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:notificationMapping withRootKeyPath:@"notification"];
    
    // Class:Event
    RKObjectMapping* eventMapping = [RKObjectMapping mappingForClass:[Event class]];
    [eventMapping mapKeyPathsToAttributes:
     @"id", @"eventID",
    // @"event_type", @"eventType",
     @"user_id", @"userID",
     @"poll_id", @"pollID",
    // @"item_id", @"itemID",
     @"created_at", @"timeStamp",
     nil];
    [eventMapping mapRelationship:@"user" withMapping:userMapping];
    //[eventMapping mapKeyPath:@"poll_owner" toRelationship:@"pollOwner" withMapping:userMapping];
    [eventMapping mapRelationship:@"poll" withMapping:pollMapping];
    [eventMapping mapRelationship:@"items" withMapping:itemMapping];
    [[RKObjectManager sharedManager].mappingProvider registerMapping:eventMapping withRootKeyPath:@"event"];

    
    [[RKObjectManager sharedManager].router routeClass:[User class] toResourcePath:@"/users/:userID"];
	[[RKObjectManager sharedManager].router routeClass:[User class] toResourcePath:@"/signup" forMethod:RKRequestMethodPOST];
    
    [[RKObjectManager sharedManager].router routeClass:[UserGroup class] toResourcePath:@"/fb_friends"];
    
    [[RKObjectManager sharedManager].router routeClass:[PollRecord class] toResourcePath:@"/poll_records/:pollID"];
	[[RKObjectManager sharedManager].router routeClass:[PollRecord class] toResourcePath:@"/poll_records" forMethod:RKRequestMethodPOST];
    
    [[RKObjectManager sharedManager].router routeClass:[Poll class] toResourcePath:@"/polls/:pollID"];
    [[RKObjectManager sharedManager].router routeClass:[Poll class] toResourcePath:@"/polls" forMethod:RKRequestMethodPOST];
    
    [[RKObjectManager sharedManager].router routeClass:[Comment class] toResourcePath:@"/comments/:commentID"];
    [[RKObjectManager sharedManager].router routeClass:[Comment class] toResourcePath:@"/comments" forMethod:RKRequestMethodPOST];
    
    [[RKObjectManager sharedManager].router routeClass:[Item class] toResourcePath:@"/items/:itemID"];
    [[RKObjectManager sharedManager].router routeClass:[Item class] toResourcePath:@"/items" forMethod:RKRequestMethodPOST];
    
    [[RKObjectManager sharedManager].router routeClass:[Event class] toResourcePath:@"/events/:eventID"];
    [[RKObjectManager sharedManager].router routeClass:[Event class] toResourcePath:@"/events" forMethod:RKRequestMethodPOST];
    
    
    [[RKObjectManager sharedManager].router routeClass:[Audience class] toResourcePath:@"/audiences/:audienceID"];
    [[RKObjectManager sharedManager].router routeClass:[Audience class] toResourcePath:@"/audiences" forMethod:RKRequestMethodPOST];
    

    // Override point for customization after application launch.
    
    
    // Create the object manager
  
    HJObjectManager = [[HJObjManager alloc] initWithLoadingBufferSize:6 memCacheSize:1];
	
	//if you are using for full screen images, you'll need a smaller memory cache than the defaults,
	//otherwise the cached images will get you out of memory quickly
	//objMan = [[HJObjManager alloc] initWithLoadingBufferSize:6 memCacheSize:1];
	
	// Create a file cache for the object manager to use
	// A real app might do this durring startup, allowing the object manager and cache to be shared by several screens
	NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/"] ;
	HJMOFileCache* fileCache = [[HJMOFileCache alloc] initWithRootPath:cacheDirectory];
	HJObjectManager.fileCache = fileCache;
    [HJObjectManager.fileCache emptyCache];
	
	// Have the file cache trim itself down to a size & age limit, so it doesn't grow forever
	fileCache.fileCountLimit = 100;
	fileCache.fileAgeLimit = 60*60*24*7; //1 week
	[fileCache trimCacheUsingBackgroundThread];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // this means the user switched back to this app without completing
    // a login in Safari/Facebook App
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [RKClient setSharedClient:nil];
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Utility setObject:deviceTokenString forKey:DEVICE_TOKEN_KEY];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                
                // Initiate a Facebook instance
                self.facebook = [[Facebook alloc]
                                 initWithAppId:FBSession.activeSession.appID
                                 andDelegate:nil];
                
                // Store the Facebook session information
                self.facebook.accessToken = FBSession.activeSession.accessToken;
                self.facebook.expirationDate = FBSession.activeSession.expirationDate;
                
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            // Clear out the Facebook instance
            self.facebook = nil;
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        NSLog(@"Error: %@",error);
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = nil;
    /*[[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_photos",
                            nil];*/
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

@end
