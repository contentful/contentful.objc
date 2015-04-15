//
//  CDANullabilityStubs.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/15.
//
//

// Thanks to https://gist.github.com/steipete/d9f519858fe5fb5533eb
#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define nonnull
#define null_unspecified
#define null_resettable
#define __nullable
#define __nonnull
#define __null_unspecified
#endif
