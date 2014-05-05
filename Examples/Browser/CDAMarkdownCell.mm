//
//  CDAMarkdownCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <Bypass/Bypass.h>

#import "CDAMarkdownCell.h"

@interface CDAMarkdownCell ()

@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation CDAMarkdownCell

+(UIFont*)usedFont {
    return [UIFont systemFontOfSize:18.0];
}

#pragma mark -

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:self.bounds];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.editable = NO;
        self.textView.font = [[self class] usedFont];
        if ([self.textView respondsToSelector:@selector(textContainerInset)]) {
            self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 20.0);
        }
        [self addSubview:self.textView];
    }
    return self;
}

- (void)layoutSubviews {
    self.textView.frame = self.bounds;
    [self.contentView bringSubviewToFront:self.textView];
}

- (void)setMarkdownText:(NSString *)markdownText {
    _markdownText = markdownText;
    
    BPDocument* document = [[BPParser new] parse:markdownText];
    BPAttributedStringConverter* converter = [BPAttributedStringConverter new];
    converter.displaySettings.quoteFont = [UIFont fontWithName:@"Marion-Italic"
                                                          size:[UIFont systemFontSize] + 1.0f];
    NSAttributedString* attributedText = [converter convertDocument:document];
    
    self.textView.attributedText = attributedText;
}

@end
