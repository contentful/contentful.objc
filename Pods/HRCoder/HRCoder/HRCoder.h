//
//  HRCoder.h
//
//  Version 1.3.1
//
//  Created by Nick Lockwood on 24/04/2012.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/HRCoder
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import <Foundation/Foundation.h>


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


extern NSString *const HRCoderException;
extern NSString *const HRCoderClassNameKey;
extern NSString *const HRCoderRootObjectKey;
extern NSString *const HRCoderObjectAliasKey;
extern NSString *const HRCoderBase64DataKey;


typedef NS_ENUM(NSUInteger, HRCoderFormat)
{
    HRCoderFormatXML = 0,
    HRCoderFormatJSON,
    HRCoderFormatBinary,
};


@interface HRCoder : NSCoder

@property (nonatomic, assign) HRCoderFormat outputFormat;

+ (id)unarchiveObjectWithPlistOrJSON:(id)plistOrJSON;
+ (id)unarchiveObjectWithData:(NSData *)data;
+ (id)unarchiveObjectWithFile:(NSString *)path;
+ (id)archivedPlistWithRootObject:(id)rootObject;
+ (id)archivedJSONWithRootObject:(id)rootObject;
+ (NSData *)archivedDataWithRootObject:(id)rootObject;
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;

- (id)initForReadingWithData:(NSData *)data;
- (id)initForWritingWithMutableData:(NSMutableData *)data;
- (void)finishDecoding;
- (void)finishEncoding;

@end
