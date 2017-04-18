//
//  TestErrors.m
//  ManagementSDK
//
//  Created by Boris Bügling on 03/12/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "CDAResource+Management.h"

SpecBegin(Errors)

describe(@"CMA", ^{
    it(@"throws when -URLPath is not overridden", ^{
        CDAClient* client = [CDAClient new];
        CDAResource* resource = [CDAResource new];
        [resource performSelector:@selector(setClient:) withObject:client];

        expect(^{ [resource performDeleteToFragment:@"" withSuccess:nil failure:nil]; }).to.raiseAny();
        expect(client).toNot.beNil();
    });

    it(@"throws when specifying validations with invalid bounds", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        expect(^{ [CMAValidation validationOfArraySizeWithMinimumValue:nil
                                                          maximumValue:nil]; }).to.raiseAny();
        expect(^{ [CMAValidation validationOfValueRangeWithMinimumValue:nil
                                                           maximumValue:nil]; }).to.raiseAny();
#pragma clang diagnostic pop
    });
});

SpecEnd
