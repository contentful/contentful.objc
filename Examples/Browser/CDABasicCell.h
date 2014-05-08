//
//  CDABasicCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CDACellType) {
    CDACellTypeAny,
    CDACellTypeFirst,
    CDACellTypeLast,
};

@interface CDABasicCell : UICollectionViewCell

@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic) CDACellType cellType;
@property (nonatomic, readonly) UILabel* detailTextLabel;
@property (nonatomic, readonly) UILabel* textLabel;

@end
