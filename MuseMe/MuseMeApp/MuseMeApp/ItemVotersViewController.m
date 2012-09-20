//
//  ItemVotersViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ItemVotersViewController.h"
#import "ProfileTableViewController.h"
#define TableView 10
#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140
#define kDefaultTabbarHeight 49

@interface ItemVotersViewController ()
{
    User* userToBePassed;
    BOOL keyboardIsVisible;
}
@property (nonatomic, strong) UIInputToolbar* commentBar;
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@end

@implementation ItemVotersViewController
@synthesize item = _item;
@synthesize itemImageView = _itemImageView;
@synthesize commentBar = _commentBar;
@synthesize spinner = _spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    //set UIBarButtonItem background image
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _spinner = [MuseMeActivityIndicator new];
    
    keyboardIsVisible = NO;
    
    self.tableView.tag = TableView;
    
    [Utility renderView:self.itemImageView withCornerRadius:LARGE_CORNER_RADIUS andBorderWidth:LARGE_BORDER_WIDTH];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_WITH_LOGO] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    /* Listen for keyboard */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    /* Create toolbar */
    self.commentBar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kDefaultToolbarHeight, self.view.frame.size.width, kDefaultToolbarHeight)];
    self.commentBar.delegate = self;
    self.commentBar.textView.placeholder = @"Leave your comment here";
    [self.view addSubview:self.commentBar];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    [[RKObjectManager sharedManager] getObject:self.item delegate:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setItemImageView:nil];
    [super viewDidUnload];
    self.item = nil;
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
    if ([objectLoader.resourcePath hasPrefix:@"/items"]){
        [self.itemImageView clear];
        [self.itemImageView.loadingWheel startAnimating];
        self.itemImageView.url = [NSURL URLWithString:self.item.photoURL];
        [HJObjectManager manage:self.itemImageView];
        [_spinner stopAnimating];
    }else{
        [[RKObjectManager sharedManager] getObject:self.item delegate:self];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return self.item.voters.count;
    }else{
        return self.item.comments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
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
    }else{
        static NSString *CellIdentifier = @"comment cell";
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CommentCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        Comment* comment = [self.item.comments objectAtIndex:indexPath.row];
        [Utility renderView:cell.userPhoto withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH];
        cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
        if (comment.commenter.profilePhotoURL){
            [cell.userPhoto clear];
            cell.userPhoto.url = [NSURL URLWithString:comment.commenter.profilePhotoURL];
            [HJObjectManager manage:cell.userPhoto];
        }
        cell.usernameLabel.text = comment.commenter.username;
        cell.commentLabel.text = comment.content;
        [cell.commentLabel adjustHeight];
        cell.timeStampLabel.text = [Utility formatTimeWithDate:comment.timeStamp];
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return USER_CELL_HEIGHT;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    AppFormattedBoldLabel* header = [[AppFormattedBoldLabel alloc] initWithFrame:CGRectMake(5, 0, 200, 25)];
    if (section == 0){
        header.text = @"You received votes from";
    }else{
        header.text = @"Comments";
    }
    header.backgroundColor = [UIColor clearColor];
    [headerView addSubview:header];
    headerView.backgroundColor = [Utility colorFromKuler:KULER_WHITE alpha:0.8];
    
    return headerView;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        User* voter = [self.item.voters objectAtIndex:indexPath.row];
        if (voter.userID){
            userToBePassed = voter;
            [self performSegueWithIdentifier:@"show profile" sender:self];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show profile"])
    {
        ((ProfileTableViewController*)segue.destinationViewController).user = userToBePassed;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == TableView){
        [self.commentBar.textView resignFirstResponder];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == TableView){
        self.commentBar.frame = CGRectMake(0, self.view.frame.size.height-kDefaultToolbarHeight+scrollView.contentOffset.y, self.view.frame.size.width, kDefaultToolbarHeight);
        [self.view bringSubviewToFront:self.commentBar];
    }
}
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.commentBar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height - (kKeyboardHeightPortrait - kDefaultTabbarHeight) + self.tableView.contentOffset.y;
	self.commentBar.frame = frame;
	[UIView commitAnimations];
    keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.commentBar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height + self.tableView.contentOffset.y;
	self.commentBar.frame = frame;
	[UIView commitAnimations];
    keyboardIsVisible = NO;
}

-(void)inputButtonPressed:(NSString *)inputText
{
    /* Called when toolbar button is pressed */
    NSString* trimmedComment = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedComment.length > 0)
    {
        Comment* comment = [Comment new];
        comment.itemID = self.item.itemID;
        comment.commenterID = [Utility getObjectForKey:CURRENTUSERID];
        comment.content = trimmedComment;
        [[RKObjectManager sharedManager] postObject:comment delegate:self];
    }
    [self.commentBar.textView resignFirstResponder];
}

@end
