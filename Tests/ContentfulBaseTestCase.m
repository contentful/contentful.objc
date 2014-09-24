//
//  ContentfulBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <CCLRequestReplay/CCLRequestReplayManager.h>
#import <CCLRequestReplay/CCLRequestReplayProtocol.h>
#import <VCRURLConnection/VCR.h>

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

#define SIG(class, selector) [class instanceMethodSignatureForSelector:selector]

extern void __gcov_flush();

@interface CDAClient ()

-(void)setSpace:(CDASpace*)space;

@end

#pragma mark -

@interface ContentfulBaseTestCase ()

@property (nonatomic) NSString* cassetteBaseName;
@property (nonatomic) CCLRequestReplayManager* requestReplayManager;
@property (nonatomic) FBSnapshotTestController* snapshotTestController;

@end

#pragma mark -

@implementation ContentfulBaseTestCase

+ (NSArray *)testInvocations
{
    if (self == [ContentfulBaseTestCase class]) {
        return nil;
    }
    
    NSMutableArray *testInvocations = [NSMutableArray arrayWithArray:[super testInvocations]];
    
    if ([self instancesRespondToSelector:@selector(beforeAll)]) {
        NSInvocation *beforeAll = [NSInvocation invocationWithMethodSignature:SIG(self, @selector(beforeAll))];
        beforeAll.selector = @selector(beforeAll);
        [testInvocations insertObject:beforeAll atIndex:0];
    }
    
    if ([self instancesRespondToSelector:@selector(afterAll)]) {
        NSInvocation *afterAll = [NSInvocation invocationWithMethodSignature:SIG(self, @selector(afterAll))];
        afterAll.selector = @selector(afterAll);
        [testInvocations addObject:afterAll];
    }
    
    return testInvocations;
}

#pragma mark -

- (void)afterAll
{
    [VCR save:[NSString stringWithFormat:@"/tmp/%@.json", self.cassetteBaseName]];
    [VCR stop];
    
    __gcov_flush();
}

- (void)addRecordingWithJSONNamed:(NSString*)JSONName
                      inDirectory:(NSString*)directory
                          matcher:(CCLURLRequestMatcher)matcher {
    CCLRequestJSONRecording* recording = [[CCLRequestJSONRecording alloc] initWithBundledJSONNamed:JSONName inDirectory:directory matcher:matcher statusCode:200 headerFields:@{ @"Content-Type": @"application/vnd.contentful.delivery.v1+json" }];
    [self.requestReplayManager addRecording:recording];
}

- (void)assertField:(CDAField*)field
      hasIdentifier:(NSString*)identifier
               name:(NSString*)name
               type:(CDAFieldType)type
{
    XCTAssertEqualObjects(identifier, field.identifier, @"");
    XCTAssertEqualObjects(name, field.name, @"");
    XCTAssertEqual(type, field.type, @"");
}

- (void)addResponseWithData:(NSData*)data
                 statusCode:(NSInteger)statusCode
                    headers:(NSDictionary*)headers
                    matcher:(CCLURLRequestMatcher)matcher {
    CCLRequestRecording* recording = [[CCLRequestRecording alloc] initWithRequest:nil response:[[NSHTTPURLResponse alloc] initWithURL:nil statusCode:statusCode HTTPVersion:@"1.1" headerFields:headers] data:data];
    recording.matcher = matcher;
    [self.requestReplayManager addRecording:recording];
}

- (void)addResponseWithError:(NSError*)error matcher:(CCLURLRequestMatcher)matcher {
    CCLRequestRecording* recording = [[CCLRequestRecording alloc] initWithRequest:nil error:error];
    recording.matcher = matcher;
    [self.requestReplayManager addRecording:recording];
}

- (void)beforeAll
{
    [VCR loadCassetteWithContentsOfURL:[[NSBundle bundleForClass:[self class]]
                                        URLForResource:self.cassetteBaseName withExtension:@"json"]];
    [VCR start];
}

