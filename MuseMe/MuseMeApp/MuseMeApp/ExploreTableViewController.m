//
//  ExploreTableViewController.m
//  MuseMe
//
//  Created by Yong Lin on 7/6/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "ExploreTableViewController.h"
#import "AddNewItemController.h"
#import "ProfileTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

#define TimeStampLabelFrame CGRectMake(48,9,74,9)
#define UserImageFrame CGRectMake(5,9,40,40)
#define UsernameAndActionLabelFrame CGRectMake(47,17,236,16)
#define EventDescriptionLabelFrame CGRectMake(47,33,236,16)
#define CategoryIconFrame CGRectMake(292,9,23,23)
#define ItemImageFrame CGRectMake(5,57,310,310)
#define degreesToRadians(degrees) (M_PI * degrees / 180.0)
#define Reload_Distance 10.0

@interface ExploreTableViewController (){
    User* userToBePassed;
    BOOL isLoading;
}
@property (nonatomic, strong) NSMutableArray* events;
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@end

@implementation ExploreTableViewController

@synthesize events=_events;
@synthesize spinner = _spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    self.events = [NSMutableArray new];
    isLoading = NO;
    _spinner = [MuseMeActivityIndicator new];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
}

- (void)viewDidUnload
{
    self.events = nil;
    self.tableView = nil;
    _spinner = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    self.tabBarController.tabBar.alpha = 1;
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_WITH_LOGO] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/events/0" delegate:self];
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
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}
#pragma mark - User Actions


- (IBAction)refresh:(id)sender {
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/events/0" delegate:self]; 
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
    if ([objectLoader.resourcePath hasPrefix:@"/events"]){
        if ([objectLoader.resourcePath hasPrefix:@"/events/0"]){
            self.events = [objects mutableCopy];
        }else{
            [self.events addObjectsFromArray:objects];
        }
            [_spinner stopAnimating];
            _spinner = nil;
            
            [self.tableView reloadData];
            isLoading = NO;
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
#if ENVIRONMENT == ENVIRONMENT_DEVELOPMENT
    [Utility showAlert:[error localizedDescription] message:nil];
#endif
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
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.events objectAtIndex:indexPath.row];

    static NSString *CellIdentifier = @"feeds cell";
    FeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FeedsCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    cell.thumbnail0.hidden = YES;
    cell.thumbnail1.hidden = YES;
    cell.thumbnail2.hidden = YES;
    cell.thumbnail3.hidden = YES;
    cell.background0.hidden = YES;
    cell.background1.hidden = YES;
    cell.background2.hidden = YES;
    cell.background3.hidden = YES;
    // Configure the cell...Add item event
    [Utility renderView:cell.userImage withBackground:cell.userPhotoBackground withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
    
    cell.userImage.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    if (event.user.profilePhotoURL){
        [cell.userImage clear];
        [cell.userImage showLoadingWheel];
        cell.userImage.url = [NSURL URLWithString:event.user.profilePhotoURL];
        [HJObjectManager manage:cell.userImage];
    }

    
    if (event.items.count == 2) {
        [self setPicture:cell.thumbnail0  withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:213.6 Y:210.9 angleInDegree:17 edge:150 withBackground:cell.background0];
        
        [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:105.5 Y:104.94 angleInDegree:75.53 - 90 edge:149 withBackground:cell.background1];
        cell.thumbnail0.hidden = NO;
        cell.thumbnail1.hidden = NO;
        cell.background0.hidden = NO;
        cell.background1.hidden = NO;
    }else
    if (event.items.count == 3) {
        cell.picContainerImageView.image = [UIImage imageNamed:PIC_CONTAINER_BG];
        [self setPicture:cell.thumbnail0 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:247.31 Y:246.44 angleInDegree:11.26 edge:97 withBackground:cell.background0];
        [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:247.5 Y:77.42 angleInDegree:19.30 edge:88 withBackground:cell.background1];
        [self setPicture:cell.thumbnail2 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:2]).photoURL] atCenterX:150.43 Y:161.68 angleInDegree:66.5 - 90 edge:194 withBackground:cell.background2];
        cell.thumbnail0.hidden = NO;
        cell.thumbnail1.hidden = NO;
        cell.background0.hidden = NO;
        cell.background1.hidden = NO;
        cell.thumbnail2.hidden = NO;
        cell.background2.hidden = NO;
    }else
    if (event.items.count >= 4) {
        cell.picContainerImageView.image = [UIImage imageNamed:PIC_CONTAINER_BG];
        CGFloat edge = 131;
        [self setPicture:cell.thumbnail0 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:224.89 Y:224.44 angleInDegree:20.91 edge:edge withBackground:cell.background0];
        [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:224.66 Y:95.53 angleInDegree:18.5 edge:edge withBackground:cell.background1];
        [self setPicture:cell.thumbnail2 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:2]).photoURL] atCenterX:90.83 Y:227.21 angleInDegree:79.21-90 edge:edge withBackground:cell.background2];
        [self setPicture:cell.thumbnail3 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:3]).photoURL] atCenterX:99.95 Y:98.53 angleInDegree:66.5-90 edge:edge withBackground:cell.background3];
        cell.thumbnail0.hidden = NO;
        cell.thumbnail1.hidden = NO;
        cell.background0.hidden = NO;
        cell.background1.hidden = NO;
        cell.thumbnail2.hidden = NO;
        cell.thumbnail3.hidden = NO;
        cell.background2.hidden = NO;
        cell.background3.hidden = NO;
    }
    
    
    // In current version, photo uploading is limited to one picture at a time
    cell.timeStampLabel.text = [Utility formatTimeWithDate:event.timeStamp];
    
    cell.categoryIcon.image = [Utility iconForCategory:(PollCategory)[event.poll.category intValue]];
    cell.categoryLabel.text = [Utility stringFromCategory:(PollCategory)[event.poll.category intValue]];
    
    UILabel* label;
    
    [cell.usernameAndActionLabel updateNumberOfLabels:2];
    [cell.usernameAndActionLabel setText:event.user.username andFont:[UIFont fontWithName:@"Calibri-Bold" size:17] andColor:BLACK_TEXT_COLOR forLabel:0];
    label = [cell.usernameAndActionLabel.labels objectAtIndex:0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(1, 1);
    
    [cell.usernameAndActionLabel setText:@" would like your vote" andFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0] andColor:BLACK_TEXT_COLOR forLabel:1];
    label = [cell.usernameAndActionLabel.labels objectAtIndex:1];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(1, 1);
    
    cell.eventDescriptionLabel.text = event.poll.title;
    cell.eventDescriptionLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:15.2];
    [cell.eventDescriptionLabel adjustHeight];
    
    cell.upperContainer.frame = CGRectMake(0, 0, 320, cell.eventDescriptionLabel.frame.origin.y + cell.eventDescriptionLabel.frame.size.height + 5);
    
    cell.totalVotes.text = [event.poll.totalVotes stringValue];

    CGRect frame = cell.picContainer.frame;
    frame.origin.y = cell.eventDescriptionLabel.frame.origin.y + cell.eventDescriptionLabel.frame.size.height + 13;
    cell.picContainer.frame = frame;
    

    return cell;

}


