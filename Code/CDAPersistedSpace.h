//
//  CDAPersistedSpace.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/**
 *  Any class representing synchronized Spaces saved to a persistent store needs to conform 
 *  to this protocol.
 */
@protocol CDAPersistedSpace <NSObject>

/** Timestamp of the last synchronization operation. */
@property (nonatomic) NSDate* lastSyncTimestamp;
/** Token for the next synchronization operation. */
@property (nonatomic) NSString* syncToken;

@end
