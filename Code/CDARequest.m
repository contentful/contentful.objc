//
//  CDARequest.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/03/14.
//
//

#import "CDARequest+Private.h"

@interface CDARequest ()

@property (nonatomic) NSURLSessionTask* task;

@end

#pragma mark -

@implementation CDARequest

@dynamic error;
@dynamic request;
@dynamic response;
@dynamic responseStringEncoding;

#pragma mark -

-(id)initWithSessionTask:(NSURLSessionTask *)task {
    self = [super init];
    if (self) {
        self.task = task;
    }
    return self;
}

#pragma mark - Compatibility with 1.x API

-(NSURLRequest *)request {
    return self.task.originalRequest;
}

-(NSStringEncoding)responseStringEncoding {
    NSString* encoding = self.task.response.textEncodingName;
    if (!encoding) {
        return NSUTF8StringEncoding;
    }
    return CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encoding));
}

#pragma mark - Message forwarding to underlying AFHTTPRequestOperation

-(void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:self.task];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = [super methodSignatureForSelector:selector];
	if (!signature) {
		signature = [self.task methodSignatureForSelector:selector];
	}
	return signature;
}

@end
