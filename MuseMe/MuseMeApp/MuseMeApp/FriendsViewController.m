//
//  FriendsViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FriendsViewController.h"
#import "UserCell.h"
#import "ProfileTableViewController.h"

@interface FriendsViewController (){
    id<FBGraphUser> fbUser;
}
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@end

@implementation FriendsViewController
@synthesize searchBar;
@synthesize filteredListContent, savedSearchTerm;
@synthesize spinner=_spinner;
@synthesize loginView = _loginView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchBar setText:savedSearchTerm];
        self.savedSearchTerm = nil;
    }
    
    _spinner = [MuseMeActivityIndicator new];
    self.searchBar.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    self.filteredListContent = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // save the state of the search UI so that it can be restored if the view is re-created
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User actions

- (IBAction)showFacebookFriends {
    [self performSegueWithIdentifier:@"show FB friends" sender:self];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonPressed:(id)sender {
    UserCell* cell = (UserCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    User* user = (User*)[self.filteredListContent objectAtIndex:indexPath.row];
    if (user.isFollowed.boolValue){
        [self unfollowUser:user.userID];
    }else{
        [self followUser:user.userID];
    }
    user.isFollowed = [NSNumber numberWithBool:!(user.isFollowed.boolValue)];
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

#pragma mark - RKObjectLoader delegate

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    if ([objectLoader.resourcePath hasPrefix:@"/user_search"]){
        self.filteredListContent = objects;
        [_spinner stopAnimating];
    }
    [self.tableView reloadData];
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [Utility showAlert:@"Sorry!" message:error.localizedDescription];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredListContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"user cell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }

    User* user = (User*)[self.filteredListContent objectAtIndex:indexPath.row];
    
    [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH];
    cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    if (user.profilePhotoURL){
        [cell.userPhoto clear];
        cell.userPhoto.url = [NSURL URLWithString:user.profilePhotoURL];
        [HJObjectManager manage:cell.userPhoto];
    }
    
    cell.usernameLabel.text = user.username;
    [cell.usernameLabel adjustHeight];
    
    if ([[Utility getObjectForKey:CURRENTUSERID] isEqualToNumber:user.userID])
    {
        cell.followButton.enabled = NO;
        [cell.followButton setTitle:@"Me" forState:UIControlStateDisabled];
    }else{
        cell.followButton.enabled = YES;
        if (user.isFollowed.boolValue){
            [cell.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }else{
            [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    
    [cell.followButton sizeToFit];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return USER_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profile page"];
    profileVC.user = [self.filteredListContent objectAtIndex:indexPath.row];
    profileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - Search Bar delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/user_search/%@", searchText] delegate:self];
        [_spinner startAnimatingWithMessage:@"Searching..." inView:self.view];
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
