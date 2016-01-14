//
//  CDASyncedSpace+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/CDASyncedSpace.h>

@interface CDASyncedSpace ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic) NSURL* nextPageUrl;
@property (nonatomic) NSURL* nextSyncUrl;

-(id)initWithAssets:(NSArray*)assets entries:(NSArray*)entries;
-(void)updateLastSyncTimestamp;

@end