- (void)compareView:(UIView*)view forTestSelector:(SEL)testSelector
{
    NSError* error;
    UIImage* referenceImage = [self.snapshotTestController referenceImageForSelector:testSelector
                                                                          identifier:nil
                                                                               error:&error];
    
    if (!referenceImage) {
        self.snapshotTestController.recordMode = YES;
        XCTFail(@"No reference image found.");
    }
    
    XCTAssert([self.snapshotTestController compareSnapshotOfView:view
                                                        selector:testSelector
                                                      identifier:nil
                                                           error:&error],
              @"Error ocurred: %@", error);
}

- (CDAEntry*)customEntryHelperWithFields:(NSDictionary*)fields
{
    NSData* spaceData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"space" ofType:@"json" inDirectory:@"SyncTests"]];
    NSDictionary* spaceJSON = [NSJSONSerialization JSONObjectWithData:spaceData options:0 error:nil];
    CDASpace* space = [[CDASpace alloc] initWithDictionary:spaceJSON client:self.client];
    [self.client setSpace:space];
    
    NSDictionary* ct = @{
                         @"name": @"My trolls",
                         @"fields": @[
                                 @{ @"id": @"someArray",    @"type": @"Array",
                                    @"items": @{ @"type": @"Link" } },
                                 @{ @"id": @"someBool",     @"type": @"Boolean" },
                                 @{ @"id": @"someDate",     @"type": @"Date" },
                                 @{ @"id": @"someInteger",  @"type": @"Integer" },
                                 @{ @"id": @"someLink",     @"type": @"Link" },
                                 @{ @"id": @"someLocation", @"type": @"Location" },
                                 @{ @"id": @"someNumber",   @"type": @"Number" },
                                 @{ @"id": @"someSymbol",   @"type": @"Symbol" },
                                 @{ @"id": @"someText",     @"type": @"Text" },
                                 ],
                         @"sys": @{ @"id": @"trolololo" },
                         };
    
    CDAContentType* contentType = [[CDAContentType alloc] initWithDictionary:ct client:self.client];
    XCTAssertEqual(9U, contentType.fields.count, @"");
    
    NSDictionary* entry = @{
                            @"fields": fields,
                            @"sys": @{
                                    @"id": @"brokenEntry",
                                    @"contentType": @{ @"sys": @{ @"id": @"trolololo" } }
                                    },
                            };
    CDAEntry* brokenEntry = [[CDAEntry alloc] initWithDictionary:entry client:self.client];
    XCTAssertEqualObjects(@"brokenEntry", brokenEntry.identifier, @"");
    return brokenEntry;
}

- (void)removeAllStubs {
    [self.requestReplayManager removeAllRecordings];
}

- (void)setUp
{
    [super setUp];
    
    self.cassetteBaseName = NSStringFromClass([self class]);
    self.client = [CDAClient new];
    
    self.requestReplayManager = [CCLRequestReplayManager new];
    [self.requestReplayManager replay];
    
    self.snapshotTestController = [[FBSnapshotTestController alloc] initWithTestClass:[self class]];
    self.snapshotTestController.referenceImagesDirectory = [[NSBundle bundleForClass:[self class]]
                                                            bundlePath];
}

- (void)stubHTTPRequestUsingFixtures:(NSDictionary*)fixtureMap inDirectory:(NSString*)directoryName
{
    [fixtureMap enumerateKeysAndObjectsUsingBlock:^(NSString* url, NSString* JSONName, BOOL *stop) {
        [self addRecordingWithJSONNamed:JSONName
                            inDirectory:directoryName
                                matcher:^BOOL(NSURLRequest *request) {
                                    return [request.URL.absoluteString isEqualToString:url];
                                }];
    }];
    
    CCLRequestJSONRecording* recording = [[CCLRequestJSONRecording alloc]
                                          initWithBundledJSONNamed:nil
                                          inDirectory:directoryName
                                          matcher:^BOOL(NSURLRequest *request) {
                                              return YES;
                                          }
                                          statusCode:404
                                          headerFields:nil];
    [self.requestReplayManager addRecording:recording];
}

-(void)tearDown {
    [self.requestReplayManager stopReplay];
    self.requestReplayManager = nil;
}

@end
