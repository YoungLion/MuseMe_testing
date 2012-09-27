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
    UserGroup* users;
    FBRequestConnection *FBConnection;
    MuseMeDelegate *appDelegate;
}
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@property (nonatomic, strong) NSMutableArray* filteredListContent;
@end

@implementation FBFriendsViewController
@synthesize searchBar = _searchBar;
@synthesize spinner = _spinner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _spinner = [MuseMeActivityIndicator new];
    
    self.searchBar.delegate = self;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
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
                                      [appDelegate sessionStateChanged:session state:status error:error];
                                      if ((!error) && FB_ISSESSIONOPENWITHSTATE(status)) {
                                          // send our requests if we successfully logged in
                                          FBRequestHandler handler =
                                          ^(FBRequestConnection *connection, id result, NSError *error) {
                                              User* user = [User new];
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
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Actions
-(void)sendRequests
{
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"received from facebook: %@", result);
        data = [(NSDictionary*)result objectForKey:@"data"];
        friends = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (int i = 0; i < data.count; i += 1) {
            User *tempUser = [User new];
            NSDictionary* userData = [data objectAtIndex:i];
            tempUser.fbID = [userData objectForKey:@"id"];
            tempUser.username = [userData objectForKey:@"name"];
            [friends addObject:tempUser];
        }
        users = [UserGroup new];
        users.users = [friends copy];
        [[RKObjectManager sharedManager] postObject:users delegate:self];
    };
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:handler];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonPressed:(UIButton*)sender {
    UserCell* cell = (UserCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    User* user;
    if (self.filteredListContent){
        user = [self.filteredListContent objectAtIndex:indexPath.row];
    }else
    {
        user = [users.users objectAtIndex:indexPath.row];
    }
    if (user.isFollowed){
        if (user.isFollowed.boolValue){
            [self unfollowUser:user.userID];
        }else{
            [self followUser:user.userID];
        }
        user.isFollowed = [NSNumber numberWithBool:!(user.isFollowed.boolValue)];
    }else{
        [self inviteFBUser:user.fbID];
        sender.enabled = NO;
        [sender setTitle:@"Invited" forState:UIControlStateDisabled];
    }
    [self.tableView reloadData];
}

-(void)unfollowUser:(NSNumber*)userID
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/unfollow_user/%@",userID] delegate:self];
}

-(void)followUser:(NSNumber*)userID
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/follow_user/%@",userID] delegate:self];
}

-(void)inviteFBUser:(NSNumber*)fbID
{
    if (FBSession.activeSession.isOpen){
        
        Facebook* facebook = appDelegate.facebook;
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Check out this awesome app.",  @"message",
                                       /*[NSString stringWithFormat:@"%@",fbID]*/@"1702730384", @"to",
                                       nil];
        [facebook dialog:@"apprequests"
               andParams:params
             andDelegate:self];
    }
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
    
    if ([objectLoader.resourcePath hasPrefix:@"/fb_friends"]){
        [self.tableView reloadData];
    }else{
       NSLog(@"user %@ connected with fbid %@", ((User*)(objectLoader.sourceObject)).userID, ((User*)(objectLoader.sourceObject)).fbID);
    }
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
    if (self.filteredListContent)
    {
        return self.filteredListContent.count;
    }else{
        return users.users.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User* friend;
    if (self.filteredListContent) {
        friend = [self.filteredListContent objectAtIndex:indexPath.row];
    }else{
        friend = [users.users objectAtIndex:indexPath.row];
    }
    static NSString *CellIdentifier = @"fb user cell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
    cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    [cell.userPhoto clear];
    if (!friend.profilePhotoURL) {friend.profilePhotoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", friend.fbID];}
    cell.userPhoto.url = [NSURL URLWithString:friend.profilePhotoURL];
    [HJObjectManager manage:cell.userPhoto];
    
    if (!friend.userID) {
        [cell.followButton setTitle:@"Invite" forState:UIControlStateNormal];
    }else{
        if (friend.isFollowed.boolValue){
            [cell.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }else{
            [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    
    cell.usernameLabel.text = friend.username;
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

#pragma mark - Search Bar delegate
- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    [_spinner startAnimatingWithMessage:@"Search..." inView:self.view];
    self.filteredListContent = [NSMutableArray new];
    for (User *friend in users.users)
	{
        NSRange result = [friend.username rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        if (result.location != NSNotFound)
        {
            [self.filteredListContent addObject:friend];
        }
	}
    [_spinner stopAnimating];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        [self filterContentForSearchText:searchText];
        [self.tableView reloadData];
    }else{
        self.filteredListContent = nil;
        [self.tableView reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    NSLog(@"clicked");
    [theSearchBar resignFirstResponder];
}
@end
