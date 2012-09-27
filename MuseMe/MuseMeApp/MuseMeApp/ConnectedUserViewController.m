//
//  ConnectedUserViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ConnectedUserViewController.h"
#import "UserCell.h"

@interface ConnectedUserViewController ()
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@property (nonatomic, strong) NSArray* users;
@end

@implementation ConnectedUserViewController

@synthesize spinner=_spinner;
@synthesize users = _users;
@synthesize user = _user;
@synthesize userConnectionType = _userConnectionType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _spinner = [MuseMeActivityIndicator new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((CenterButtonTabController*)self.tabBarController).cameraButton.alpha = 0;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    NSString* resourcePath;
    NSLog(@"_userConnectionType = %d",self.userConnectionType );
    if (self.userConnectionType == FOLLOWING){
        resourcePath = [NSString stringWithFormat:@"/following_of_user/%@", _user.userID];
    }else if (self.userConnectionType == FOLLOWERS){
        resourcePath = [NSString stringWithFormat:@"/followers_of_user/%@", _user.userID];
    }
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:resourcePath delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.users = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonPressed:(id)sender {
    UserCell* cell = (UserCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    User* user = (User*)[self.users objectAtIndex:indexPath.row];
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
        NSLog(@"resource path:%@", request.resourcePath);
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    if ([objectLoader.resourcePath hasPrefix:@"/following_of_user"]||[objectLoader.resourcePath hasPrefix:@"/followers_of_user"]){
        self.users = objects;
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
    return [self.users count];
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
    
    User* user = (User*)[self.users objectAtIndex:indexPath.row];
    
    [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
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
        [cell.followButton setTitle:@"It's me" forState:UIControlStateDisabled];
    }else{
        cell.followButton.enabled = YES;
        if (user.isFollowed.boolValue){
            [cell.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }else{
            [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return USER_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profile page"];
    profileVC.user = [self.users objectAtIndex:indexPath.row];
    profileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
