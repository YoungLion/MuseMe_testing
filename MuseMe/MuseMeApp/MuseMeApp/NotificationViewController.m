//
//  NotificationViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"
#import "ProfileTableViewController.h"
@interface NotificationViewController ()
{
    BOOL isLoading;
    User* userToBePassed;
}
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@property (nonatomic, strong) NSMutableArray* notifications;
@end

@implementation NotificationViewController

@synthesize spinner = _spinner;
@synthesize notifications = _notifications;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.notifications = [NSMutableArray new];
    isLoading = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    self.tabBarController.tabBar.alpha = 1;
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_WITH_LOGO] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    /*self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:LOGO]];
     self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
     CGRect frame = self.navigationItem.titleView.frame;
     frame.size.height = 40;
     frame.size.width = 140;
     self.navigationItem.titleView.frame = frame;*/
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    ((CenterButtonTabController*)self.tabBarController).cameraButton.alpha = 1;
    _spinner = [MuseMeActivityIndicator new];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/notifications/0" delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

#pragma mark - User Actions
- (IBAction)showUserProfile:(id)sender {
    NotificationCell *cell = (NotificationCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
    [Utility setObject:notification.poll.pollID forKey:IDOfPollToBeShown];
    userToBePassed = notification.user;
    [self performSegueWithIdentifier:@"show profile" sender:self];
}

#pragma mark - RKObjectLoader Delegate Methods

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
    if ([objectLoader.resourcePath hasPrefix:@"/notifications"]){
        if ([objectLoader.resourcePath hasPrefix:@"/notifications/0"]){
            self.notifications = [objects mutableCopy];
        }else{
            [self.notifications addObjectsFromArray:objects];
        }
        [_spinner stopAnimating];
        _spinner = nil;
        
        [self.tableView reloadData];
        isLoading = NO;
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"notification cell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[NotificationCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    [Utility renderView:cell.userImage withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH ];
    
    cell.userImage.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    
    [cell.messageLabel updateNumberOfLabels:2];
    [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:0];

    if (notification.type.intValue == BEING_FOLLOWED_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:2];
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:0];
        [cell.messageLabel setText:@" started following you." andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
    }else if (notification.type.intValue == RECEIVED_VOTES_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:3];
        
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:0];
        
        [cell.messageLabel setText:@" voted in your poll:" andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
        
        [cell.messageLabel setText:notification.poll.title andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:2];
        [[cell.messageLabel.labels objectAtIndex:2] adjustHeight];
    }else if (notification.type.intValue == RECEIVED_COMMENTS_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:3];
        
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:0];
        
        [cell.messageLabel setText:@" commented in your poll:" andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
        
        [cell.messageLabel setText:notification.poll.title andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:2];
        [[cell.messageLabel.labels objectAtIndex:2] adjustHeight];
    }
    
    if (notification.user.profilePhotoURL){
        [cell.userImage clear];
        [cell.userImage showLoadingWheel];
        cell.userImage.url = [NSURL URLWithString:notification.user.profilePhotoURL];
        [HJObjectManager manage:cell.userImage];
    }
    
    cell.timeStampLabel.text = [Utility formatTimeWithDate:notification.timeStamp];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
    if (notification.type.intValue ==RECEIVED_VOTES_NOTIFICATION)
    {
        [self performSegueWithIdentifier:@"show poll" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show profile"])
    {
        ProfileTableViewController* profileVC =(ProfileTableViewController*)segue.destinationViewController;
        profileVC.user = userToBePassed;
        profileVC.hidesBottomBarWhenPushed = YES;
    }
}
@end
