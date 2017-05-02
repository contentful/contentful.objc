//
//  CDAFieldCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

@import UIKit;

@class CDAField;

@interface CDAFieldCell : UITableViewCell

@property (nonatomic) CDAField* field;
@property (nonatomic) id value;

@end
