//
//  CDAEntriesViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/03/14.
//
//

#import <UIKit/UIKit.h>

@class CDAClient;
@class CDAEntriesViewController;
@class CDAEntry;

/** 
 The delegate of a `CDAEntriesViewController` object must adopt the `CDAEntriesViewControllerDelegate`
 protocol. The one optional method of the protocol allows reacting to row selection by the user.
 
 By default, a `CDAFieldsViewController` will be pushed to the entries view controller' 
 `navigationController` with the selected Entry as parameter.
 */
@protocol CDAEntriesViewControllerDelegate <NSObject>

@optional

/**
 *  This delegate method is called when the user selects a row in the table view of entries.
 *
 *  @param entriesViewController    The sender of the delegate method.
 *  @param entry                    The Entry associated with the row the user selected.
 */
-(void)entriesViewController:(CDAEntriesViewController*)entriesViewController
       didSelectRowWithEntry:(CDAEntry*)entry;

@end

/**
 `CDAEntriesViewController` is designed to make it easy to display a list of Entries in a table view.
 
 It will automatically request the data from a Space you specify with a query you define once it is 
 visible on screen. Additionally, it provides a mapping for selecting which Fields to display in the 
 cells of the table view.
 */
@interface CDAEntriesViewController : UITableViewController

/** @name Initializing the CDAEntriesViewController Object */

/**
*  Initializes a new instance with the given cell mapping. The cell mapping is a dictionary, containing
*  keypaths to properties on each cell and mapping them to Field identifiers. This is used for
*  automatically filling new cells with data from the Entries.
*
*  Example:
*
*  `@{ @"textLabel.text": @"fields.name" }`
*
*  This will set the text of each cell's `textLabel` to the corresponding Entry's value of Field `name`.
*
*  @param cellMapping A dictionary describing the Field values used to set table view cell properties.
*
*  @return An initialized `CDAEntriesViewController` or `nil` if the object couldn't be created.
*/
-(id)initWithCellMapping:(NSDictionary*)cellMapping;

/**
 *  Initializes a new instance with the given cell mapping and a local array of Entries. This allows
 *  displaying a list of Entries which were already fetched from the server. In this case, the `client`
 *  and `query` properties will be completely ignored.
 *
 *  @param cellMapping A dictionary described the Field values used to set table view cell properties.
 *  @see initWithCellMapping: for a description of the cell mapping format.
 *  @param items       An array of locally available Entries.
 *
 *  @return An initialized `CDAEntriesViewController` or `nil` if the object couldn't be created.
 */
-(id)initWithCellMapping:(NSDictionary *)cellMapping items:(NSArray *)items;

/** @name Managing the Delegate */

/**
 The object that acts as the delegate of the receiving entries view controller.
 
 The delegate must adopt the `CDAEntriesViewControllerDelegate` protocol. The delegate is not retained.
 */
@property (nonatomic, weak) id<CDAEntriesViewControllerDelegate> delegate;

/** @name Configure Data to Fetch */

/** 
 The client which is used to fetch Entries. Make sure to set it before displaying the view
 controller's view or an exception will be thrown unless `initWithCellMapping:items:` was used to
 initialize this view controller.
 
 The client is not retained.
 */
@property (nonatomic, weak) CDAClient* client;

/** The items which are currently displayed in this view controller's table view. */
@property (nonatomic, readonly) NSArray* items;

/** 
 The query parameters used for fetching Entries. By default, all Entries from the Space associated
 with the client will be fetched.
 */
@property (nonatomic) NSDictionary* query;

/** @name Configuring behaviour in Subclasses */

/** 
 The table view's data source is configured to return cells of this class. If you wish to use your own
 `UITableViewCell` subclass, override this method in your subclass of `CDAEntriesViewController`.
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
