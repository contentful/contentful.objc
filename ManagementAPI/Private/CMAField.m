//
//  CMAField.m
//  Pods
//
//  Created by Boris Bügling on 29/07/14.
//
//

#import "CDAField+Private.h"
#import "CMAField.h"
#import "CMAValidation+Private.h"

@interface CDAField ()

@property (nonatomic) NSMutableArray* mutableValidations;

-(NSDictionary*)dictionaryRepresentation;
-(void)setIdentifier:(NSString*)identifier;
-(void)setName:(NSString*)name;
-(void)setType:(CDAFieldType)type;

@end

#pragma mark -

@implementation CMAField

@dynamic itemType;
@synthesize mutableValidations = _mutableValidations;

#pragma mark -

+(instancetype)fieldWithName:(NSString *)name type:(CDAFieldType)type {
    NSDictionary* fieldDictionary = @{ @"type": @"Symbol",
                                       @"id": [self identifierFromString:name] };
    CMAField* field = [[self alloc] initWithDictionary:fieldDictionary
                                                client:(CDAClient*)[NSNull null]
                                 localizationAvailable:NO];
    field.name = name;
    field.type = type;
    return field;
}

+(NSString*)identifierFromString:(NSString*)string {
    NSArray* components = [string componentsSeparatedByString:@" "];

    if (components.count == 0) {
        return @"";
    }

    NSMutableString* identifier = [[components[0] lowercaseString] mutableCopy];

    for (NSUInteger i = 1; i < components.count; i++) {
        [identifier appendString:[components[i] capitalizedString]];
    }

    return [identifier copy];
}

#pragma mark -

-(void)addValidation:(CMAValidation*)validation {
    [self.mutableValidations addObject:validation];
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary* base = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    NSMutableArray* allValidations = [[self.mutableValidations valueForKey:@"dictionaryRepresentation"] mutableCopy];

    if (self.type == CDAFieldTypeArray) {
        NSMutableArray* itemValidations = [@[] mutableCopy];

        NSArray* const itemValidationNames = @[@"linkContentType", @"linkMimetypeGroup"];
        for (NSDictionary* validation in allValidations) {
            if (![itemValidationNames containsObject:(NSString * _Nonnull)validation.allKeys.firstObject]) {
                continue;
            }

            [itemValidations addObject:validation];
            [allValidations removeObject:validation];
        }

        NSMutableDictionary* items = [base[@"items"] mutableCopy];
        items[@"validations"] = itemValidations;
        base[@"items"] = items;
    }

    base[@"validations"] = allValidations;
    return [base copy];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.omitted = [dictionary[@"omitted"] boolValue];
        self.mutableValidations = [@[] mutableCopy];

        for (NSArray* validations in @[dictionary[@"validations"] ?: @[], dictionary[@"items"][@"validations"] ?: @[]]) {
            for (NSDictionary* validation in validations) {
                [self.mutableValidations addObject:[[CMAValidation alloc] initWithDictionary:validation]];
            }
        }
    }
    return self;
}

-(NSArray *)validations {
    return [self.mutableValidations copy];
}

@end
