//
//  CDAUtilities.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

#import "CDAClient.h"

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
