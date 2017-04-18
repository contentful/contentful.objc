//
//  TestUtilities.m
//  ManagementSDK
//
//  Created by Boris Bügling on 05/03/15.
//  Copyright (c) 2015 Boris Bügling. All rights reserved.
//

#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "CDAClient+Private.h"
#import "CDAResource+Private.h"
#import "CMAUtilities.h"

void _itTestForSanitize(id self, int lineNumber, const char *fileName, NSString *name,
                        NSDictionary* fields) {
    it(name, ^{
        NSDictionary* sanitized = CMASanitizeParameterDictionaryForJSON(fields);

        __block NSError* error = nil;
        __block NSData* result = nil;

        expect(^{ result = [NSJSONSerialization dataWithJSONObject:sanitized
                                                           options:0
                                                             error:&error]; }).toNot.raiseAny();

        expect(result).toNot.beNil();
        expect(error).to.beNil();
    });
}

SpecBegin(Utilities)

describe(@"CMAClientAllowsChangingServer", ^{
    it(@"uses the default server by default", ^{
        CMAClient* client = [[CMAClient alloc] initWithAccessToken:@"XYZ"];

        CDAClient* deliveryClient = [client valueForKey:@"client"];
        XCTAssertEqualObjects(deliveryClient.configuration.server, @"api.contentful.com");
    });

    it(@"uses the specified server if changed", ^{
        CDAConfiguration* config = [CDAConfiguration defaultConfiguration];
        config.server = @"api.yolo.com";
        CMAClient* client = [[CMAClient alloc] initWithAccessToken:@"XYZ" configuration:config];

        CDAClient* deliveryClient = [client valueForKey:@"client"];
        XCTAssertEqualObjects(deliveryClient.configuration.server, @"api.yolo.com");
    });
});

describe(@"CMASanitizeParameterDictionaryForJSON", ^{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(40.0, 50.0);
    NSData* locationValue = [NSData dataWithBytes:&location length:sizeof(location)];

    CDAAsset* asset = (CDAAsset*)[CDAResource resourceObjectForDictionary:@{ @"sys": @{ @"type": @"Asset", @"id": @"XXX" } } client:[CDAClient new] localizationAvailable:NO];

    _itTestForSanitize(self, __LINE__, __FILE__, @"sanitizes arrays of values",
                       @{ @"en-US": @{ @"someAssetArray": @[asset] } });

    _itTestForSanitize(self, __LINE__, __FILE__, @"sanitizes asset values",
                       @{ @"en-US": @{ @"someAsset": asset } });

    _itTestForSanitize(self, __LINE__, __FILE__, @"sanitizes date values",
                       @{ @"en-US": @{ @"someDate": [NSDate new] } });

    _itTestForSanitize(self, __LINE__, __FILE__, @"sanitizes location values",
                       @{ @"en-US": @{ @"someLocation": locationValue } });
});

SpecEnd
