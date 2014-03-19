//
//  CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAAsset.h"
#import "CDAClient+Private.h"
#import "CDAResource+Private.h"

@interface CDAAsset ()

@property (nonatomic) NSDictionary* fields;

@end

#pragma mark -

@implementation CDAAsset

+(NSString *)CDAType {
    return @"Asset";
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"CDAAsset of type %@ at URL %@", self.MIMEType, self.URL];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        NSMutableDictionary* fields = [dictionary[@"fields"] mutableCopy];
        
        NSMutableDictionary* fileProperties = [fields[@"file"] mutableCopy];
        NSString* assetURLString = fileProperties[@"url"];
        if (assetURLString) {
            fileProperties[@"url"] = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",
                                                           self.client.protocol, assetURLString]];
            fields[@"file"] = fileProperties;
        }
        
        self.fields = fields;
    }
    return self;
}

-(NSString *)MIMEType {
    return self.fields[@"file"][@"contentType"];
}

-(void)resolveWithSuccess:(void (^)(CDAResponse *, CDAResource *))success
                  failure:(void (^)(CDAResponse *, NSError *))failure {
    if (self.fetched) {
        [super resolveWithSuccess:success failure:failure];
        return;
    }
    
    [self.client fetchAssetWithIdentifier:self.identifier
                                  success:^(CDAResponse *response, CDAAsset *asset) {
                                      if (success) {
                                          success(response, asset);
                                      }
                                  } failure:failure];
}

-(CGSize)size {
    NSDictionary* size = self.fields[@"file"][@"details"][@"image"];
    return size ? CGSizeMake([size[@"width"] floatValue], [size[@"height"] floatValue]) : CGSizeZero;
}

-(NSURL *)URL {
    return self.fields[@"file"][@"url"];
}

@end
