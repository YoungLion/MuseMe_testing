//
//  AddToPollController.m
//  MuseMe
//
//  Created by Yong Lin on 8/26/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "AddToPollController.h"
#import "CenterButtonTabController.h"
#define PollPicker 0
//#define CategoryPicker 1
//#define kOFFSET_FOR_KEYBOARD 216.0

@interface AddToPollController (){
    BOOL newPoll, backMark;
    MuseMeActivityIndicator *spinner;
    NSMutableArray *pickerDataArray;
    NSArray *draftPolls;
    Poll *poll;
}
@end

@implementation AddToPollController
//@synthesize brandLabel = _brandLabel;
//@synthesize priceLabel = _priceLabel;
@synthesize itemImageView = _itemImageView;


@synthesize capturedItemImage=_capturedItemImage, pickerView, item=_item;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;

    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];

    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    

    pickerDataArray=[NSMutableArray new];
    draftPolls = [NSMutableArray new];
    backMark = NO;
    newPoll = YES;

    self.itemImageView.image = self.capturedItemImage;

    /*self.brandLabel.text = _item.brand;
    self.priceLabel.text = [Utility formatCurrencyWithNumber:_item.price];
    [self.brandLabel setNeedsLayout];
    [self.priceLabel setNeedsLayout];*/
    
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/draft_polls" delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    //[self setBrandLabel:nil];
    //[self setPriceLabel:nil];
    [super viewDidUnload];
    [self setItemImageView:nil];
    [self setPickerView:nil];
    _item = nil;
    poll = nil;
    spinner = nil;
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];*/
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)addToPoll
{
    //[self.pickPollTitleTextField resignFirstResponder];
        if (newPoll) {
            NewPollViewController* newPOllVC = [self.storyboard  instantiateViewControllerWithIdentifier:@"new poll VC"];;
            newPOllVC.delegate = self;
            [self.navigationController pushViewController:newPOllVC animated:YES];
        }else{
            [self addItemToPoll:((PollRecord*)[draftPolls objectAtIndex:[self.pickerView selectedRowInComponent:0]-1]).pollID];
        }
}

-(void)addItemToPoll:(NSNumber*)pollID
{
    spinner = [MuseMeActivityIndicator new];
    [spinner startAnimatingWithMessage:@"Adding Item..." inView:self.view];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    _item.pollID = pollID;
    _item.photo = UIImageJPEGRepresentation(self.capturedItemImage, 1.0f);
    [[RKObjectManager sharedManager] postObject:self.item usingBlock:^(RKObjectLoader *loader){
        RKParams* params = [RKParams params];
        [params setValue:_item.pollID forParam:@"item[poll_id]"];
        [params setData:_item.photo MIMEType:@"image/jpeg" forParam:@"item[photo]"];
        [params setValue:_item.brand forParam:@"item[brand]"];
        NSLog(@"post to %@",loader.resourcePath);
        loader.params = params;
        loader.delegate = self;
    }];
}



-(IBAction)backgroundTouched:(id)sender
{
   // [self.pickPollTitleTextField resignFirstResponder];
}


-(void)backWithFlipAnimation{
    [Utility setObject:self.item.pollID forKey:IDOfPollToBeShown];
    id VC = ((UINavigationController*)((CenterButtonTabController*)[self.navigationController presentingViewController]).selectedViewController).topViewController;
    [VC performSegueWithIdentifier:@"show poll" sender:VC];
    [[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma RKObjectLoaderDelegate Methods

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    if ([objectLoader.resourcePath hasPrefix:@"/items"]){
        NSLog(@"The new item has been added!");
        [Utility showAlert:@"Item added!" message:@""];
        backMark = YES;
    }else if ([objectLoader.resourcePath hasPrefix:@"/draft_polls"]){
        // extract all the active polls in editing state of the current user
        draftPolls = objects;
        for (id obj in objects){
            PollRecord *pollRecord = (PollRecord*) obj;
            if ([pollRecord.pollRecordType intValue] == EDITING_POLL){
                //[draftPolls addObject:pollRecord];
                [pickerDataArray addObject:pollRecord.title];
            }
        }
        [self.pickerView reloadAllComponents];
    }
    if (backMark){
        [spinner stopAnimating];
        [self backWithFlipAnimation];
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
#if ENVIRONMENT == ENVIRONMENT_DEVELOPMENT
    [Utility showAlert:[error localizedDescription] message:nil];
#endif
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - UIPickerView Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerDataArray count] + 1;
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.backgroundColor = [UIColor clearColor];
        tView.font = [UIFont fontWithName:@"AmericanTypewriter" size:14];
    }
    // Fill the label text here
    if (row > 0) {
        tView.text = [pickerDataArray objectAtIndex:row - 1];
    }else{
        tView.text = @"New Poll ... ";
    }
    tView.text = [@" " stringByAppendingString:tView.text];
    return tView;
}

#pragma mark - UIPickerView Delegate Methods

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row > 0) {
        _item.pollID = ((PollRecord*)[draftPolls objectAtIndex:row - 1]).pollID;
        [Utility setObject:_item.pollID forKey:IDOfPollToBeShown];
        newPoll = NO;
    }else{
        _item.pollID = nil;
        newPoll = YES;
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

#pragma mark - NewPollViewController Delegate Method

-(void)newPollViewController:(id)sender didCreateANewPoll:(NSNumber *)pollID
{
    [self addItemToPoll:pollID];
}

/*-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}*/
@end
