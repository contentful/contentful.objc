//
//  CDAResource+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAResource.h"

@class CDAClient;

@interface CDAResource ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic) NSString* defaultLocaleOfSpace; // FIXME: should this be `readonly`?

+(NSString*)CDAType;
+(BOOL)classIsOfType:(Class)class;
+(instancetype)resourceObjectForDictionary:(NSDictionary*)dictionary
                                    client:(CDAClient*)client
                     localizationAvailable:(BOOL)localizationAvailable;

-(BOOL)createdAfterDate:(NSDate*)date;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary
                 client:(CDAClient*)client
  localizationAvailable:(BOOL)localizationAvailable;
-(NSDictionary*)localizeFieldsFromDictionary:(NSDictionary*)fields;
-(NSDictionary*)localizedDictionaryFromDictionary:(NSDictionary*)dictionary
                                        forLocale:(NSString*)locale
                                          default:(BOOL)isDefault;
-(NSDictionary*)parseDictionary:(NSDictionary*)dictionary;
-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries;
-(BOOL)updatedAfterDate:(NSDate*)date;
-(void)updateWithContentsOfDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;
-(void)updateWithResource:(CDAResource*)resource;

@end
