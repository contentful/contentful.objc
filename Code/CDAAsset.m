//
//  CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAAsset+Private.h"
#import "CDAClient+Private.h"
#import "CDAResource+Private.h"
#import "CDASpace+Private.h"
#import "CDAUtilities.h"

const CGFloat CDAImageQualityOriginal = 0.0;

@interface CDAAsset ()

@property (nonatomic) NSDictionary* localizedFields;

@end

#pragma mark -

@implementation CDAAsset

@synthesize locale = _locale;

#pragma mark -

+(instancetype)assetFromPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client {
    NSParameterAssert(persistedAsset);
    NSParameterAssert(persistedAsset.identifier);
    NSParameterAssert(persistedAsset.mimeType);
    NSParameterAssert(persistedAsset.url);
    
    NSDictionary* fileContent = @{ @"contentType": persistedAsset.mimeType,
                                   @"url": persistedAsset.url };
    
    if (client.localizationAvailable) {
        fileContent = @{ client.space.defaultLocale ?: @"en-US": fileContent };
    }
    
    return [[self alloc] initWithDictionary:@{ @"sys": @{ @"id": persistedAsset.identifier,
                                                          @"type": @"Asset" },
                                               @"fields": @{ @"file": fileContent } }
                                     client:client];
}

+(NSData*)cachedDataForAsset:(CDAAsset*)asset {
    NSString* fileName = CDACacheFileNameForResource(asset);
    return [NSData dataWithContentsOfFile:fileName];
}

+(NSData*)cachedDataForPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client {
    if (!persistedAsset) {
        return nil;
    }
    return [self cachedDataForAsset:[self assetFromPersistedAsset:persistedAsset client:client]];
}

+(NSString *)CDAType {
    return @"Asset";
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"CDAAsset of type %@ at URL %@", self.MIMEType, self.URL];
}

-(NSDictionary *)fields {
    return self.localizedFields[self.locale];
}

-(NSURL *)imageURLWithSize:(CGSize)size {
    return [self imageURLWithSize:size quality:CDAImageQualityOriginal format:CDAImageFormatOriginal];
}

-(NSURL *)imageURLWithSize:(CGSize)size quality:(CGFloat)quality format:(CDAImageFormat)format {
    if (!self.isImage) {
        return self.URL;
    }
    
    NSMutableDictionary* parameters = [@{} mutableCopy];
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        parameters[@"w"] = @(size.width);
        parameters[@"h"] = @(size.height);
    }
    
    if (quality != CDAImageQualityOriginal) {
        parameters[@"q"] = @(quality * 100);
    }
    
    switch (format) {
        case CDAImageFormatJPEG:
            parameters[@"fm"] = @"jpg";
            break;
        case CDAImageFormatPNG:
            parameters[@"fm"] = @"png";
            break;
        default:
            break;
    }
    
    if (parameters.count == 0) {
        return self.URL;
    }
    
    NSMutableString* imageUrlString = [self.URL.absoluteString mutableCopy];
    
    [imageUrlString appendString:@"?"];
    
    NSMutableArray* queryParameters = [@[] mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        [queryParameters addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
    
    [imageUrlString appendString:[queryParameters componentsJoinedByString:@"&"]];
    
    return [NSURL URLWithString:imageUrlString];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        NSDictionary* fields = dictionary[@"fields"];
        NSMutableDictionary* localizedFields = [@{} mutableCopy];
        
        if (fields) {
            if (self.localizationAvailable) {
                for (NSString* locale in self.client.space.localeCodes) {
                    localizedFields[locale] = [self localizedDictionaryFromDictionary:fields
                                                                            forLocale:locale];
                }
            } else {
                localizedFields[self.defaultLocaleOfSpace] = fields;
            }
        }
        
        self.localizedFields = [localizedFields copy];
    }
    return self;
}

-(BOOL)isImage {
    return [self.MIMEType hasPrefix:@"image/"];
}

-(NSString *)locale {
    return _locale ?: self.defaultLocaleOfSpace;
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

-(void)setLocale:(NSString *)locale {
    if (_locale == locale) {
        return;
    }
    
    if ([self.localizedFields.allKeys containsObject:locale]) {
        _locale = locale;
    } else {
        _locale = self.defaultLocaleOfSpace;
    }
}

-(CGSize)size {
    NSDictionary* size = self.fields[@"file"][@"details"][@"image"];
    return size ? CGSizeMake([size[@"width"] floatValue], [size[@"height"] floatValue]) : CGSizeZero;
}

-(NSURL *)URL {
    NSString* url = self.fields[@"file"][@"url"];
    if (!url) {
        return nil;
    }
    
    if ([url rangeOfString:@"://"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"%@:%@", self.client.protocol, url];
    }
    
    return [NSURL URLWithString:url];
}

@end
