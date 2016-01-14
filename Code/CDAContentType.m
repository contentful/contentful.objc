//
//  CDAContentType.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAContentType.h>

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAField+Private.h"
#import "CDAResource+Private.h"

@interface CDAContentType ()

@property (nonatomic) NSDictionary* allFields;
@property (nonatomic) NSString* displayField;
@property (nonatomic) NSArray* fields;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* userDescription;

@end

#pragma mark -

@implementation CDAContentType

+(NSString *)CDAType {
    return @"ContentType";
}

+(Class)fieldClass {
    return CDAField.class;
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"CDAContentType %@ with %ld fields",
            self.name, (long)self.allFields.count];
}

-(CDAField*)fieldForIdentifier:(NSString *)identifier {
    return self.allFields[identifier];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        if (dictionary[@"name"]) {
            NSString* name = dictionary[@"name"];
            self.name = name;
        } else {
            [NSException raise:NSInvalidArgumentException format:@"Content-Types need a name"];
        }

        self.displayField = dictionary[@"displayField"];
        self.userDescription = dictionary[@"description"];
        
        NSMutableDictionary* allFields = [@{} mutableCopy];
        NSMutableArray* fields = [@[] mutableCopy];
        
        for (NSDictionary* field in dictionary[@"fields"]) {
            CDAField* fieldObject = [[[self.class fieldClass] alloc] initWithDictionary:field
                                                                                 client:self.client];
            
            allFields[fieldObject.identifier] = fieldObject;
            [fields addObject:fieldObject];
        }
        
        self.allFields = allFields;
        self.fields = fields;
        
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
