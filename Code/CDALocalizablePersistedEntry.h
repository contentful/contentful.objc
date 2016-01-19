//
//  CDALocalizablePersistedEntry.h
//  
//
//  Created by Boris Bügling on 23/09/15.
//
//

#if __has_feature(modules)
@import CoreData;
#else
#import <CoreData/CoreData.h>
#endif

#import <ContentfulDeliveryAPI/CDALocalizedPersistedEntry.h>

/**
 *  Any class representing a set of localizable persisted entries should inherit from this class.
 */
@interface CDALocalizablePersistedEntry : NSManagedObject <CDAPersistedEntry>

/** Set of localized entries of type `CDALocalizedPersistedEntry` */
@property (nonatomic) NSSet* localizedEntries;

@end

#pragma mark -

@interface CDALocalizablePersistedEntry (Additions)

/**
Add a localized entry to the collection.

@param entry The entry to add to the collection.
*/
- (void)addLocalizedEntriesObject:(id<CDAPersistedEntry>)entry;

/**
Remove a localized entry to the collection.

@param entry The entry to remove from the collection.
*/
- (void)removeLocalizedEntriesObject:(id<CDAPersistedEntry>)entry;

@end
