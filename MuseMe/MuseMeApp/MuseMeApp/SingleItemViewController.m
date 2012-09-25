//
//  SingleItemViewController.m
//  
//
//  Created by Yong Lin on 7/15/12.
//  Copyright (c) 2012 MuseMe Inc.. All rights reserved.
//

#import "SingleItemViewController.h"


@interface SingleItemViewController ()
{
    BOOL textboxOn;
    NSURL *photoURL;
}
@property (nonatomic, strong) MuseMeActivityIndicator *spinner;
@end

@implementation SingleItemViewController
@synthesize brandTextField = _brandTextField;
@synthesize itemImageView = _itemImageView;
//@synthesize cameraButton = _cameraButton;
@synthesize singleItemViewOption, item = _item;
//@synthesize descriptionTextField=_descriptionTextField;
//@synthesize priceTextField=_priceTextField;
@synthesize capturedImage = _capturedImage;
@synthesize tapHintImageView = _tapHintImageView;
@synthesize spinner = _spinner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
    UIImage *navigationBarBackground =[[UIImage imageNamed:NAV_BAR_BACKGROUND_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    
    UIImage *navButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.navigationItem.leftBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem  setBackgroundImage:navButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *addToPollButtonImage = [[UIImage imageNamed:NAV_BAR_BUTTON_BG] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]; 
    //UIImage *backButtonPressedImage = [UIImage imageNamed:NAV_BAR_BUTTON_BG_HL]; 
    UIBarButtonItem *addToPollButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    [addToPollButton  setBackgroundImage:addToPollButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = addToPollButton;
    
    NSArray *titles = [[NSArray alloc] initWithObjects:@"Add new item", @"Edit item", @"View item",nil];
    self.title = [titles objectAtIndex:singleItemViewOption];

    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:BACKGROUND_COLOR]];
    self.view.backgroundColor = [Utility colorFromKuler:KULER_BLACK alpha:1];
    
    //self.descriptionTextField.delegate= self;
    //self.priceTextField.delegate= self;
    self.brandTextField.delegate = self;
    //self.descriptionTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    //self.priceTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    self.brandTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    self.brandTextField.alpha = 0;
    //self.priceTextField.alpha = 0;
    textboxOn = NO;
    
    
    if (!singleItemViewOption == SingleItemViewOptionNew){
        //self.descriptionTextField.text = self.item.description;
        //self.priceTextField.text = [Utility formatCurrencyWithNumber:self.item.price];
        self.brandTextField.text = self.item.brand;
        self.itemImageView.url = [NSURL URLWithString:self.item.photoURL];
        [HJObjectManager manage:self.itemImageView];
    }else{
        self.itemImageView.image = self.capturedImage;
    }
    if (singleItemViewOption == SingleItemViewOptionView)
    {
        //self.descriptionTextField.enabled = NO;
        //self.priceTextField.enabled = NO;
        self.brandTextField.enabled = NO;
        //self.descriptionTextField.borderStyle = UITextBorderStyleNone;
        //self.priceTextField.borderStyle = UITextBorderStyleNone;
        self.brandTextField.borderStyle = UITextBorderStyleNone;
        self.tapHintImageView.image = [UIImage imageNamed:TAP_FOR_MORE_INFO];
    }else{
        //self.descriptionTextField.enabled = YES;
        //self.priceTextField.enabled = YES;
        self.brandTextField.enabled = YES;
        //self.descriptionTextField.borderStyle = UITextBorderStyleRoundedRect;
        //self.priceTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.brandTextField.borderStyle = UITextBorderStyleRoundedRect;
        //self.descriptionTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
        //self.priceTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
        self.brandTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
        self.tapHintImageView.image = [UIImage imageNamed:TAP_TO_ADD_INFO];
    }
    [UIView beginAnimations:@"animation2" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.7];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    self.navigationItem.titleView = [Utility formatTitleWithString:self.navigationItem.title];
	// Do any additional setup after loading the view.
}


