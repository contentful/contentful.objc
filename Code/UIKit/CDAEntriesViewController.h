//
//  CDAEntriesViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResourcesViewController.h>

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
-(void)entriesViewController:(CDAEntriesViewController* __nonnull)entriesViewController
       didSelectRowWithEntry:(CDAEntry* __nonnull)entry;

@end

/**
 `CDAEntriesViewController` is designed to make it easy to display a list of Entries in a table view.
 
 It will automatically request the data from a Space you specify with a query you define once it is 
 visible on screen. Additionally, it provides a mapping for selecting which Fields to display in the 
 cells of the table view.
 */
@interface CDAEntriesViewController : CDAResourcesViewController <CDAEntriesViewControllerDelegate>

/** @name Managing the Delegate */

/**
 The object that acts as the delegate of the receiving entries view controller.
 
 The delegate must adopt the `CDAEntriesViewControllerDelegate` protocol. The delegate is not retained.
 */
@property (nonatomic, weak) id<CDAEntriesViewControllerDelegate> __nullable delegate;

@end
