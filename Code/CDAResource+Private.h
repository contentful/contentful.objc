//
//  CDAResource+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

@class CDAClient;

@interface CDAResource ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic) NSString* defaultLocaleOfSpace;
@property (nonatomic, readonly) BOOL localizationAvailable;

+(NSString*)CDAType;
+(BOOL)classIsOfType:(Class)class;
+(instancetype)resourceObjectForDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;

-(BOOL)createdAfterDate:(NSDate*)date;
-(id)initWithDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;
-(NSDictionary*)localizedDictionaryFromDictionary:(NSDictionary*)dictionary forLocale:(NSString*)locale;
-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries;
-(BOOL)updatedAfterDate:(NSDate*)date;
-(void)updateWithContentsOfDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;
-(void)updateWithResource:(CDAResource*)resource;

@end