- (void)viewDidUnload
{
    [self setBrandTextField:nil];
    [self setItemImageView:nil];
    [self setTapHintImageView:nil];
    [super viewDidUnload];
    //self.descriptionTextField = nil;
    //self.priceTextField = nil;
    photoURL = nil;
    self.item = nil;
    _spinner = nil;
    self.capturedImage = nil;
    //[AmazonClientManager clearCredentials];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    ((CenterButtonTabController*)self.tabBarController).cameraButton.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma User Action

-(IBAction)done
{
    //[self.descriptionTextField resignFirstResponder];
    //[self.priceTextField resignFirstResponder];
    [self.brandTextField resignFirstResponder];
    switch (self.singleItemViewOption) {
        case SingleItemViewOptionView:
            [self backWithFlipAnimation];
            break;
        case SingleItemViewOptionEdit:
        {
            //self.item.description = self.descriptionTextField.text;
            /*NSString* priceValueString;
            if ([self.priceTextField.text hasPrefix:@"$"]){
                priceValueString = [self.priceTextField.text substringFromIndex:1];
            }else{
                priceValueString = self.priceTextField.text;
            }
            self.item.price = [NSNumber numberWithDouble:[priceValueString doubleValue]];*/
            Item* item = [Item new];
            item.itemID = self.item.itemID;
            item.brand = self.brandTextField.text;
            [[RKObjectManager sharedManager] putObject:item delegate:self];
            break;
        }
        case SingleItemViewOptionNew:
        {
            _spinner = [MuseMeActivityIndicator new];
            [_spinner startAnimatingWithMessage:@"Adding..." inView:self.view];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            
            self.item = [Item new];
            _item.pollID = [Utility getObjectForKey:IDOfPollToBeShown];
            _item.photo = UIImageJPEGRepresentation(self.capturedImage, 1.0f);
            _item.brand = self.brandTextField.text;
            [[RKObjectManager sharedManager] postObject:_item usingBlock:^(RKObjectLoader *loader){
                
                RKParams* params = [RKParams params];
                [params setValue:_item.pollID forParam:@"item[poll_id]"];
                [params setData:_item.photo MIMEType:@"image/jpeg" forParam:@"item[photo]"];
                NSLog(@"post to %@",loader.resourcePath);
                loader.params = params;
                loader.delegate = self;
            }];
            break;
        }
        default:
            break;
    }

}

- (IBAction)cancelButton{
    [self backWithFlipAnimation];
}

-(IBAction)backgroundTouched:(id)sender
{
    if (textboxOn) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.brandTextField.alpha = 0;
            //self.priceTextField.alpha = 0;
            self.tapHintImageView.alpha = 1;

        } completion:nil];
        //[self.priceTextField resignFirstResponder];
        [self.brandTextField resignFirstResponder];
    }else {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.brandTextField.alpha = 1;
            //self.priceTextField.alpha = 1;
            self.tapHintImageView.alpha = 0;
            
        } completion:nil];
    }
    textboxOn = !textboxOn;
}

#pragma RKObjectLoaderDelegate Methods

- (void)request:(RKRequest*)request didLoadResponse:
(RKResponse*)response {
    if ([response isJSON]) {
        NSLog(@"Got a JSON, %@", response.bodyAsString);
    }
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    if ([objectLoader wasSentToResourcePath:@"/items" method:RKRequestMethodPOST] ){
        [Utility showAlert:@"Item added!" message:@""];
    }
    [_spinner stopAnimating];
    _spinner = nil;
    [self backWithFlipAnimation];
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [Utility showAlert:@"Sorry!" message:error.localizedDescription];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Helper Methods

-(void)backWithFlipAnimation{
    [UIView beginAnimations:@"animation2" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.7];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO]; 
    [UIView commitAnimations];
    [self.navigationController popViewControllerAnimated:NO];
}

/*-(void)doneButton{
    [self.priceTextField resignFirstResponder];
}*/


#pragma mark - TextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > MAX_CHARACTER_NUMBER_FOR_ITEM_DESCRIPTION) ? NO : YES;
}

/*- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.priceTextField) {
        // create custom button
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(0, 163, 106, 53);
        doneButton.adjustsImageWhenHighlighted = NO;
        [doneButton setImage:[UIImage imageNamed:@"doneNormal.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"doneHighlighted.png"] forState:UIControlStateHighlighted];
        [doneButton addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchUpInside];
        
        // locate keyboard view
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        for (UIView *keyboard in tempWindow.subviews) {
            if ([[keyboard description] hasPrefix:@"<UIKeyboard"]) {
                [keyboard addSubview:doneButton];
                break; 
            } 
        }
    }
}*/


@end
