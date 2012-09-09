//
//  ItemVotersViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ItemVotersViewController.h"
#import "ProfileTableViewController.h"

@interface ItemVotersViewController ()
{
    User* userToBePassed;
}
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@end

@implementation ItemVotersViewController
@synthesize item = _item;
@synthesize spinner = _spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    //set UIBarButtonItem background image
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.color = [Utility colorFromKuler:KULER_CYAN alpha:1];
    _spinner.center = CGPointMake(160, 208);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_WITH_LOGO] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_spinner startAnimating];
    [[RKObjectManager sharedManager] getObject:self.item delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.item = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User actions
- (IBAction)backButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonPressed:(id)sender {
    UserCell* cell = (UserCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    User* user = (User*)[self.item.voters objectAtIndex:indexPath.row];
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

#pragma mark - RKObjectLoader delegate method
- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [_spinner stopAnimating];
    [self.tableView reloadData];
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [Utility showAlert:@"Sorry!" message:error.localizedDescription];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.item.voters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"voter cell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    User* voter = (User*)[self.item.voters objectAtIndex:indexPath.row];
    [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH];
    cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    if (voter.profilePhotoURL){
        [cell.userPhoto clear];
        cell.userPhoto.url = [NSURL URLWithString:voter.profilePhotoURL];
        [HJObjectManager manage:cell.userPhoto];
    }
    
    cell.usernameLabel.text = voter.username;
    [cell.usernameLabel adjustHeight];
    if ([[Utility getObjectForKey:CURRENTUSERID] isEqualToNumber:voter.userID])
    {
        cell.followButton.enabled = NO;
        [cell.followButton setTitle:@"Me" forState:UIControlStateDisabled];
    }else{
        cell.followButton.enabled = YES;
        if (voter.isFollowed.boolValue){
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
    User* voter = [self.item.voters objectAtIndex:indexPath.row];
    if (voter.userID){
        userToBePassed = voter;
        [self performSegueWithIdentifier:@"show profile" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show profile"])
    {
        ((ProfileTableViewController*)segue.destinationViewController).user = userToBePassed;
    }
}
@end
