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

@interface FriendsViewController ()
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@end

@implementation FriendsViewController
@synthesize searchBar;
@synthesize filteredListContent, savedSearchTerm;
@synthesize spinner=_spinner;

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
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.color = [Utility colorFromKuler:KULER_CYAN alpha:1];
    _spinner.center = CGPointMake(160, 208);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User actions

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
}

-(void)unfollowUser:(NSNumber*)userID
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/follow_user/%@",userID] delegate:self];
}

-(void)followUser:(NSNumber*)userID
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/unfollow_user/%@",userID] delegate:self];
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
        [cell.userPhoto showLoadingWheel];
        cell.userPhoto.url = [NSURL URLWithString:user.profilePhotoURL];
        [HJObjectManager manage:cell.userPhoto];
    }
    
    cell.usernameLabel.text = user.username;
    [cell.usernameLabel adjustHeight];
    
    if (user.isFollowed.boolValue){
        cell.followButton.titleLabel.text = @"Unfollow";
    }else{
        cell.followButton.titleLabel.text = @"Follow";
    }
    
    [cell.followButton setNeedsLayout];
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
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - Search Bar delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/user_search/%@", searchText] delegate:self];
        [_spinner startAnimating];
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
