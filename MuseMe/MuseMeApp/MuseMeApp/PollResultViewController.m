//
//  PollResultViewController.m
//  MuseMe
//
//  Created by Yong Lin on 7/17/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "PollResultViewController.h"

@interface PollResultViewController (){
    double maxVotesForSingleItem;
}
@property (nonatomic, strong) Poll *poll;
@end

@implementation PollResultViewController
@synthesize poll=_poll;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    self.poll = [Poll new];
    self.poll.pollID = [Utility getObjectForKey:IDOfPollToBeShown];
    [[RKObjectManager sharedManager] getObject:self.poll delegate:self];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.poll = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    //((CenterButtonTabController*)self.tabBarController).cameraButton.hidden = YES;
}

-(void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    [self.tableView reloadData];
    for (NSUInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; i++){
        PollResultCell* cell = (PollResultCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        CGRect frame = cell.numberOfVotesIndicator.frame;
        CGRect frame0 = frame;
        frame0.size.width = 0;
        cell.numberOfVotesIndicator.frame = frame0;
        Item* item = [self.poll.items objectAtIndex:i];
        frame.size.width = (item.numberOfVotes.floatValue/(self.poll.totalVotes.floatValue == 0? 1:self.poll.totalVotes.floatValue))*155;
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            //cell.numberOfVotesIndicator.progress = item.numberOfVotes.floatValue/(self.poll.totalVotes.floatValue == 0? 1:self.poll.totalVotes.floatValue);
            cell.numberOfVotesIndicator.frame = frame;
        } completion:nil];
    }
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
    // Return the number of rows in the section.
    return self.poll.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"poll result cell";
    PollResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PollResultCell alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }
    Item* item = [self.poll.items objectAtIndex:indexPath.row];
    // Configure the cell...
    [Utility renderView:cell.itemImage withBackground:cell.background withCornerRadius:SMALL_CORNER_RADIUS andBorderWidth:SMALL_BORDER_WIDTH shadowOffSet:SMALL_SHADOW_OFFSET];
    [cell.itemImage clear];
    [cell.itemImage showLoadingWheel];
    cell.itemImage.url= [NSURL URLWithString:item.photoURL];
    [HJObjectManager manage:cell.itemImage];
    //cell.priceLabel.text = (item.price.intValue == 0 )?@"":[Utility formatCurrencyWithNumber:item.price];
    //cell.brandPreLabel.hidden = YES;
    /*if (item.brand.length > 0) {*/
    /*cell.brandLabel.text = item.brand;
    [cell.brandLabel adjustHeight];*/
        //cell.brandPreLabel.hidden = NO;
    //}
    cell.numberOfVotesIndicator.progress = 1;
    /*cell.numberOfVotesIndicator.progress = item.numberOfVotes.floatValue/(self.poll.totalVotes.floatValue == 0? 1:self.poll.totalVotes.floatValue);*/
    cell.numberOfVotesLabel.text = [NSString stringWithFormat:@"%d%%",item.numberOfVotes.intValue*100/(self.poll.totalVotes.intValue == 0? 1:self.poll.totalVotes.intValue)];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
