//
//  RealmManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

/**
 A specialization of `CDAPersistenceManager` which allows you to use Realm.
 
 It is not need to set a class for Assets or Spaces, this implementation will always use the same one.
 
 */
@interface RealmManager : CDAPersistenceManager

@end
