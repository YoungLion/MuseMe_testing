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
#define MAX_POLL_TITLE_HEIGHT 30
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
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/notifications" delegate:self];
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
        self.notifications = [objects mutableCopy];
        [_spinner stopAnimating];
        _spinner = nil;
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.notifications.count];
        if (self.notifications.count > 0){
            ((UITabBarItem*)[self.tabBarController.tabBar.items objectAtIndex:3]).badgeValue = [NSString stringWithFormat:@"%d", self.notifications.count];
        }
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
    
    [Utility renderView:cell.userImage withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
    
    cell.userImage.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    
    UILabel* label;
    
    if (notification.type.intValue == BEING_FOLLOWED_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:2];
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"Calibri-Bold" size:17.0] andColor:BLACK_TEXT_COLOR forLabel:0];
        label = [cell.messageLabel.labels objectAtIndex:0];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        [cell.messageLabel setText:@" started following you." andFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0] andColor:BLACK_TEXT_COLOR forLabel:1];
        label = [cell.messageLabel.labels objectAtIndex:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        cell.pollDescriptionLabel.text = @"";

    }else if (notification.type.intValue == RECEIVED_VOTES_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:2];
        
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"Calibri-Bold" size:17.0] andColor:BLACK_TEXT_COLOR forLabel:0];
        label = [cell.messageLabel.labels objectAtIndex:0];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        [cell.messageLabel setText:@" voted in your poll:" andFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0] andColor:BLACK_TEXT_COLOR forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
        label = [cell.messageLabel.labels objectAtIndex:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        cell.pollDescriptionLabel.text = notification.poll.title;
        [cell.pollDescriptionLabel adjustHeightWithMaxHeight:MAX_POLL_TITLE_HEIGHT];
        
    }else if (notification.type.intValue == RECEIVED_COMMENTS_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:2];
        
        [cell.messageLabel setText:notification.user.username andFont:[UIFont fontWithName:@"Calibri-Bold" size:17.0] andColor:BLACK_TEXT_COLOR forLabel:0];
        label = [cell.messageLabel.labels objectAtIndex:0];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        [cell.messageLabel setText:@" commented in your poll:" andFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0] andColor:BLACK_TEXT_COLOR forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
        label = [cell.messageLabel.labels objectAtIndex:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        [label adjustHeight];
        
        cell.pollDescriptionLabel.text = notification.poll.title;
        [cell.pollDescriptionLabel adjustHeightWithMaxHeight:MAX_POLL_TITLE_HEIGHT];
    }else if (notification.type.intValue == POLL_KILLED_NOTIFICATION){
        [cell.messageLabel updateNumberOfLabels:2];
        
        [cell.messageLabel setText:@"Administrator" andFont:[UIFont fontWithName:@"Calibri-Bold" size:17.0] andColor:BLACK_TEXT_COLOR forLabel:0];
        label = [cell.messageLabel.labels objectAtIndex:0];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        
        [cell.messageLabel setText:@" deleted your poll:" andFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0] andColor:BLACK_TEXT_COLOR forLabel:1];
        [[cell.messageLabel.labels objectAtIndex:1] adjustHeight];
        label = [cell.messageLabel.labels objectAtIndex:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(1, 1);
        [label adjustHeight];
        
        cell.pollDescriptionLabel.text = notification.poll.title;
        [cell.pollDescriptionLabel adjustHeightWithMaxHeight:MAX_POLL_TITLE_HEIGHT];
        
        cell.userImage.image = [UIImage imageNamed:APP_ICON];
    }
    
    if ((notification.user.profilePhotoURL)&&(notification.type.intValue != POLL_KILLED_NOTIFICATION)){
        [cell.userImage clear];
        [cell.userImage showLoadingWheel];
        cell.userImage.url = [NSURL URLWithString:notification.user.profilePhotoURL];
        [HJObjectManager manage:cell.userImage];
    }
    
    cell.timeStampLabel.text = [Utility formatTimeWithDate:notification.timeStamp];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
    if (notification.type.intValue != BEING_FOLLOWED_NOTIFICATION){
        UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 242, 10)];
        tmpLabel.text = notification.poll.title;
        [tmpLabel adjustHeightWithMaxHeight:MAX_POLL_TITLE_HEIGHT];
        CGFloat height = 36 + tmpLabel.frame.size.height;
        if (height > NOTIFICATION_CELL_HEIGHT){
            return height + 5;
        }
    }
    return NOTIFICATION_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/read_notification/%@", notification.notificationID] delegate:self];
    if (notification.type.intValue == BEING_FOLLOWED_NOTIFICATION)
    {
        [Utility setObject:notification.poll.pollID forKey:IDOfPollToBeShown];
        userToBePassed = notification.user;
        [self performSegueWithIdentifier:@"show profile" sender:self];
    }else if (notification.type.intValue == POLL_KILLED_NOTIFICATION){
        [self performSegueWithIdentifier:@"show system info" sender:self];
    }else{
        [Utility setObject:notification.poll.pollID forKey:IDOfPollToBeShown];
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
