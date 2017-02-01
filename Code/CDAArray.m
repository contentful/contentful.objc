//
//  CDAArray.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAArray+Private.h"
#import "CDAError+Private.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"

@interface CDAArray ()

@property (nonatomic) NSArray* errors;
@property (nonatomic) NSArray* items;
@property (nonatomic) NSUInteger limit;
@property (nonatomic) NSString* nextPageUrlString;
@property (nonatomic) NSString* nextSyncUrlString;
@property (nonatomic) NSUInteger skip;
@property (nonatomic) NSUInteger total;

@end

#pragma mark -

@implementation CDAArray

+(NSString *)CDAType {
    return @"Array";
}

#pragma mark -

-(NSString *)description {
    return self.items.description;
}

-(id)initWithDictionary:(NSDictionary*)dictionary
                 client:(CDAClient*)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary client:client localizationAvailable:localizationAvailable];
    if (self) {
        self.limit = [dictionary[@"limit"] unsignedIntegerValue];
        self.skip = [dictionary[@"skip"] unsignedIntegerValue];
        self.total = [dictionary[@"total"] unsignedIntegerValue];
        
        self.nextPageUrlString = dictionary[@"nextPageUrl"];
        self.nextSyncUrlString = dictionary[@"nextSyncUrl"];
        
        NSMutableArray* items = [@[] mutableCopy];
        for (NSDictionary* item in dictionary[@"items"]) {
            CDAResource* resource = [CDAResource resourceObjectForDictionary:item
                                                                      client:self.client
                                                       localizationAvailable:localizationAvailable];
            [items addObject:resource];
        }
        self.items = [items copy];
        
        NSMutableArray* errors = [@[] mutableCopy];
        for (NSDictionary* item in dictionary[@"errors"]) {
            CDAError* error = (CDAError*)[CDAResource resourceObjectForDictionary:item
                                                                           client:self.client
                                                            localizationAvailable:localizationAvailable];
            NSAssert(CDAClassIsOfType([error class], CDAError.class),
                     @"Invalid resource %@ in errors array.", error);
            [errors addObject:[error errorRepresentationWithCode:0]];
        }
        self.errors = [errors copy];
    }
    return self;
}

-(id)initWithItems:(NSArray *)items client:(CDAClient *)client {
    self = [self initWithDictionary:@{ @"sys": @{} } client:client localizationAvailable:NO];
    if (self) {
        self.limit = items.count;
        self.skip = 0;
        self.total = items.count;

        self.items = items;
    }
    return self;
}

-(NSURL *)nextPageUrl {
    return self.nextPageUrlString ? [NSURL URLWithString:self.nextPageUrlString] : nil;
}

-(NSURL *)nextSyncUrl {
    return self.nextSyncUrlString ? [NSURL URLWithString:self.nextSyncUrlString] : nil;
}

-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries {
    for (CDAResource* item in self.items) {
        [item resolveLinksWithIncludedAssets:assets entries:entries];
    }
}

-(void)setClient:(CDAClient *)client {
    [super setClient:client];
    
    for (id item in self.items) {
        if ([item respondsToSelector:@selector(setClient:)]) {
            [(CDAResource*)item setClient:self.client];
        }
    }
}

// We only encode properties that have write permissions
#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.errors             = [aDecoder decodeObjectForKey:@"errors"];
        self.items              = [aDecoder decodeObjectForKey:@"items"];
        self.query              = [aDecoder decodeObjectForKey:@"query"];
        self.nextPageUrlString  = [aDecoder decodeObjectForKey:@"nextPageUrlString"];
        self.nextSyncUrlString  = [aDecoder decodeObjectForKey:@"nextSyncUrlString"];

        self.limit              = [(NSNumber *)[aDecoder decodeObjectForKey:@"limit"] unsignedIntegerValue];
        self.skip               = [(NSNumber *)[aDecoder decodeObjectForKey:@"skip"] unsignedIntegerValue];
        self.total              = [(NSNumber *)[aDecoder decodeObjectForKey:@"total"] unsignedIntegerValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:self.errors forKey:@"errors"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.query forKey:@"query"];

    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.limit] forKey:@"limit"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.skip] forKey:@"skip"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.total] forKey:@"total"];

    [aCoder encodeObject:self.nextPageUrlString forKey:@"nextPageUrlString"];
    [aCoder encodeObject:self.nextSyncUrlString forKey:@"nextSyncUrlString"];
}

@end
