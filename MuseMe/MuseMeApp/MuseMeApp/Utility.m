//
//  Utility.m
//  
//
//  Created by Yong Lin on 8/25/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import "Utility.h"

double secondsInAnHour = 3600;
double secondsInAMinute = 60;
double secondsInADay = 3600*24;
double secondsInAWeek = 3600*24*7;
double secondsInAMonth = 3600*24*30.5;
double secondsInAYear = 3600*24*365;

@implementation Utility


+(void) showAlert:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];

    [alert show];
}

+(void) setObject:(id) obj forKey:(NSString*) key{
    NSUserDefaults *session = [NSUserDefaults standardUserDefaults];
    [session setObject:obj forKey:key];
    [session synchronize];
}

+(id) getObjectForKey:(NSString*) key{
    NSUserDefaults *session = [NSUserDefaults standardUserDefaults];
    return [session objectForKey:key];
}

+ (NSString*) formatCurrencyWithString: (NSString *) string
{
    // alloc formatter
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    
    // set options.
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    
    // reset style to no style for converting string to number.
    [currencyStyle setNumberStyle:NSNumberFormatterNoStyle];
    
    //create number from string
    NSNumber * balance = [currencyStyle numberFromString:string];
    
    //now set to currency format
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyStyle setMaximumFractionDigits:2];
    [currencyStyle setMinimumFractionDigits:2];
    // get formatted string
    NSString* formatted = [currencyStyle stringFromNumber:balance];
    
    currencyStyle = nil;
    
    //return formatted string
    return formatted;
}

+ (NSString*) formatCurrencyWithNumber: (NSNumber *) price
{
    // alloc formatter
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    
    // set options.
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    
    // set to currency format
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyStyle setMaximumFractionDigits:2];
    [currencyStyle setMinimumFractionDigits:2];
    // get formatted string
    NSString* formatted = [currencyStyle stringFromNumber:price];
    
    currencyStyle = nil;
    
    //return formatted string
    return formatted;
}

+(UILabel*)formatTitleWithString:(NSString *) titleText
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22];
    title.shadowColor = [UIColor blackColor];
    title.shadowOffset = CGSizeMake(0, -1);
    title.textAlignment = UITextAlignmentCenter;
    title.textColor = [UIColor whiteColor]; 
    title.text = titleText;
    [title sizeToFit];
    return title;
}

+(NSString*)formatTimeWithDate:(NSDate *) date
{
    NSDate* now = [NSDate date];
    NSTimeInterval timeDifference = [now timeIntervalSinceDate:date];
    NSInteger years = timeDifference /secondsInAYear;
    NSInteger minutes = timeDifference / secondsInAMinute;
    NSInteger hours = timeDifference / secondsInAnHour;
    NSInteger days = timeDifference /secondsInADay;
    NSInteger weeks = timeDifference / secondsInAWeek;
    NSInteger months = timeDifference / secondsInAMonth;
    
    if (years > 1)
    {
        return [NSString stringWithFormat:@"%u yr ago", years];
    }else if (years == 1){
        return @"1 yr ago";
    }else if (months > 1)
    {
        return [NSString stringWithFormat:@"%u mo ago", months];
    }else if (months == 1){
        return @"1 mo ago";
    }else if (weeks > 1)
    {
        return [NSString stringWithFormat:@"%u wk ago", weeks];
    }else if (weeks == 1){
        return @"1 wk ago";
    }else if (days > 1)
    {
        return [NSString stringWithFormat:@"%u d ago", days];
    }else if (days == 1){
        return @"1 d ago";
    }else if (hours > 1)
    {
        return [NSString stringWithFormat:@"%u hr ago", hours];
    }else if (hours == 1){
        return @"1 hr ago";
    }else if (minutes > 1)
    {
        return [NSString stringWithFormat:@"%u min ago", minutes];
    }else if (minutes == 1){
        return @"1 min ago";
    }else return @"just now";
}

+(NSURL*)URLForCategory:(PollCategory) category;
{
    NSURL* url;
    return url;
}

+(UIImage*)iconForCategory:(PollCategory) category
{
    NSString *imageName;
    switch (category) {
        case Art: imageName = @"Art";
            break;
        case Cars: imageName = @"Cars";
            break;
        case Beauty: imageName = @"Beauty";
            break;
        case CuteThings: imageName = @"CuteThings";
            break;
        case Electronics: imageName = @"Electronics";
            break;
        case Events: imageName = @"Events";
            break;
        case Fashion: imageName = @"Fashion";
            break;
        case Food: imageName = @"Food";
            break;
        case Humor: imageName = @"Humor";
            break;
        case Media: imageName = @"Media";
            break;
        case Travel: imageName = @"Travel";
            break;
        default: imageName = @"Other";
            break;
    }
    return [UIImage imageNamed:imageName];
}

