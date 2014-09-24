//
//  CDAField.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import ObjectiveC.runtime;

#import <ContentfulDeliveryAPI/CDAResource.h>

#import "CDAField+Private.h"
#import "CDAFieldValueTransformer.h"
#import "CDAUtilities.h"

@interface CDAField ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic) BOOL disabled;
@property (nonatomic, readonly) NSDictionary* fieldTypes;
@property (nonatomic) NSString* identifier;
@property (nonatomic) CDAFieldType itemType;
@property (nonatomic) BOOL localized;
@property (nonatomic) BOOL required;
@property (nonatomic) CDAFieldValueTransformer* transformer;

@end

#pragma mark -

@implementation CDAField

+(BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark -

-(NSString *)description {
    NSString* type = [[self.fieldTypes allKeysForObject:@(self.type)] firstObject];
    return [NSString stringWithFormat:@"CDAField %@ of type %@", self.identifier, type];
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary* rep = [@{ @"id": self.identifier,
                                   @"name": self.name } mutableCopy];

    switch (self.type) {
        case CDAFieldTypeAsset:
        case CDAFieldTypeEntry:
            rep[@"type"] = [self fieldTypeToString:CDAFieldTypeLink];
            rep[@"linkType"] = [self fieldTypeToString:self.type];
            break;

        case CDAFieldTypeArray:
        case CDAFieldTypeBoolean:
        case CDAFieldTypeDate:
        case CDAFieldTypeInteger:
        case CDAFieldTypeLink:
        case CDAFieldTypeLocation:
        case CDAFieldTypeNone:
        case CDAFieldTypeNumber:
        case CDAFieldTypeObject:
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            rep[@"type"] = [self fieldTypeToString:self.type];
            break;
    }

    switch (self.itemType) {
        case CDAFieldTypeNone:
            break;
        case CDAFieldTypeAsset:
        case CDAFieldTypeEntry:
            rep[@"items"] = @{ @"type": [self fieldTypeToString:CDAFieldTypeLink],
                               @"linkType": [self fieldTypeToString:self.itemType] };
            break;
        case CDAFieldTypeArray:
        case CDAFieldTypeBoolean:
        case CDAFieldTypeDate:
        case CDAFieldTypeInteger:
        case CDAFieldTypeLink:
        case CDAFieldTypeLocation:
        case CDAFieldTypeNumber:
        case CDAFieldTypeObject:
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            rep[@"items"] = @{ @"type": [self fieldTypeToString:self.itemType] };
            break;
    }

    return rep;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    CDAEncodeObjectWithCoder(self, aCoder);
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
                                            @"Object": @(CDAFieldTypeObject),
                                            @"Symbol": @(CDAFieldTypeSymbol),
                                            @"Text": @(CDAFieldTypeText),
                                            @"Entry": @(CDAFieldTypeEntry),
                                            @"Asset": @(CDAFieldTypeAsset),
                                            }; });
    return fieldTypes;
}

-(NSString*)fieldTypeToString:(CDAFieldType)fieldType {
    NSArray* possibleFieldTypes = [self.fieldTypes allKeysForObject:@(fieldType)];
    NSAssert(possibleFieldTypes.count == 1,
             @"Field-type %ld lacks proper string representation.", (long)fieldType);
    return possibleFieldTypes[0];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        CDADecodeObjectWithCoder(self, aDecoder);
    }
    return self;
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
        
        self.disabled = [dictionary[@"disabled"] boolValue];
        self.localized = [dictionary[@"localized"] boolValue];
        self.required = [dictionary[@"required"] boolValue];
        
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
