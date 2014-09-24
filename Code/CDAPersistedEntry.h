//
//  CDAPersistedEntry.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import Foundation;

/**
 *  Any class representing Entries saved to a persistent store needs to conform to this protocol.
 */
@protocol CDAPersistedEntry <NSObject>

/** The `sys.id` of the Entry. */
@property (nonatomic) NSString* identifier;

@end
