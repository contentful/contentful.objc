//
//  CDAUtilities.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAClient.h>
#import <Foundation/Foundation.h>

NSString* CDACacheFileNameForQuery(CDAResourceType resourceType, NSDictionary* query);
NSArray* CDAClassGetSubclasses(Class parentClass);
void CDADecodeObjectWithCoder(id object, NSCoder* aDecoder);
void CDAEncodeObjectWithCoder(id object, NSCoder* aCoder);
BOOL CDAIsNoNetworkError(NSError* error);
