//
//  CDABasicCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import "CDABasicCell.h"

@interface CDABasicCell ()

@property (nonatomic) UITableViewCell* cell;
@property (nonatomic) UIView* separatorView;

@end

#pragma mark -

@implementation CDABasicCell

-(UITableViewCellAccessoryType)accessoryType {
    return self.cell.accessoryType;
}

-(UILabel *)detailTextLabel {
    return self.cell.detailTextLabel;
}

-(CGRect)frameForCellType:(CDACellType)cellType {
    switch (cellType) {
        case CDACellTypeAny:
            return CGRectMake(15.0,
                              self.frame.size.height - 1.0,
                              self.frame.size.width - 15.0,
                              1.0);
        
        case CDACellTypeFirst:
            return CGRectMake(0.0,
                              0.0,
                              self.frame.size.width,
                              1.0);
            
        case CDACellTypeLast:
            return CGRectMake(0.0,
                              self.frame.size.height - 1.0,
                              self.frame.size.width,
                              1.0);
            
    }
    
    return CGRectZero;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                           reuseIdentifier:nil];
        self.cell.backgroundColor = [UIColor whiteColor];
        self.cell.frame = self.bounds;
        self.cell.userInteractionEnabled = NO;
        [self addSubview:self.cell];
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.separatorView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        [self addSubview:self.separatorView];
        
        self.cellType = CDACellTypeAny;
    }
    return self;
}

-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    self.cell.accessoryType = accessoryType;
}

-(void)setCellType:(CDACellType)cellType {
    _cellType = cellType;
    
    self.separatorView.frame = [self frameForCellType:cellType];
    
    if (cellType == CDACellTypeFirst) {
        UIView* separator = [[UIView alloc] initWithFrame:[self frameForCellType:CDACellTypeAny]];
        separator.backgroundColor = self.separatorView.backgroundColor;
        [self addSubview:separator];
    }
}

-(UILabel *)textLabel {
    return self.cell.textLabel;
}

@end
