//
//  UILabel+Alignment.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/05/14.
//
//

#import "UILabel+Alignment.h"

@implementation UILabel (Alignment)

- (void)cda_alignBottom
{
    CGSize fontSize = [self.text sizeWithAttributes:@{ NSFontAttributeName: self.font }];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    CGSize theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName: self.font }
                                                   context:nil].size;
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for(int i=0; i< newLinesToPad; i++)
    {
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
    }
}

@end
