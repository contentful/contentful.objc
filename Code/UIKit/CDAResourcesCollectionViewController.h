//
//  CDAResourcesCollectionViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAClient.h>
#import <UIKit/UIKit.h>

/**
 The `CDAResourcesCollectionViewController` makes it easy to display content from different kinds
 of Resources in an `UICollectionView`.
 */
@interface CDAResourcesCollectionViewController : UICollectionViewController

/** @name Initializing the CDAResourcesCollectionViewController Object */

/**
*  Initializes a new instance with the given cell mapping. The cell mapping is a dictionary, containing
*  keypaths to properties on each cell and mapping them to Field identifiers. This is used for
*  automatically filling new cells with data from the Resources.
*
*  Example:
*
*  `@{ @"textLabel.text": @"fields.name" }`
*
*  This will set the text of each cell's `textLabel` to the corresponding Entry's value of Field `name`.
*
*  @param layout      The layout to be used for the collection view.
*  @param cellMapping Mapping between cell properties and Resource content.
*
*  @return An initialized `CDAResourcesCollectionViewController` or `nil` if the object
*  couldn't be created.
*/
-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
                      cellMapping:(NSDictionary*)cellMapping;

/** @name Access Displayed Data */

/** The items which are currently displayed in this view controller's table view. */
@property (nonatomic, readonly) NSArray* items;

/** @name Configure Data to Fetch */

/**
 The client which is used to fetch Resources. Make sure to set it before displaying the view
 controller's view or an exception will be thrown unless `initWithCellMapping:items:` was used to
 initialize this view controller.
 
 The client is not retained.
 */
@property (nonatomic, weak) CDAClient* client;

/**
 The query parameters used for fetching Resources. By default, all Resources from the Space associated
 with the client will be fetched.
 */
@property (nonatomic) NSDictionary* query;

/** The type of Resources which ought to be fetched. */
@property (nonatomic) CDAResourceType resourceType;

@end
