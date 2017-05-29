
//
//  CDARequestSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/07/14.
//
//

#import "CDARequestSerializer.h"
#import "CDAUtilities.h"
#import "Versions.h"

@implementation CDARequestSerializer

-(instancetype)initWithAccessToken:(NSString*)accessToken
                      isCMARequest:(BOOL)isCMARequest {
    NSParameterAssert(accessToken);

    self = [super init];
    if (self) {
        [self setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];

        NSString *userAgentHeaderString = [self userAgentHeaderStringIsForCMA:isCMARequest];
        [self setValue:userAgentHeaderString forHTTPHeaderField:@"X-Contentful-User-Agent"];
    }
    return self;
}

- (NSString *)userAgentHeaderStringIsForCMA:(BOOL)isCMARequest {
    NSMutableString *userAgentString = [[NSMutableString alloc] initWithString:@""];

    NSString *appVersionString = [self appVersionString];
    if (appVersionString != nil) {
        [userAgentString appendString:[NSString stringWithFormat:@"app %@; ", appVersionString]];
    }

    [userAgentString appendString:[NSString stringWithFormat:@"sdk %@;", [self sdkVersionString:isCMARequest]]];

    NSString *operatingSystemVersionString = [self operatingSystemVersionString];
    if (operatingSystemVersionString != nil) {
        [userAgentString appendString:[NSString stringWithFormat:@" os %@;", operatingSystemVersionString]];
    }
    return userAgentString;
}

- (NSString *)appVersionString {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionNumberString = bundleInfo[@"CFBundleShortVersionString"];
    NSString *appBundleId = [[NSBundle mainBundle] bundleIdentifier];
    if (versionNumberString == nil || appBundleId == nil) {
        return nil;
    }

    return [NSString stringWithFormat:@"%@/%@", appBundleId, versionNumberString];
}

- (NSString *)sdkVersionString:(BOOL)isCMARequest {

    NSString *sdkVersion = DELIVERY_SDK_VERSION;
    NSString *sdkVersionString = [NSString stringWithFormat:@"contentful.objc/%@", sdkVersion];

    if (isCMARequest) {
        sdkVersion = MANAGEMENT_SDK_VERSION;
        sdkVersionString = [NSString stringWithFormat:@"contentful-management.objc/%@", sdkVersion];
    }

    return sdkVersionString;
}

- (NSString *)operatingSystemVersionString {
    NSString *operatingSystemPlatform = [self operatingSystemPlatform];
    if (operatingSystemPlatform == nil) {
        return nil;
    }

    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString *osVersionString = [NSString stringWithFormat:@"%li.%li.%li", (long)osVersion.majorVersion, (long)osVersion.minorVersion, (long)osVersion.patchVersion];

    return [NSString stringWithFormat:@"%@/%@", operatingSystemPlatform, osVersionString];
}


- (NSString *)operatingSystemPlatform {
    NSString *osName;

#if TARGET_OS_IOS
    osName = @"iOS";
#elif TARGET_OS_OSX
    osName = @"macOS";
#elif TARGET_OS_TV
    osName = @"tvOS";
#elif TARGET_OS_WATCH
    osName = @"watchOS";
#endif
    return osName;
}

@end
