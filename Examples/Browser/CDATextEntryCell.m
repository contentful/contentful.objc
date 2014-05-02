//
//  CDATextEntryCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import "CDATextEntryCell.h"

@interface CDATextEntryCell ()

@property (nonatomic) UITextField* textField;

@end

#pragma mark -

@implementation CDATextEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width / 2, self.frame.size.height)];
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.clearsOnBeginEditing = YES;
        self.textField.enablesReturnKeyAutomatically = YES;
        
        self.accessoryView = self.textField;
    }
    return self;
}

@end
