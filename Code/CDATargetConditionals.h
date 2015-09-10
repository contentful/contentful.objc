//
//  CDATargetConditionals.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/09/15.
//
//

@import Darwin.TargetConditionals;

#ifndef TARGET_OS_IOS
    #define TARGET_OS_IOS TARGET_OS_IPHONE
#endif

#ifndef TARGET_OS_TV
    #define TARGET_OS_TV 0
#endif

#ifndef TARGET_OS_WATCH
    #define TARGET_OS_WATCH 0
#endif
