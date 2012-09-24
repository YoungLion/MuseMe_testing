//
//  PollTableViewController.m
//  MuseMe
//
//  Created by Yong Lin on 7/9/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "PollTableViewController.h"
#import "ItemVotersViewController.h"


#define  POLLITEMCELLHEIGHT 330
#define  ADD_ITEM_BUTTON_CELL_HEIGHT 58
#define  OPEN_POLL_BUTTON_TITLE @"Publish poll"
//#define  FOLLOW_POLL_BUTTON_TITLE @"Follow poll"
//#define  UNFOLLOW_POLL_BUTTON_TITLE @"Unfollow poll"
#define  DELETE_POLL_BUTTON_TITLE   @"Delete poll"
#define  SHOW_POLL_RESULT_BUTTON_TITLE @"Show poll results"
#define  OPEN_POLL_HINT_STAY_DURATION 5

#define REPORT_INAPPROPRIATE_CONTENT_BUTTON_TITLE @"Flag as inappropriate"
#define SAVE_TO_PHOTO_LIBRARY_BUTTON_TITLE @"Save to photo library"

#define OpenPollAlertView 1
#define EndPollAlertView 2
#define DeletePollAlertView 3


#define NewItemActionSheet 0
#define PollOperationActionSheet 1
#define DeleteItemConfirmation 2
#define ItemOperationActionSheet 3

@interface PollTableViewController (){
    NSUInteger audienceIndex;
    BOOL isOwnerView, needsBack, openPollHintHasShown, newMedia, needsBackToFeeds, votingState;
    PollRecord *pollRecord;
    SingleItemViewOption singleItemViewOption;
    Item *itemToBeShown;
    UIImage* capturedImage;
    UIImageView *emptyPollHint;//, *emptyPollHintInAudienceView;// *addItemHint;
    UIActionSheet *popupQuery, *newItemOptions, *confirmation;
    id senderButton;
}
@property (nonatomic,strong) MuseMeActivityIndicator* spinner;
@end

@implementation PollTableViewController
@synthesize openPollHint = _openPollHint;
@synthesize poll=_poll;
@synthesize timeStampLabel = _timeStampLabel;
//@synthesize totalVotesCount = _totalVotesCount;
@synthesize pollDescription = _pollDescription;
@synthesize categoryLabel = _categoryLabel;
//@synthesize userPhoto = _userPhoto;
@synthesize categoryIconView = _categoryIconView;
@synthesize spinner=_spinner;
//@synthesize username = _username;
//@synthesize stateIndicationLabel = _stateIndicationLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    //set UIBarButtonItem background image
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    //self.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_LARGE];
    CGRect frameOfEmptyPollHint = CGRectMake(0, 150, 320, 160);
    
    emptyPollHint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:EMPTY_POLL_HINT]];
    emptyPollHint.frame = frameOfEmptyPollHint;
    emptyPollHint.hidden = YES;
    [self.view addSubview:emptyPollHint];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    needsBack = NO;
    needsBackToFeeds = NO;
    votingState = NO;
    
    self.pollDescription.inputAccessoryView = [Utility keyboardAccessoryToolBarWithButton:@"Done" target:self action:@selector(doneTyping)];
    self.openPollHint.alpha = 0;
    
    _spinner = [MuseMeActivityIndicator new];
}

