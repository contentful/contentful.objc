//
//  CDAEntryPreviewDataSource.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import <UIKit/UIKit.h>

extern NSString* const kAssetCell;
extern NSString* const kItemCell;
extern NSString* const kMapCell;
extern NSString* const kPrimitiveCell;
extern NSString* const kTextCell;

@interface CDAEntryPreviewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

-(id)initWithEntry:(CDAEntry*)entry;

@end
