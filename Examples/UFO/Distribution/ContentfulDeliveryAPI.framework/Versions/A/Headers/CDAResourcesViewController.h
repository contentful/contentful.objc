//
//  CDAResourcesViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

@import UIKit;

#import <ContentfulDeliveryAPI/CDAClient.h>

@class CDAResource;

/**
 `CDAResourcesViewController` is designed to make it easy to display a list of Resources in a table view.
 
 It will automatically request the data from a Space you specify with a query you define once it is
 visible on screen. Additionally, it provides a mapping for selecting which Fields to display in the
 cells of the table view.
 */
@interface CDAResourcesViewController : UITableViewController

/** @name Initializing the CDAResourcesViewController Object */

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
 *  @param cellMapping A dictionary describing the Field values used to set table view cell properties.
 *
 *  @return An initialized `CDAResourcesViewController` or `nil` if the object couldn't be created.
 */
-(id)initWithCellMapping:(NSDictionary*)cellMapping;

/**
 *  Initializes a new instance with the given cell mapping and a local array of Resources. This allows
 *  displaying a list of Resources which were already fetched from the server. In this case, the `client`
 *  and `query` properties will be completely ignored.
 *
 *  @param cellMapping A dictionary described the Field values used to set table view cell properties.
 *  @see initWithCellMapping: for a description of the cell mapping format.
 *  @param items       An array of locally available Resources.
 *
 *  @return An initialized `CDAResourcesViewController` or `nil` if the object couldn't be created.
 */
-(id)initWithCellMapping:(NSDictionary *)cellMapping items:(NSArray *)items;

/** @name Reacting on Cell Selection */

/**
 *  This is a convenience method which sits on top of `tableView:didSelectRowAtIndexPath:`, making it
 *  easy to react on cell selection by the user. It is intended to be overridden in subclasses.
 *
 *
 *  @param resource The Resource displayed in the cell selected by the user.
 */
-(void)didSelectRowWithResource:(CDAResource*)resource;

/** @name Configure Data to Fetch */

/**
 The client which is used to fetch Resources. Make sure to set it before displaying the view
 controller's view or an exception will be thrown unless `initWithCellMapping:items:` was used to
 initialize this view controller.
 
 The client is not retained.
 */
@property (nonatomic, weak) CDAClient* client;

/** 
 Locale to use when querying Resources. 
 
 This property has no effect when showing locally available Resources.
 */
@property (nonatomic, copy) NSString* locale;

/** The items which are currently displayed in this view controller's table view. */
@property (nonatomic, readonly) NSArray* items;

/**
 The query parameters used for fetching Resources. By default, all Resources from the Space associated
 with the client will be fetched.
 */
@property (nonatomic) NSDictionary* query;

/** The type of Resources which ought to be fetched. */
@property (nonatomic) CDAResourceType resourceType;

/**
 Activate the built-in support for caching Resources offline.
 
 The cached data will only be used if the device is truly offline, use a `CDASyncedSpace` instead for
 general purpose caching.
 */
@property (nonatomic) BOOL offlineCaching;

/** @name Configure Appearance */

/** 
 Configure whether or not to show a search bar.
 
 The query will be handled automatically, by utilizing the full-text search of Contentful.
 */
@property (nonatomic) BOOL showSearchBar;

/** @name Configuring behaviour in Subclasses */

/**
 The table view's data source is configured to return cells of this class. If you wish to use your own
 `UITableViewCell` subclass, override this method in your subclass of `CDAResourcesViewController`.
 */
+(Class)cellClass;

/**
 *  By default, errors related to requests made to the Contentful API will be displayed in a
 *  `UIAlertView`. You can override this method in your subclass if you want to implement different
 *  behaviour.
 *
 *  @param error The error which occured.
 */
-(void)showError:(NSError*)error;

@end
