//
//  CDAFieldsViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

@import UIKit;

@class CDAEntry;

/**
 `CDAFieldsViewController` is designed to make it easy to display Field values of a single Entry in a
 simple way.
 
 This view controller's view will show a table view in `UITableViewStyleGrouped` style with one section
 containing Field values of the Entry.
 */
@interface CDAFieldsViewController : UITableViewController

/**
 *  By default, values for all Fields of the Entry will be shown. If you want to limit which Fields
 *  are shown and also influence the order in which they are shown, override this method in your
 *  subclass.
 *
 *  If this method returns `nil`, all Fields will be shown in alphabetical order.
 *
 *  @return An array of Field identifiers as strings. Any identifiers which do not match actual
 *      Fields on the Entry will be ignored.
 */
@property (nonatomic, readonly) NSArray* visibleFields;

/** @name Initializing the CDAEntriesViewController Object */

/**
 *  Initializes a new instance with the given Entry.
 *
 *  @param entry The Entry whose values should be shown in this view controller's view.
 *
 *  @return An initialized `CDAFieldsViewController` or `nil` if the object couldn't be created.
 */
-(id)initWithEntry:(CDAEntry*)entry;

/**
 *  Initializes a new instance with the given Entry.
 *
 *  @param entry   The Entry whose values should be shown in this view controller's view.
 *  @param style   The style of table view to use for displaying the Fields.
 *
 *  @return An initialized `CDAFieldsViewController` or `nil` if the object couldn't be created.
 */
-(id)initWithEntry:(CDAEntry*)entry tableViewStyle:(UITableViewStyle)style;

/** @name Reacting on Cell Selection */

/**
 *  This is a convenience method which sits on top of `tableView:didSelectRowAtIndexPath:`, making it
 *  easy to react on cell selection by the user. It is intended to be overridden in subclasses.
 *
 *  By default, this method pushes new view controller's specific to the corresponding field's content
 *  type to this view controller's navigation controller. It will act on fields of the types 
 *  `CDAFieldTypeArray`, `CDAFieldTypeLink` and `CDAFieldTypeLocation`. For fields of type
 *  `CDAFieldTypeText` or `CDAFieldTypeSymbol`, it will act if the text is too long to be completely
 *  shown inline. As values for any other types are always shown inline, nothing will be done for them
 *  by default.
 *
 *  @param value The Entry's value shown in the cell the user selected.
 *  @param field The Field definition for the cell the user selected.
 */
-(void)didSelectRowWithValue:(id)value forField:(CDAField*)field;

/** @name Configuring behaviour in Subclasses */

/**
 *  By default, errors related to requests made to the Contentful API will be displayed in a
 *  `UIAlertView`. You can override this method in your subclass if you want to implement different
 *  behaviour.
 *
 *  @param error The error which occured.
 */
-(void)showError:(NSError*)error;

@end
