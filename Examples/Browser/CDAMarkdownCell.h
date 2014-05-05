//
//  CDAMarkdownCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <UIKit/UIKit.h>

@interface CDAMarkdownCell : UITableViewCell

@property (nonatomic) NSString* markdownText;
@property (nonatomic, readonly) UITextView* textView;

+(UIFont*)usedFont;

@end
