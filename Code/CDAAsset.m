//
//  CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAAsset+Private.h"
#import "CDAClient+Private.h"
#import "CDAInputSanitizer.h"
#import "CDAResource+Private.h"
#import "CDASpace+Private.h"
#import "CDAUtilities.h"

const CGFloat CDAImageQualityOriginal   = 0.0;
const CGFloat CDARadiusMaximum          = -100.0;
const CGFloat CDARadiusNone             = 0.0;

#if CGFLOAT_IS_DOUBLE
#define CGFLOAT_EPSILON DBL_EPSILON
#define cgfloat_abs     fabs
#else
#define CGFLOAT_EPSILON FLT_EPSILON
#define cgfloat_abs     fabsf
#endif

@interface CDAAsset ()

@property (nonatomic) NSDictionary* localizedFields;
@property (nonatomic) NSString* protocol;

@end

#pragma mark -

@implementation CDAAsset

@synthesize locale = _locale;

#pragma mark -

+(instancetype)assetFromPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client {
    NSParameterAssert(persistedAsset);
    NSParameterAssert(persistedAsset.identifier);
    NSParameterAssert(persistedAsset.internetMediaType);
    NSParameterAssert(persistedAsset.url);
    
    NSDictionary* fileContent = @{ @"contentType": persistedAsset.internetMediaType,
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

+(void)cachePersistedAsset:(id<CDAPersistedAsset>)persistedAsset
                    client:(CDAClient*)client
          forcingOverwrite:(BOOL)forceOverwrite
         completionHandler:(void (^)(BOOL success))handler {
    CDAAsset* asset = [self assetFromPersistedAsset:persistedAsset client:client];
    [asset cacheAssetForcingOverwrite:forceOverwrite completionHandler:handler];
}

+(NSString *)CDAType {
    return @"Asset";
}

+(NSArray*)subclasses {
    static dispatch_once_t once;
    static NSArray* subclasses;
    dispatch_once(&once, ^ { subclasses = CDAClassGetSubclasses([self class]); });
    return subclasses;
}

#pragma mark -

-(void)cacheAssetForcingOverwrite:(BOOL)forceOverwrite
                completionHandler:(void (^)(BOOL success))handler {
    NSString* fileName = CDACacheFileNameForResource(self);

    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName] && !forceOverwrite) {
        if (handler) {
            handler(NO);
        }
        return;
    }

    if (!self.URL) {
        return;
    }

    NSURL* url = self.URL;
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!data) {
                                   if (handler) {
                                       handler(NO);
                                   }

                                   return;
                               }

                               [data writeToFile:fileName atomically:YES];

                               if (handler) {
                                   handler(YES);
                               }
                           }];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"CDAAsset of type %@ at URL %@", self.MIMEType, self.URL];
}

-(NSDictionary *)fields {
    NSDictionary* localizedFields = self.localizedFields[self.locale];
    return localizedFields ?: @{};
}

-(NSURL *)imageURLWithSize:(CGSize)size {
    return [self imageURLWithSize:size quality:CDAImageQualityOriginal format:CDAImageFormatOriginal];
}

-(NSURL *)imageURLWithSize:(CGSize)size quality:(CGFloat)quality format:(CDAImageFormat)format {
    return [self imageURLWithSize:size
                          quality:quality
                           format:format
                              fit:CDAFitDefault
                            focus:nil
                           radius:CDARadiusNone
                       background:nil
                      progressive:false];
}

-(NSURL *)imageURLWithSize:(CGSize)size
                   quality:(CGFloat)quality
                    format:(CDAImageFormat)format
                       fit:(CDAFitType)fit
                     focus:(NSString *)focus
                    radius:(CGFloat)radius
                background:(NSString *)backgroundColor
               progressive:(BOOL)progressive {
    if (!self.isImage) {
        return self.URL;
    }
    
    NSMutableDictionary* parameters = [@{} mutableCopy];
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        parameters[@"w"] = @(size.width);
        parameters[@"h"] = @(size.height);
    }
    
    if (cgfloat_abs((quality) - (CDAImageQualityOriginal)) > CGFLOAT_EPSILON) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdouble-promotion"
        NSAssert(quality <= 1.0, @"Quality parameter should be between 0.0 and 1.0, but is %.2f", quality);