- (void)viewDidUnload
{
    self.timeStampLabel = nil;
    //[self setTotalVotesCount:nil];
    [self setPollDescription:nil];
    [self setCategoryLabel:nil];
    //[self setUserPhoto:nil];
    [self setCategoryIconView:nil];
    //[self setUsername:nil];
    //[self setStateIndicationLabel:nil];
    [self setOpenPollHint:nil];
    [super viewDidUnload];
    self.poll = nil;
    pollRecord = nil;
    itemToBeShown = nil;
    emptyPollHint = nil;
    capturedImage = nil;
    senderButton = nil;
    _spinner = nil;
    //addItemHint = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((CenterButtonTabController*)self.tabBarController).cameraButton.alpha = 0;
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    self.poll = [Poll new];
    self.poll.pollID = [Utility getObjectForKey:IDOfPollToBeShown];
    openPollHintHasShown = NO;
   // [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_spinner startAnimatingWithMessage:@"Loading..." inView:self.view];
    [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Actions
- (IBAction)backButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (needsBackToFeeds)  self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

- (IBAction)actionButtonPressed:(UIBarButtonItem *)sender 
{
        NSString *pollOperation;
        NSString *deleteButton;
        NSString *showPollResultButton;
        if (isOwnerView)
        {
            deleteButton = DELETE_POLL_BUTTON_TITLE;
            if ([self.poll.state intValue] == EDITING){
                pollOperation = OPEN_POLL_BUTTON_TITLE;
                showPollResultButton = nil;
            } else {
                pollOperation = nil;
                showPollResultButton = SHOW_POLL_RESULT_BUTTON_TITLE;
            }
        }else{
            deleteButton = nil;
            pollOperation = nil;
            showPollResultButton = SHOW_POLL_RESULT_BUTTON_TITLE;
        }
        if (pollOperation){
            popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:deleteButton otherButtonTitles: pollOperation,showPollResultButton,  nil];
        }else{
            popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:deleteButton otherButtonTitles:showPollResultButton,  nil];
        }
        //}
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupQuery showFromTabBar:self.tabBarController.tabBar];
        popupQuery.tag = PollOperationActionSheet;
        popupQuery = nil;
}


- (IBAction)deleteButtonPressed:(UIButton *)sender {
    senderButton = sender;
    confirmation = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    confirmation.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [confirmation showFromTabBar:self.tabBarController.tabBar];
    confirmation.tag = DeleteItemConfirmation;
    confirmation = nil;
}

- (IBAction)vote:(UIButton *)sender
{
    sender.enabled = NO;
    PollItemCell *cell = (PollItemCell*)[[sender superview] superview];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{cell.votePercentageLabel.alpha = 1;} completion:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Item *item = [self.poll.items objectAtIndex:indexPath.row];
    Audience *audience = [self.poll.audiences objectAtIndex:audienceIndex];
    /*if ([[[self.poll.audiences objectAtIndex:audienceIndex] hasVoted] boolValue]){
        // if the current user has voted for an item in this poll, then undo the voting
        audience.hasVoted= [NSNumber numberWithInt:0];
        [[RKObjectManager sharedManager] putObject:audience delegate:self];
        
        self.poll.totalVotes = [NSNumber numberWithInt:[self.poll.totalVotes intValue] - 1];
        [[RKObjectManager sharedManager] putObject:self.poll delegate:self];
        
        item.numberOfVotes = [NSNumber numberWithInt:[item.numberOfVotes intValue] - 1];
        [[RKObjectManager sharedManager] putObject:item delegate:self];
        
       
        
    }else {*/
        //if the current user has not voted for an item in this poll, then vote for this item
        audience.hasVoted=item.itemID;
        [[RKObjectManager sharedManager] putObject:audience delegate:self];
        
        item.numberOfVotes = [NSNumber numberWithInt:[item.numberOfVotes intValue]+ 1];
        [[RKObjectManager sharedManager] putObject:item delegate:self];
    
        self.poll.totalVotes = [NSNumber numberWithInt:[self.poll.totalVotes intValue]+ 1];
        [[RKObjectManager sharedManager] putObject:self.poll delegate:self];
        
        [self followPoll];
        [Utility showAlert:@"Voted!" message:@"We appreciate your vote."];
}

- (IBAction)voteCountLabelPressed:(UIButton *)sender {
    if ([self.poll.state intValue] != EDITING)
    {
        PollItemCell *cell = (PollItemCell*)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        itemToBeShown = [self.poll.items objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"show voters" sender:self];
    }
}

- (IBAction)moreActionsOnThisItem:(UIButton *)sender {
    popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:REPORT_INAPPROPRIATE_CONTENT_BUTTON_TITLE otherButtonTitles:SAVE_TO_PHOTO_LIBRARY_BUTTON_TITLE,  nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showFromTabBar:self.tabBarController.tabBar];
    popupQuery.tag = ItemOperationActionSheet;
    popupQuery = nil;
    senderButton = sender;
}

