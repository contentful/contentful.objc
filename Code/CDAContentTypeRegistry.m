//
//  CDAContentTypeRegistry.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAContentType.h"
#import "CDAContentTypeRegistry.h"

@interface CDAContentTypeRegistry ()

@property (nonatomic) NSMutableDictionary* contentTypes;
@property (nonatomic) NSMutableDictionary* customClasses;

@end

#pragma mark -

@implementation CDAContentTypeRegistry

-(void)addContentType:(CDAContentType*)contentType {
    NSAssert(contentType.identifier, @"Content Type needs an identifier");
    self.contentTypes[contentType.identifier] = contentType;
}

-(CDAContentType*)contentTypeForIdentifier:(NSString*)identifier {
    return self.contentTypes[identifier];
}

-(Class)customClassForContentType:(CDAContentType *)contentType {
    return self.customClasses[contentType.identifier];
}

-(BOOL)fetched {
    return self.contentTypes.count > 0;
}

-(id)init {
    self = [super init];
    if (self) {
        self.contentTypes = [@{} mutableCopy];
        self.customClasses = [@{} mutableCopy];
    }
    return self;
}

-(void)registerClass:(Class)customClass forContentType:(CDAContentType*)contentType {
    self.customClasses[contentType.identifier] = customClass;
}

-(void)registerClass:(Class)customClass forContentTypeWithIdentifier:(NSString*)identifier {
    self.customClasses[identifier] = customClass;
}

@end