#pragma clang diagnostic pop
        parameters[@"q"] = @(quality * 100);
    }
    
    switch (format) {
        case CDAImageFormatJPEG:
            parameters[@"fm"] = @"jpg";
            break;
        case CDAImageFormatPNG:
            parameters[@"fm"] = @"png";
            break;
        case CDAImageFormatOriginal:
            break;
    }

    switch (fit) {
        case CDAFitPad:
            parameters[@"fit"] = @"pad";
            break;
        case CDAFitCrop:
            parameters[@"fit"] = @"crop";
            break;
        case CDAFitFill:
            parameters[@"fit"] = @"fill";
            break;
        case CDAFitScale:
            parameters[@"fit"] = @"scale";
            break;
        case CDAFitThumb:
            parameters[@"fit"] = @"thumb";
            break;
        case CDAFitDefault:
            break;
    }

    if (focus) {
        parameters[@"f"] = focus;
    }

    if (cgfloat_abs(radius - CDARadiusNone) > CGFLOAT_EPSILON) {
        if (cgfloat_abs(radius - CDARadiusMaximum) < CGFLOAT_EPSILON) {
            parameters[@"r"] = @"max";
        } else {
            if (radius > 0) {
                parameters[@"r"] = @(radius);
            }
        }
    }

    if (backgroundColor) {
        parameters[@"bg"] = backgroundColor;
    }

    if (progressive) {
        parameters[@"fl"] = @"progressive";
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
        NSDictionary* fields = [CDAInputSanitizer sanitizeObject:dictionary[@"fields"]];
        NSMutableDictionary* localizedFields = [@{} mutableCopy];
        
        if (fields) {
            // Ensure there is a zero size in any case
            if (!fields[@"file"][@"details"][@"size"]) {
                NSDictionary* file = fields[@"file"] ?: @{};
                NSDictionary* details = file[@"details"] ?: @{};

                NSMutableDictionary* mutableFields = [fields mutableCopy];
                NSMutableDictionary* mutableFile = [[NSMutableDictionary alloc]
                                                    initWithDictionary:file];
                NSMutableDictionary* mutableDetails = [[NSMutableDictionary alloc]
                                                       initWithDictionary:details];
                
                mutableDetails[@"size"] = @0;
                mutableFile[@"details"] = [mutableDetails copy];
                mutableFields[@"file"] = [mutableFile copy];
                fields = [mutableFields copy];
            }
            
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

-(void)setClient:(CDAClient *)client {
    [super setClient:client];

    if (self.client.protocol) {
        self.protocol = self.client.protocol;
    }
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

-(void)setValue:(id)value forFieldWithName:(NSString *)key {
    NSMutableDictionary* allFields = [self.localizedFields mutableCopy];
    NSMutableDictionary* currentFields = [self.localizedFields[self.locale] mutableCopy];

    currentFields[key] = value;
    allFields[self.locale] = currentFields;

    self.localizedFields = allFields;
}

-(CGSize)size {
    NSDictionary* size = self.fields[@"file"][@"details"][@"image"];
#if CGFLOAT_IS_DOUBLE
    return size ? CGSizeMake([size[@"width"] doubleValue], [size[@"height"] doubleValue]) : CGSizeZero;
#else
    return size ? CGSizeMake([size[@"width"] floatValue], [size[@"height"] floatValue]) : CGSizeZero;
#endif
}

-(NSURL *)URL {
    NSString* url = self.fields[@"file"][@"url"];
    if (!url) {
        return nil;
    }
    
    if ([url rangeOfString:@"://"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"%@:%@", self.protocol, url];
    }
    
    return [NSURL URLWithString:url];
}

@end
