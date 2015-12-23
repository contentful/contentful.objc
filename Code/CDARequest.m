//
//  CDARequest.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/03/14.
//
//

#import <AFNetworking/AFHTTPRequestOperation.h>

#import "CDARequest+Private.h"

@interface CDARequest ()

@property (nonatomic) AFHTTPRequestOperation* operation;

@end

#pragma mark -

@implementation CDARequest

@dynamic error;
@dynamic request;
@dynamic response;
@dynamic responseStringEncoding;

#pragma mark -

-(id)initWithRequestOperation:(AFHTTPRequestOperation *)requestOperation {
    self = [super init];
    if (self) {
        self.operation = requestOperation;
    }
    return self;
}

#pragma mark - Message forwarding to underlying AFHTTPRequestOperation

-(void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:self.operation];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = [super methodSignatureForSelector:selector];
	if (!signature) {
		signature = [self.operation methodSignatureForSelector:selector];
	}
	return signature;
}

@end