//Set up cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event* event = [self.events objectAtIndex:indexPath.row];

    UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 242, 10)];
    tmpLabel.text = event.poll.title;
    [tmpLabel adjustHeight];
    
    CGFloat delta = tmpLabel.frame.size.height - 20;
    return FEED_CELL_HEIGHT + delta;
}


#pragma mark - Table view delegate

- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath{
   // cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.events objectAtIndex:indexPath.row];
    [Utility setObject:event.poll.pollID forKey:IDOfPollToBeShown];
    [self performSegueWithIdentifier:@"show poll" sender:self];
}

- (IBAction)showUserProfile:(id)sender {
    FeedsCell *cell = (FeedsCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Event* event = [self.events objectAtIndex:indexPath.row];
    userToBePassed = event.user;
    [self performSegueWithIdentifier:@"show profile" sender:self];
}

#pragma User Actions
- (IBAction)newPollButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"new poll" sender:self];
}

#pragma NewPollViewController delegate method

-(void)newPollViewController:(id)sender didCreateANewPoll:(NSNumber *)pollID
{
    [Utility setObject:pollID forKey:IDOfPollToBeShown];
    [self.navigationController popViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"show poll" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"new poll"]){
        ((NewPollViewController*)(segue.destinationViewController)).delegate = self;
    }else if ([segue.identifier isEqualToString:@"show profile"])
    {
        ProfileTableViewController* profileVC =(ProfileTableViewController*)segue.destinationViewController;
        profileVC.user = userToBePassed;
        profileVC.hidesBottomBarWhenPushed = YES;
    }
    
}

-(void)setPicture:(HJManagedImageV*)imageView
          withURL:(NSURL*)url
          atCenterX:(CGFloat)x
                Y:(CGFloat)y
    angleInDegree:(CGFloat)angle
             edge:(CGFloat)edge
   withBackground:(UIView*)background
{
    imageView.transform = CGAffineTransformIdentity;
    imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(angle));
    imageView.bounds = CGRectMake(0,0, edge, edge);
    imageView.center = CGPointMake(x, y);
    
    if (edge < 120){
        [Utility renderView:imageView withBackground:background withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
    }else{
        [Utility renderView:imageView withBackground:background withCornerRadius:MEDIUM_CORNER_RADIUS andBorderWidth:MEDIUM_BORDER_WIDTH shadowOffSet:MEDIUM_SHADOW_OFFSET];
    }
    [imageView clear];
    [imageView showLoadingWheel];
    imageView.url = url;
    [HJObjectManager manage:imageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    CGFloat y = offset.y + bounds.size.height - inset.bottom;
    CGFloat h = size.height;
    if ((y > h - Reload_Distance) && !isLoading) {
        NSLog(@"load more rows");
        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/events/%u", self.events.count] delegate:self];
         isLoading = YES;
    }
}
@end
