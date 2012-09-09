//
//  FBFriendsViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FBFriendsViewController.h"

@interface FBFriendsViewController ()
{
    NSArray* data;
    NSMutableArray* friends;
    User* user;
    FBRequestConnection *FBConnection;
}
@end

@implementation FBFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    FBConnection = [FBRequestConnection new];
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        [self sendRequests];
    } else {
        [FBSession openActiveSessionWithPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      // if login fails for any reason, we alert
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                          message:error.localizedDescription
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"OK"
                                                                                otherButtonTitles:nil];
                                          [alert show];
                                          // if otherwise we check to see if the session is open, an alternative to
                                          // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                          // property of the session object; the macros are useful, however, for more
                                          // detailed state checking for FBSession objects
                                      } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                          // send our requests if we successfully logged in
                                          FBRequestHandler handler =
                                          ^(FBRequestConnection *connection, id result, NSError *error) {
                                              user = [User new];
                                              user.userID = [Utility getObjectForKey:CURRENTUSERID];
                                              user.fbID = [(NSDictionary*)result objectForKey:@"id"];
                                              [[RKObjectManager sharedManager] putObject:user delegate:self];
                                          };
                                          [FBRequestConnection startForMeWithCompletionHandler:handler];
                                          [self sendRequests];
                                      }
                                  }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)sendRequests
{
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        data = [(NSDictionary*)result objectForKey:@"data"];
        friends = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (int i = 0; i < data.count; i += 1) {
            User *tempUser = [User new];
            NSDictionary* userData = [data objectAtIndex:i];
            tempUser.fbID = [userData objectForKey:@"id"];
            tempUser.username = [userData objectForKey:@"name"];
            [friends addObject:tempUser];
        }
        [[RKObjectManager sharedManager] postObject:friends usingBlock:^(RKObjectLoader *loader) {
            loader.resourcePath = @"/fb_friends";
        }];
        [self.tableView reloadData];
    };
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:handler];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RKObjectLoader delegate method
- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
    NSLog(@"user %@ connected with fbid %@", user.userID, user.fbID);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [Utility showAlert:@"Error!" message:[error localizedDescription]];
    NSLog(@"Encountered an error: %@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *friend = [friends objectAtIndex:indexPath.row];
    NSString *fbid = [friend objectForKey:@"id"];
    NSString *name = [friend objectForKey:@"name"];
    static NSString *CellIdentifier = @"fb user cell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH];
    cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    [cell.userPhoto clear];
    cell.userPhoto.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", fbid]];
    [HJObjectManager manage:cell.userPhoto];
    
    cell.usernameLabel.text = name;
    [cell.usernameLabel adjustsFontSizeToFitWidth];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_CELL_HEIGHT;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
