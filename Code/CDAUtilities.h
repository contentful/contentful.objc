//
//  CDAUtilities.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <Foundation/Foundation.h>

NSArray* CDAClassGetSubclasses(Class parentClass);
void CDADecodeObjectWithCoder(id object, NSCoder* aDecoder);
void CDAEncodeObjectWithCoder(id object, NSCoder* aCoder);
