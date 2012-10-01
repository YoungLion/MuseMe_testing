//
//  Utility.h
//  
//
//  Created by Yong Lin on 8/25/12.
//  Copyright (c) 2012 MuseMe Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RKJSONParserJSONKit.h>
#import "MuseMeDelegate.h" 

@interface Utility : NSObject
{
    
}

+(void) showAlert:(NSString *) title message:(NSString *) msg; 
+(void) setObject:(id) obj forKey:(NSString*) key;
+(id) getObjectForKey:(NSString*) key;
+ (NSString*) formatCurrencyWithString: (NSString *) string;
+(NSString*) formatCurrencyWithNumber: (NSNumber *) number;
+(UILabel*)formatTitleWithString:(NSString *) titleText;
+(NSString*)formatTimeWithDate:(NSDate *) date;
+(NSURL*)URLForCategory:(PollCategory) category;
+(UIImage*)iconForCategory:(PollCategory) category;
+(NSString*)stringFromCategory:(PollCategory) category;
+(PollCategory)categoryFromString:(NSString*) string;
+(UIBarButtonItem *)createSquareBarButtonItemWithNormalStateImage:(NSString*)normalStateImage
                                         andHighlightedStateImage:(NSString*) highlightedStateImage
                                                           target:(id)tgt
                                                           action:(SEL)a;
+(UIColor*)colorFromKuler:(int)kulerColor
                   alpha:(CGFloat)alpha;
+(UIToolbar*)keyboardAccessoryToolBarWithButton:(NSString*)title
                                         target:(id) t
                                         action:(SEL) a;
+(NSString*)stringFromPollState:(int) state;
+(NSString*)formatURLFromDateString:(NSString*) string;
+(void)renderView:(UIView *)view
   withBackground:(UIView *)background
 withCornerRadius:(CGFloat)r
   andBorderWidth:(CGFloat)w
     shadowOffSet:(CGFloat)d;
+(void)renderCommentBox:(UIView*)view
       withCornerRadius:(CGFloat)r
         andBorderWidth:(CGFloat)w;

@end
