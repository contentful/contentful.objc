//
//  CMASpace.h
//  ManagementSDK
//
//  Created by Boris Bügling on 15/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CMASpace.h"

@interface CMASpace (Private)

+(NSDictionary*)fileUploadDictionaryFromLocalizedUploads:(NSDictionary*)localizedUploads;

-(CDARequest *)createAssetWithIdentifier:(NSString*)identifier
                                  fields:(NSDictionary *)fields
                                 success:(CMAAssetFetchedBlock)success
                                 failure:(CDARequestFailureBlock)failure;

-(CDARequest *)createEntryOfContentType:(CMAContentType*)contentType
                         withIdentifier:(NSString*)identifier
                                 fields:(NSDictionary*)fields
                                success:(CMAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure;

@end
