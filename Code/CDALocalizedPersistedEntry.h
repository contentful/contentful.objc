//
//  CDALocalizedPersistedEntry.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/09/15.
//
//

@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>

/**
 *  Any class representing localized Entries saved to a persistent store needs to conform to this 
 *  protocol.
 */
@protocol CDALocalizedPersistedEntry <CDAPersistedEntry>

/** The locale of this persisted entry */
@property (nonatomic) NSString* locale;

@end
