//
//  CDAContentType.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAClient+Private.h"
#import "CDAContentType.h"
#import "CDAContentTypeRegistry.h"
#import "CDAField+Private.h"
#import "CDAResource+Private.h"

@interface CDAContentType ()

@property (nonatomic) NSDictionary* allFields;
@property (nonatomic) NSString* displayField;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* userDescription;

@end

#pragma mark -

@implementation CDAContentType

+(NSString *)CDAType {
    return @"ContentType";
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"CDAContentType %@ with %ld fields",
            self.name, (long)self.allFields.count];
}

-(CDAField*)fieldForIdentifier:(NSString *)identifier {
    return self.allFields[identifier];
}

-(NSArray*)fields {
    return [self.allFields.allValues sortedArrayUsingComparator:^NSComparisonResult(CDAField* field1, CDAField* field2) { return [field1.name localizedStandardCompare:field2.name]; }];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        self.displayField = dictionary[@"displayField"];
        self.name = dictionary[@"name"];
        self.userDescription = dictionary[@"description"];
        
        NSMutableDictionary* allFields = [@{} mutableCopy];
        
        for (NSDictionary* field in dictionary[@"fields"]) {
            CDAField* fieldObject = [[CDAField alloc] initWithDictionary:field client:self.client];
            allFields[fieldObject.identifier] = fieldObject;
        }
        
        self.allFields = allFields;
        
        [self.client.contentTypeRegistry addContentType:self];
    }
    return self;
}

-(void)resolveWithSuccess:(void (^)(CDAResponse *, CDAResource *))success
                  failure:(void (^)(CDAResponse *, NSError *))failure {
    if (self.fetched) {
        [super resolveWithSuccess:success failure:failure];
        return;
    }
    
    [self.client fetchContentTypeWithIdentifier:self.identifier
                                        success:^(CDAResponse *response, CDAContentType *contentType) {
                                            if (success) {
                                                success(response, contentType);
                                            }
                                        } failure:failure];
}

@end
