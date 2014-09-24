//
//  CDAUtilities.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

#import <ContentfulDeliveryAPI/CDAClient.h>

NSString* CDACacheDirectory();
NSString* CDACacheFileNameForQuery(CDAClient* client, CDAResourceType resourceType, NSDictionary* query);
NSString* CDACacheFileNameForResource(CDAResource* resource);
NSArray* CDAClassGetSubclasses(Class parentClass);
void CDADecodeObjectWithCoder(id object, NSCoder* aDecoder);
void CDAEncodeObjectWithCoder(id object, NSCoder* aCoder);
BOOL CDAIsNoNetworkError(NSError* error);
NSString* CDASquashCharactersFromSetInString(NSCharacterSet* characterSet, NSString* string);