+(NSString*)stringFromCategory:(PollCategory) category
{
    switch (category) {
        case Art: return @"Art";
        case Cars: return @"Cars";
        case Beauty: return @"Beauty";
        case CuteThings: return @"Cute things";
        case Electronics: return @"Electronics";
        case Events: return @"Events";
        case Fashion: return @"Fashion";
        case Food: return @"Food";
        case Humor: return @"Humor";
        case Media: return @"Media";
        case Travel: return @"Travel";
        default: return @"Other";
    }
}

+(PollCategory)categoryFromString:(NSString*) string
{
    if ([string isEqualToString:@"Art"]){
        return Art;
    }else if ([string isEqualToString:@"Cars"]){
        return Cars;
    }else if ([string isEqualToString:@"Beauty"]){
        return Beauty;
    }else if ([string isEqualToString:@"CuteThings"]){
        return CuteThings;
    }else if ([string isEqualToString:@"Electronics"]){
        return Electronics;
    }else if ([string isEqualToString:@"Events"]){
        return Events;
    }else if ([string isEqualToString:@"Fashion"]){
        return Fashion;
    }else if ([string isEqualToString:@"Food"]){
        return Food;
    }else if ([string isEqualToString:@"Humor"]){
        return Humor;
    }else if ([string isEqualToString:@"Media"]){
        return Media;
    }else if ([string isEqualToString:@"Travel"]){
        return Travel;
    }
    
    return Other;
}

+ (UIBarButtonItem *)createSquareBarButtonItemWithNormalStateImage:(NSString*)normalStateImage
                                          andHighlightedStateImage:(NSString*) highlightedStateImage
                                                            target:(id)tgt
                                                            action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:normalStateImage] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    //UIImage *buttonPressedImage = [[UIImage imageNamed:highlightedStateImage] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    /*[[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];*/
    
    CGRect buttonFrame = [button frame];
    buttonFrame.size = buttonImage.size;
    [button setFrame:buttonFrame];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    //[button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    //[button setTitle:t forState:UIControlStateNormal];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return buttonItem;
}

+(UIColor*)colorFromKuler:(int)kulerColor
                    alpha:(CGFloat)a
{
    switch (kulerColor) {
        case KULER_YELLOW:return [UIColor colorWithRed:246/255.0 green:247/255.0 blue:146/255.0 alpha:a];
        case KULER_BLACK:return [UIColor colorWithRed:40/255.0  green:40/255.0 blue:40/255.0 alpha:a];
        case KULER_CYAN:return [UIColor colorWithRed:24/255.0 green:105/255.0 blue:145/255.0 alpha:a];
        case KULER_WHITE:return [UIColor colorWithRed:218/255.0 green:237/255.0 blue:226/255.0 alpha:a];
        case KULER_RED:return [UIColor colorWithRed:234/255.0 green:46/255.0 blue:73/255.0 alpha:a];
        default:return [UIColor clearColor];
    }
}

+(UIToolbar*)keyboardAccessoryToolBarWithButton:(NSString*)title
                                         target:(id) t
                                         action:(SEL) a
{
    UIToolbar *keyboardAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    keyboardAccessoryView.barStyle = UIBarStyleBlackTranslucent;
    keyboardAccessoryView.tintColor = [UIColor darkGrayColor];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:t action:a];
    doneButton.title = title;
    [keyboardAccessoryView setItems:[NSArray arrayWithObjects: flexSpace, doneButton, nil] animated:NO];
    return keyboardAccessoryView;
}

+(NSString*)stringFromPollState:(int) state
{
    switch (state) {
        case EDITING:
            return @"DRAFT";
        case VOTING:
            return @"ACTIVE";
        default:
            return @"UNKNOWN";
    }
}

+(NSString*)formatURLFromDateString:(NSString*) string
{
    NSMutableString *result = [string mutableCopy];
    [result replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
    return result;
}

+(void)renderView:(UIView*)view
 withCornerRadius:(CGFloat)r
   andBorderWidth:(CGFloat)w
{
    // border
    view.layer.borderColor = [[UIColor whiteColor] CGColor];
    view.layer.borderWidth = w;
    
    // corner
    view.layer.cornerRadius = r;
    view.layer.masksToBounds = YES;
}

+(void)renderCommentBox:(UIView*)view
 withCornerRadius:(CGFloat)r
   andBorderWidth:(CGFloat)w
{
    // border
    view.layer.borderColor = [[Utility colorFromKuler:KULER_BLACK alpha:1] CGColor];
    view.layer.borderWidth = w;
    
    // corner
    view.layer.cornerRadius = r;
    view.layer.masksToBounds = YES;
}

@end
