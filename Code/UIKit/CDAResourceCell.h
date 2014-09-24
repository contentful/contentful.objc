//
//  CDAResourceCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

@import UIKit;

/** UICollectionViewCell subclass for displaying Resources. */
@interface CDAResourceCell : UICollectionViewCell

/** @name Accessing Subviews */

/** An image view which will display the image at `imageURL`, eventually. */
@property (nonatomic, readonly) UIImageView* imageView;

/** @name Specifying Content */

/** URL of an image which should be displayed in the `imageView` of this cell. */
@property (nonatomic) NSURL* imageURL;

@end
