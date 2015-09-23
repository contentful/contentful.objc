//
//  CDALocalizablePersistedEntry.h
//  
//
//  Created by Boris Bügling on 23/09/15.
//
//

@import CoreData;

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

/** Add a localized entry to the collection. */
- (void)addLocalizedEntriesObject:(id<CDAPersistedEntry>)entry;

/** Remove a localized entry to the collection. */
- (void)removeLocalizedEntriesObject:(id<CDAPersistedEntry>)entry;

@end
