//
//  CDAArray+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>

@interface CDAArray ()

// TODO: Handle nextPageUrl in sync
@property (nonatomic, readonly) NSURL* nextPageUrl;
@property (nonatomic, readonly) NSURL* nextSyncUrl;
@property (nonatomic) NSDictionary* query;

@end
