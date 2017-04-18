//
//  CMAEditorInterface.m
//  Pods
//
//  Created by Boris Bügling on 11/07/16.
//

#import "CDAResource+Management.h"
#import "CDAResource+Private.h"
#import "CMAEditorInterface.h"

@implementation CMAEditorInterface

+(NSString *)CDAType {
    return @"EditorInterface";
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", self.class.CDAType, self.controls];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
                           client:(CDAClient *)client
            localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        if ([dictionary[@"controls"] isKindOfClass:[NSArray class]] && dictionary[@"controls"] != nil) {
            self.controls = (NSArray* _Nonnull )dictionary[@"controls"];
        }
    }
    return self;
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"controls": self.controls }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    NSString* contentTypeId = [self.sys[@"contentType"] identifier];
    NSAssert(contentTypeId, @"Editor interface is missing content type ID.");
    NSString* URLPath = [@"content_types" stringByAppendingPathComponent:contentTypeId];
    return [URLPath stringByAppendingPathComponent:@"editor_interface"];
}

@end
