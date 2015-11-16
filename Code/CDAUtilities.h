//
//  CDAUtilities.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

#import <ContentfulDeliveryAPI/CDAClient.h>

// FIXME: Used to silence Xcode 6.3 beta - should be eventually removed.
#undef NSParameterAssert
#define NSParameterAssert(condition)	({\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Wcstring-format-directive\"")\
NSAssert((condition), @"Invalid parameter not satisfying: %s", #condition);\
_Pragma("clang diagnostic pop")\
} while(0);\
})

@class CDAResource;

NSString* CDACacheDirectory();
NSString* CDACacheFileNameForQuery(CDAClient* client, CDAResourceType resourceType, NSDictionary* query);
NSString* CDACacheFileNameForResource(CDAResource* resource);
NSArray* CDAClassGetSubclasses(Class parentClass);
BOOL CDAClassIsOfType(Class someClass, Class otherClass);
void CDADecodeObjectWithCoder(id object, NSCoder* aDecoder);
void CDAEncodeObjectWithCoder(id object, NSCoder* aCoder);
BOOL CDAIsNoNetworkError(NSError* error);
id CDAReadItemFromFileURL(NSURL* fileURL, CDAClient* client);
NSString* CDASquashCharactersFromSetInString(NSCharacterSet* characterSet, NSString* string);
NSString* CDAValueForQueryParameter(NSURL* url, NSString* queryParameter);
