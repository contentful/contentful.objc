//
//  CMAEntry.m
//  Pods
//
//  Created by Boris Bügling on 25/07/14.
//
//

#import "CDAEntry+Private.h"
#import "CDAResource+Management.h"
#import "CMAEntry.h"
#import "CMAUtilities.h"

@interface CMAEntry ()

@property (nonatomic, readonly) NSString* URLPath;

@end

#pragma mark -

@implementation CMAEntry

-(CDARequest *)archiveWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@"archived" withSuccess:success failure:failure];
}

-(CDARequest*)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(BOOL)isArchived {
    return self.sys[@"archivedVersion"] != nil;
}

-(BOOL)isPublished {
    return self.sys[@"publishedVersion"] != nil;
}

-(NSDictionary*)parametersFromLocalizedFields {
    return CMATransformLocalizedFieldsToParameterDictionary(self.localizedFields);
}

-(CDARequest *)publishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@"published" withSuccess:success failure:failure];
}

-(void)setValue:(id)value forFieldWithName:(NSString *)key {
    [super setValue:value forFieldWithName:key];
}

-(CDARequest *)unarchiveWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"archived" withSuccess:success failure:failure];
}

-(CDARequest *)unpublishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"published" withSuccess:success failure:failure];
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"fields" : [self parametersFromLocalizedFields] }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return [@"entries" stringByAppendingPathComponent:self.identifier];
}

@end
