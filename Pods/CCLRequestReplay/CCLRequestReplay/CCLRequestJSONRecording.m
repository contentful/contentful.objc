//
//  CCLRequestJSONRecording.m
//  CCLRequestReplay
//
//  Created by Boris Bügling on 30/04/2014.
//

#import "CCLRequestJSONRecording.h"

@interface CCLRequestJSONRecording ()

@property (nonatomic) NSDictionary* headerFields;
@property (nonatomic, copy) CCLURLRequestMatcher matcher;
@property (nonatomic) NSData* responseData;
@property (nonatomic) NSInteger statusCode;

@end

#pragma mark -

@implementation CCLRequestJSONRecording

-(id)initWithBundledJSONNamed:(NSString*)JSONName
                  inDirectory:(NSString*)directoryName
                      matcher:(CCLURLRequestMatcher)matcher
                   statusCode:(NSInteger)statusCode
                 headerFields:(NSDictionary*)headerFields {
    self = [super init];
    if (self) {
        self.headerFields = headerFields;
        self.matcher = matcher;
        self.responseData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:JSONName ofType:@"json" inDirectory:directoryName]];
        self.statusCode = statusCode;
    }
    return self;
}

#pragma mark - CCLRequestRecordingProtocol

-(NSData *)dataForRequest:(NSURLRequest *)request {
    return self.responseData;
}

-(NSError *)errorForRequest:(NSURLRequest *)request {
    return nil;
}

-(BOOL)matchesRequest:(NSURLRequest *)request {
    return self.matcher(request);
}

-(NSURLResponse *)responseForRequest:(NSURLRequest *)request {
    return [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                       statusCode:self.statusCode
                                      HTTPVersion:@"1.1"
                                     headerFields:self.headerFields];
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    return nil;
}

#pragma mark - NSSecureCoding

+(BOOL)supportsSecureCoding {
    return NO;
}

@end
