//
//  RealmClassHierarchy.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 23/02/16.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <Foundation/Foundation.h>
#import <Realm/RLMObject.h>

#import "RealmAsset.h"

@interface RealmRootObject: RLMObject <CDAPersistedEntry>

@end

#pragma mark -

@interface RealmClassHierarchy : RealmRootObject

@property (nonatomic, strong) RealmClassHierarchy* bestFriend;
@property (nonatomic, strong) NSString * name;

@end
