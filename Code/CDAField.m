//
//  CDAField.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

#import "CDAField.h"
#import "CDAFieldValueTransformer.h"

@interface CDAField ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic, readonly) NSDictionary* fieldTypes;
@property (nonatomic) NSString* identifier;
@property (nonatomic) CDAFieldType itemType;
@property (nonatomic) NSString* name;
@property (nonatomic) CDAFieldValueTransformer* transformer;
@property (nonatomic) CDAFieldType type;

@end

#pragma mark -

@implementation CDAField

-(NSString *)description {
    NSString* type = [[self.fieldTypes allKeysForObject:@(self.type)] firstObject];
    return [NSString stringWithFormat:@"CDAField %@ of type %@", self.identifier, type];
}

-(NSDictionary*)fieldTypes {
    static dispatch_once_t once;
    static NSDictionary* fieldTypes;
    dispatch_once(&once, ^ { fieldTypes = @{
                                            @"Array": @(CDAFieldTypeArray),
                                            @"Boolean": @(CDAFieldTypeBoolean),
                                            @"Date": @(CDAFieldTypeDate),
                                            @"Integer": @(CDAFieldTypeInteger),
                                            @"Link": @(CDAFieldTypeLink),
                                            @"Location": @(CDAFieldTypeLocation),
                                            @"Number": @(CDAFieldTypeNumber),
                                            @"Symbol": @(CDAFieldTypeSymbol),
                                            @"Text": @(CDAFieldTypeText),
                                            }; });
    return fieldTypes;
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super init];
    if (self) {
        NSParameterAssert(client);
        self.client = client;
        
        self.identifier = dictionary[@"id"];
        self.name = dictionary[@"name"];
        
        NSString* itemType = dictionary[@"items"][@"type"];
        if (itemType) {
            self.itemType = [self stringToFieldType:itemType];
        } else {
            self.itemType = CDAFieldTypeNone;
        }
        
        self.type = [self stringToFieldType:dictionary[@"type"]];
        
        self.transformer = [CDAFieldValueTransformer transformerOfType:self.type client:self.client];
        self.transformer.itemType = self.itemType;
    }
    return self;
}

-(id)parseValue:(id)value {
    return [self.transformer transformedValue:value];
}

-(CDAFieldType)stringToFieldType:(NSString*)string {
    NSNumber* fieldTypeNumber = self.fieldTypes[string];
    NSAssert(fieldTypeNumber, @"Unknown field-type '%@'", string);
    return [fieldTypeNumber integerValue];
}

@end