#pragma mark - UIActionSheetDelegate Methods


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == PollOperationActionSheet){
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:OPEN_POLL_BUTTON_TITLE]){
            if (self.poll.items.count < 2) {
                [Utility showAlert:@"Please add more items." message:@"You can't open the poll until you have 2 or more items in the poll."];
            }else{
                [self confirmToOpenPoll];
            }
        }/*else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:FOLLOW_POLL_BUTTON_TITLE]){
            [self followPoll];
        }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:UNFOLLOW_POLL_BUTTON_TITLE]){
          [self unfollowPoll];
          }*/else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:SHOW_POLL_RESULT_BUTTON_TITLE]){
              [self performSegueWithIdentifier:@"show poll result" sender:self];
          }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:DELETE_POLL_BUTTON_TITLE]){
              [self confirmToDeletePoll];
          }
    }else if (actionSheet.tag == NewItemActionSheet){
        switch (buttonIndex) {
            case 0:
                [self useCamera];
                break;
            case 1:[self useCameraRoll];
                break;
            default:
                break;
        }
    }else if (actionSheet.tag == DeleteItemConfirmation){
        PollItemCell *cell = (PollItemCell*)[[senderButton superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Item *item = [self.poll.items objectAtIndex:indexPath.row - 1];
        switch (buttonIndex) {
            case 0:
                [self deleteItem:item];
                break;
            default:
                break;
        }
    }else if (actionSheet.tag == ItemOperationActionSheet){
        PollItemCell *cell = (PollItemCell*)[[senderButton superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Item *item = [self.poll.items objectAtIndex:indexPath.row];
        switch (buttonIndex) {
            case 0:
                [self reportInappropriateContent:item];
                break;
            case 1:
                [self saveToPhotoLibrary:cell.itemImage.image];
                break;
            default:
                break;
        }
    }
    [actionSheet resignFirstResponder];
}

- (void)deleteItem:(Item *)item
{
    [[RKObjectManager sharedManager] deleteObject:item delegate:self];
    [Utility showAlert:@"Deleted!" message:@""];
}

-(void)reportInappropriateContent:(Item*)item
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/flag/%@/%@", item.itemID, [Utility getObjectForKey:CURRENTUSERID]] delegate:self];
    [Utility showAlert:@"We will review this flagged item in 24 hours! Thank you for your contributions." message:@""];
}

-(void)saveToPhotoLibrary:(UIImage*)image
{
    UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   @selector(image:finishedSavingWithError:contextInfo:),
                                   nil);
    [Utility showAlert:@"Saved" message:nil];
}

-(void)confirmToOpenPoll
{
    UIAlertView *openPollAlertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Publishing allows your friends to vote. You can't edit a published poll." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    openPollAlertView.tag = OpenPollAlertView;
    [openPollAlertView show];
    openPollAlertView = nil;
}

-(void)confirmToDeletePoll
{
    UIAlertView *deletePollAlertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Once you delete this poll, you will delete everything in it." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [deletePollAlertView show];
    deletePollAlertView.tag = DeletePollAlertView;
    deletePollAlertView = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"A voting state change was cancelled.");
    }
    if (buttonIndex == 1) {
        if (alertView.tag == OpenPollAlertView) {
            [self openPoll];
        }else if (alertView.tag == DeletePollAlertView){
            [self deletePoll];
        }
    }
}

- (void)openPoll
{
    self.poll.state = [NSNumber numberWithInt:VOTING];
    self.poll.openTime = [NSDate date];
    [[RKObjectManager sharedManager] putObject:self.poll delegate:self];
    
    pollRecord = [PollRecord new];
    pollRecord.pollID = self.poll.pollID;
    pollRecord.pollRecordType = [NSNumber numberWithInt:OPENED_POLL];
    [[RKObjectManager sharedManager] putObject:pollRecord delegate:self];
    
    Event* event = [Event new];
    event.pollID = self.poll.pollID;
    event.userID = [Utility getObjectForKey:CURRENTUSERID];
    [[RKObjectManager sharedManager] postObject:event delegate:self];
    [Utility showAlert:@"Your poll is published." message:@""];

    needsBack = YES;
    needsBackToFeeds =YES;
}

- (void)deletePoll
{
    [[RKObjectManager sharedManager] deleteObject:self.poll delegate:self];
}

