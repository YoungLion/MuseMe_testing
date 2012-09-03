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
@end

@implementation ItemVotersViewController
@synthesize voters = _voters;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    
    //set UIBarButtonItem background image
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.voters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"voter cell";
    ItemVoterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ItemVoterCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    User* voter = [self.voters objectAtIndex:indexPath.row];
    
    cell.userPhoto.image = [UIImage imageNamed:DEFAULT_USER_PROFILE_PHOTO_SMALL];
    if (voter.profilePhotoURL){
        [cell.userPhoto clear];
        [cell.userPhoto showLoadingWheel];
        cell.userPhoto.url = [NSURL URLWithString:voter.profilePhotoURL];
        [HJObjectManager manage:cell.userPhoto];
    }
    
    cell.usernameLabel.text = voter.username;
    [cell.usernameLabel adjustHeight];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User* voter = [self.voters objectAtIndex:indexPath.row]; 
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
