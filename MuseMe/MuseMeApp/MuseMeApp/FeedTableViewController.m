//
//  FeedTableViewController.m
//  MuseMe
//
//  Created by Yong Lin on 9/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FeedTableViewController.h"
#import "AddNewItemController.h"
#import "ProfileTableViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TimeStampLabelFrame CGRectMake(48,9,74,9)
#define UserImageFrame CGRectMake(5,9,40,40)
#define UsernameAndActionLabelFrame CGRectMake(47,17,236,16)
#define EventDescriptionLabelFrame CGRectMake(47,33,236,16)
#define CategoryIconFrame CGRectMake(292,9,23,23)
#define ItemImageFrame CGRectMake(5,57,310,310)
#define degreesToRadians(degrees) (M_PI * degrees / 180.0)
#define Reload_Distance 10.0

@interface FeedTableViewController (){
    User* userToBePassed;
    BOOL isLoading;
}
@property (nonatomic, strong) NSMutableArray* events;
@property (nonatomic, strong) MuseMeActivityIndicator* spinner;
@end

@implementation FeedTableViewController

@synthesize events=_events;
@synthesize spinner = _spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    //set UIBarButtonItem background image
    UIImage *navButtonBGImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self.navigationItem.rightBarButtonItem  setBackgroundImage:navButtonBGImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonBGImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.events = [NSMutableArray new];
    isLoading = NO;
    _spinner = [MuseMeActivityIndicator new];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/feeds/0" delegate:self];
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
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/feeds/0" delegate:self];
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
    if ([objectLoader.resourcePath hasPrefix:@"/feeds"]){
        if ([objectLoader.resourcePath hasPrefix:@"/feeds/0"]){
            self.events = [objects mutableCopy];
        }else{
            [self.events addObjectsFromArray:objects];
        }
        [_spinner stopAnimating];
        _spinner = nil;
        NSLog(@"%u", self.events.count);
        
        [self.tableView reloadData];
        isLoading = NO;
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    [Utility showAlert:@"Sorry!" message:[error localizedDescription]];
    NSLog(@"Encountered an error: %@", error);
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
    
    cell.thumbnail2.hidden = YES;
    cell.thumbnail3.hidden = YES;
    cell.thumbnail4.hidden = YES;
    // Configure the cell...Add item event
    [Utility renderView:cell.userImage withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH ];
    
    cell.userImage.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    if (event.user.profilePhotoURL){
        [cell.userImage clear];
        [cell.userImage showLoadingWheel];
        cell.userImage.url = [NSURL URLWithString:event.user.profilePhotoURL];
        [HJObjectManager manage:cell.userImage];
    }
    
    
    if (event.items.count == 2) {
        //cell.picContainerImageView.image = [UIImage imageNamed:PIC_CONTAINER_BG];
        //cell.picFrameImageView.image = [UIImage imageNamed:PIC_COLLAGE_FRAME_FOR_2];
        [self setPicture:cell.thumbnail0 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:213.6 Y:210.9 angleInDegree:17 edge:150];
        
        [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:105.5 Y:104.94 angleInDegree:75.53 - 90 edge:149];
        /*[cell.thumbnail1 clear];
         [cell.thumbnail1 showLoadingWheel];
         cell.thumbnail1.url = [NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL];*/
    }else
        if (event.items.count == 3) {
            cell.picContainerImageView.image = [UIImage imageNamed:PIC_CONTAINER_BG];
            //cell.picFrameImageView.image = [UIImage imageNamed:PIC_COLLAGE_FRAME_FOR_3];
            [self setPicture:cell.thumbnail0 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:247.31 Y:246.44 angleInDegree:11.26 edge:97];
            [self setPicture:cell.thumbnail2 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:2]).photoURL] atCenterX:150.43 Y:161.68 angleInDegree:66.5 - 90 edge:194];
            [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:247.5 Y:77.42 angleInDegree:19.30 edge:88];
            
            cell.thumbnail2.hidden = NO;
        }else
            if (event.items.count >= 4) {
                cell.picContainerImageView.image = [UIImage imageNamed:PIC_CONTAINER_BG];
                //cell.picFrameImageView.image = [UIImage imageNamed:PIC_COLLAGE_FRAME_FOR_4];
                CGFloat edge = 131;
                [self setPicture:cell.thumbnail0 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:0]).photoURL] atCenterX:224.89 Y:224.44 angleInDegree:20.91 edge:edge];
                [self setPicture:cell.thumbnail1 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:1]).photoURL] atCenterX:224.66 Y:95.53 angleInDegree:18.5 edge:edge];
                [self setPicture:cell.thumbnail2 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:2]).photoURL] atCenterX:90.83 Y:227.21 angleInDegree:79.21-90 edge:edge];
                [self setPicture:cell.thumbnail3 withURL:[NSURL URLWithString:((Item*)[event.items objectAtIndex:3]).photoURL] atCenterX:99.95 Y:98.53 angleInDegree:66.5-90 edge:edge];
                cell.thumbnail2.hidden = NO;
                cell.thumbnail3.hidden = NO;
            }
    
    
    // In current version, photo uploading is limited to one picture at a time
    cell.timeStampLabel.text = [Utility formatTimeWithDate:event.timeStamp];
    
    cell.categoryIcon.image = [Utility iconForCategory:(PollCategory)[event.poll.category intValue]];
    [HJObjectManager manage:cell.categoryIcon];
    cell.categoryLabel.text = [Utility stringFromCategory:(PollCategory)[event.poll.category intValue]];
    
    [cell.usernameAndActionLabel updateNumberOfLabels:2];
    [cell.usernameAndActionLabel setText:event.user.username andFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:0];
    [cell.usernameAndActionLabel setText:@" would like your vote" andFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] andColor:[Utility colorFromKuler:KULER_BLACK alpha:1] forLabel:1];
    
    [Utility renderView:cell.categoryIcon withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH];
    cell.eventDescriptionLabel.text = event.poll.title;
    cell.eventDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    cell.eventDescriptionLabel.textColor = [Utility colorFromKuler:KULER_BLACK alpha:1];
    [cell.eventDescriptionLabel adjustHeight];
    
    cell.totalVotes.text = [event.poll.totalVotes stringValue];
    
    CGRect frame = cell.picContainer.frame;
    frame.origin.y = cell.eventDescriptionLabel.frame.origin.y + cell.eventDescriptionLabel.frame.size.height + 13;
    cell.picContainer.frame = frame;
    
    frame = cell.seperator.frame;
    frame.origin.y = cell.picContainer.frame.origin.y + cell.picContainer.frame.size.height + 11;
    cell.seperator.frame = frame;
    /*cell.timeStampLabel.frame = TimeStampLabelFrame;
     cell.userImage.frame = UserImageFrame;
     cell.usernameAndActionLabel.frame = UsernameAndActionLabelFrame;
     cell.eventDescriptionLabel.frame = EventDescriptionLabelFrame;
     cell.categoryIcon.frame = CategoryIconFrame;
     cell.itemImage.frame = ItemImageFrame;*/
    return cell;
    
}


//Set up cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat charCount = [((Event*)[self.events objectAtIndex:indexPath.row]).poll.title length];
    CGFloat delta = floor(charCount/ 30) *20;
    return ROWHEIGHT + delta;
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
{
    imageView.transform = CGAffineTransformIdentity;
    imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(angle));
    imageView.bounds = CGRectMake(0,0, edge, edge);
    imageView.center = CGPointMake(x, y);
    
    [Utility renderView:imageView withCornerRadius:MEDIUM_CORNER_RADIUS andBorderWidth:MEDIUM_BORDER_WIDTH];
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
        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/feeds/%u", self.events.count] delegate:self];
        isLoading = YES;
    }
}
@end