-(void)followPoll
{
    Audience *currentAudience = [self.poll.audiences objectAtIndex:audienceIndex];
    if ([currentAudience.isFollowing boolValue]) {
        return;
    }
    currentAudience.isFollowing = [NSNumber numberWithBool:YES];
    [[RKObjectManager sharedManager] putObject:currentAudience delegate:self];
    
    pollRecord = [PollRecord new];
    pollRecord.pollID = self.poll.pollID;
    pollRecord.pollRecordType = [NSNumber numberWithInt:VOTED_POLL];
    [[RKObjectManager sharedManager] postObject:pollRecord delegate:self];
    pollRecord = nil;
}

/*-(void)unfollowPoll
{    
    Audience *currentAudience = [self.poll.audiences objectAtIndex:audienceIndex];
    currentAudience.isFollowing = [NSNumber numberWithBool:NO];
    [[RKObjectManager sharedManager] putObject:currentAudience delegate:self];
    currentAudience = nil;
    
    pollRecord = [PollRecord new];
    pollRecord.pollID = self.poll.pollID;
    [[RKObjectManager sharedManager] deleteObject:pollRecord delegate:self];
    pollRecord = nil;
}*/

#pragma mark - RKObjectLoaderDelegate Methods

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    //Successfully loaded a poll
    if (objectLoader.method == RKRequestMethodGET){
        if (votingState) votingState = NO;
        isOwnerView = [[Utility getObjectForKey:CURRENTUSERID] isEqualToNumber:self.poll.user.userID];
        if (isOwnerView && [self.poll.state intValue] == EDITING)
        {
            self.pollDescription.editable = YES;
            if (!openPollHintHasShown){
                openPollHintHasShown = YES;
                [UIView animateWithDuration:1
                                      delay:0
                                    options:UIViewAnimationCurveLinear
                                 animations:^{self.openPollHint.alpha = 1;}
                                 completion:^(BOOL finished) {
                                     if (finished){
                                         [UIView animateWithDuration:1 delay:OPEN_POLL_HINT_STAY_DURATION options:UIViewAnimationCurveLinear animations:^{self.openPollHint.alpha = 0;} completion:nil];
                                     }
                                 }];
            }
        }else{
            self.pollDescription.editable = NO;
        }
        //self.userPhoto.url = [NSURL URLWithString:self.poll.user.profilePhotoURL];
        self.navigationItem.titleView = [Utility formatTitleWithString:self.poll.user.username];
        //NSString* stateIndication;
        switch ([self.poll.state intValue]) {
            case EDITING:
            {
                //stateIndication = isOwnerView?@"You are editing this poll.": @"is editing this poll.";
                self.timeStampLabel.text = [Utility formatTimeWithDate:self.poll.startTime];
                break;
            }
            case VOTING:
            {
                //stateIndication = isOwnerView?@"You have opened this poll.": @"has opened this poll.";
                self.timeStampLabel.text = [Utility formatTimeWithDate:self.poll.openTime];
                break;
            }
            default:
                break;
        }
        //self.stateIndicationLabel.text = stateIndication;
        
        self.pollDescription.text = self.poll.title;
        
        self.categoryLabel.text = [Utility stringFromCategory:(PollCategory)[self.poll.category intValue]];
        self.categoryIconView.image = [Utility iconForCategory:(PollCategory)[self.poll.category intValue]];
        
        //self.totalVotesCount.text = [NSString stringWithFormat:@"%@", self.poll.totalVotes];
        
        [self.timeStampLabel setNeedsLayout];
        //[self.totalVotesCount sizeToFit];

        if (self.poll.items.count == 0 && isOwnerView){
            emptyPollHint.hidden = NO;
        }else{
            emptyPollHint.hidden = YES;
        }

        //find whether the current user is among the audience of the poll
        audienceIndex = [self.poll.audiences indexOfObjectPassingTest:^(Audience* audience, NSUInteger idx, BOOL *stop)
                         {
                             NSLog(@"%@",audience.userID);
                             if ([audience.userID isEqualToNumber:[Utility getObjectForKey:CURRENTUSERID]]){
                                 *stop = YES;
                                 return YES;
                             }else return NO;
                         }];
        NSLog(@"audience index  = %u", audienceIndex);
        if ((!isOwnerView) && (audienceIndex == NSNotFound))
        {
            Audience *newAudience = [Audience new];
            newAudience.pollID = self.poll.pollID;
            newAudience.isFollowing = [NSNumber numberWithBool:NO];
            [[RKObjectManager sharedManager] postObject:newAudience delegate:self];
        }
    }else if (objectLoader.method == RKRequestMethodPUT){
        NSLog(@"Updating of this poll has been done");
        [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
    }else if (objectLoader.method == RKRequestMethodPOST && ![objectLoader wasSentToResourcePath:@"/events"]){
        [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
    }else if (objectLoader.method == RKRequestMethodDELETE){
        NSLog(@"Deleted successfully!");
        if (![objectLoader.resourcePath hasPrefix:@"/polls"]){
        [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
        }else{
            needsBack = YES;
        }
    }
    if (needsBack) [self backButtonPressed:nil];
    [_spinner stopAnimating];
    [self.tableView reloadData];
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    if ([error.localizedDescription isEqualToString:@"This poll does not exist any more."]){
        [Utility showAlert:@"Sorry!" message:error.localizedDescription];
    }
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
    if (isOwnerView && self.poll.state.intValue == EDITING){
        return self.poll.items.count + 1;
    }else return self.poll.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [Item new];
    
    if (isOwnerView && self.poll.state.intValue == EDITING){
        if (indexPath.row == 0){
            static NSString *CellIdentifier = @"add item button cell";
            PollItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[PollItemCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:CellIdentifier];
            }
            
            [cell.addNewItemButton setNavigationButtonWithColor:[Utility colorFromKuler:KULER_BLACK alpha:1]];
            cell.addNewItemButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
            [cell.addNewItemButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [cell.addNewItemButton.titleLabel setShadowColor:[UIColor blackColor]];
            cell.addNewItemButton.buttonCornerRadius = 12.0f;
            return cell;
        }else{
            item = [self.poll.items objectAtIndex:indexPath.row - 1];
        }
    }else {
        item = [self.poll.items objectAtIndex:indexPath.row];
    }
    
    static NSString *CellIdentifier = @"poll item cell";
    PollItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PollItemCell alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }
    Audience *currentUser = (audienceIndex == NSNotFound? nil:[self.poll.audiences objectAtIndex:audienceIndex]);

    // Configure the cell...
    cell.voteButton.hidden = YES;
    cell.voteButton.adjustsImageWhenDisabled = NO;
    // if the current user has voted for the item
    if ([currentUser.hasVoted isEqualToNumber:item.itemID]){
        cell.voteButton.hidden = NO;
        cell.voteButton.enabled = NO;
        [cell.voteButton setImage:[UIImage imageNamed:CHECKINBOX] forState:UIControlStateNormal];
        [cell.voteButton setImage:[UIImage imageNamed:CHECKINBOX_HL] forState:UIControlStateHighlighted];
    }
    if ((!isOwnerView) && ([self.poll.state intValue] == VOTING) && ([currentUser.hasVoted intValue] == 0)){
        cell.voteButton.hidden = NO;
        [cell.voteButton setImage:[UIImage imageNamed:CHECKBOX] forState:UIControlStateNormal];
        [cell.voteButton setImage:[UIImage imageNamed:CHECKBOX_HL] forState:UIControlStateHighlighted];
    }
    [cell.deleteButton setImage:[UIImage imageNamed:DELETE_ITEM_BUTTON] forState:UIControlStateNormal];
    [cell.deleteButton setImage:[UIImage imageNamed:DELETE_ITEM_BUTTON_HL] forState:UIControlStateHighlighted];
    cell.deleteButton.hidden = !(isOwnerView && [self.poll.state intValue] == EDITING);
    if (isOwnerView){
        cell.votePercentageLabel.hidden = YES;
        
        cell.itemOperationButton.hidden = YES;
        
        cell.voteCountLabel.hidden = YES;
        cell.voteCountIconView.hidden = YES;

        cell.commentCountLabel.hidden = YES;
        cell.commentCountIconView.hidden = YES;
    }

    
    [Utility renderView:cell.itemImage withCornerRadius:LARGE_CORNER_RADIUS andBorderWidth:LARGE_BORDER_WIDTH];
    cell.itemImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.itemImage clear];
    [cell.itemImage showLoadingWheel];
    cell.itemImage.url = [NSURL URLWithString:item.photoURL];
    [HJObjectManager manage:cell.itemImage];
    
    cell.votePercentageLabel.text = [NSString stringWithFormat:@"%d%%",item.numberOfVotes.intValue*100/(self.poll.totalVotes.intValue == 0? 1:self.poll.totalVotes.intValue)];
    
    if ([self.poll.state intValue] == VOTING && ((isOwnerView)||([currentUser.hasVoted boolValue]))){
        cell.votePercentageLabel.alpha = 1;
    }else{
        cell.votePercentageLabel.alpha = 0;
    }

    cell.timeStampLabel.text = [Utility formatTimeWithDate:item.addedTime];
    cell.voteCountLabel.text = [item.numberOfVotes stringValue];
    cell.commentCountLabel.text = [item.numberOfComments stringValue];
    
    cell.brandLabel.text = item.brand;
    [cell.brandLabel adjustHeight];
    [cell.votePercentageLabel adjustHeight];
    [cell.voteCountLabel adjustHeight];
    return cell;
}


/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}*/


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isOwnerView && self.poll.state.intValue == EDITING && indexPath.row == 0){
        return ADD_ITEM_BUTTON_CELL_HEIGHT;
    }else{
        return POLLITEMCELLHEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isOwnerView && self.poll.state.intValue == EDITING){
        if (indexPath.row == 0){
            return;
        }else{
            itemToBeShown = [self.poll.items objectAtIndex:indexPath.row - 1];
        }
    }else {
        itemToBeShown = [self.poll.items objectAtIndex:indexPath.row];
    }
    
    if ((isOwnerView)&&([self.poll.state intValue] == EDITING)){
        singleItemViewOption = SingleItemViewOptionEdit;
    }else{
        singleItemViewOption = SingleItemViewOptionView;
    }
    if (singleItemViewOption == SingleItemViewOptionNew || singleItemViewOption == SingleItemViewOptionEdit )
    {
        [self performSegueWithIdentifier:@"show single item view" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show single item view"]){
        SingleItemViewController* nextViewController = (SingleItemViewController*) segue.destinationViewController;
        nextViewController.singleItemViewOption = singleItemViewOption;
        if (!singleItemViewOption == SingleItemViewOptionNew){
            nextViewController.item = itemToBeShown;
        }else{
            nextViewController.capturedImage = capturedImage;
        }
    }
    else if ([segue.identifier isEqualToString:@"show voters"]){
        ItemVotersViewController* nextViewController = (ItemVotersViewController*)segue.destinationViewController;
        nextViewController.item = itemToBeShown;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > MAX_CHARACTER_NUMBER_FOR_POLL_DESCRIPTION) ? NO : YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (![textView.text isEqualToString:self.poll.title]){
        self.poll.title = textView.text;
        [[RKObjectManager sharedManager] putObject:self.poll delegate:self];
    }
}

-(void)doneTyping

{
    [self.pollDescription resignFirstResponder];
}

#pragma New Item
-(IBAction) newItemButtonPressed:(id)sender {
	newItemOptions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture", @"Choose from existing", nil];
	newItemOptions.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [newItemOptions showFromTabBar:self.tabBarController.tabBar];
    newItemOptions.tag = NewItemActionSheet;
	newItemOptions = nil;
}

- (void) TestOnSimulator
{
    capturedImage = [UIImage imageNamed:@"user3.png"];
}//when testing on devices, reconnect useCamera method below

- (void)useCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker
                                animated:YES];
        newMedia = YES;
    }
}

- (void)useCameraRoll
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:NO];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerEditedImage];
        capturedImage = image;
        singleItemViewOption = SingleItemViewOptionNew;
        if (newMedia){
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
         }
        [self performSegueWithIdentifier:@"show single item view" sender:self];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
}

-(void)image:(UIImage *)image
 finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
 {
 if (error) {
 [Utility showAlert:@"Save failed" message:@"Failed to save image"];
 }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
