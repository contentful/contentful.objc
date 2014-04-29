//
//  ContentfulBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

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
@property (nonatomic) FBSnapshotTestController* snapshotTestController;

@end

#pragma mark -

@implementation ContentfulBaseTestCase

+ (NSArray *)testInvocations;
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

- (void)assertField:(CDAField*)field
      hasIdentifier:(NSString*)identifier
               name:(NSString*)name
               type:(CDAFieldType)type
{
    XCTAssertEqualObjects(identifier, field.identifier, @"");
    XCTAssertEqualObjects(name, field.name, @"");
    XCTAssertEqual(type, field.type, @"");
}

- (void)beforeAll
{
    [VCR loadCassetteWithContentsOfURL:[[NSBundle bundleForClass:[self class]]
                                        URLForResource:self.cassetteBaseName withExtension:@"json"]];
    [VCR start];
}

- (void)compareImage:(UIImage*)image forTestSelector:(SEL)testSelector
{
    NSError* error;
    UIImage* referenceImage = [self.snapshotTestController referenceImageForSelector:testSelector
                                                                          identifier:nil
                                                                               error:&error];
    
    if (!referenceImage) {
        XCTAssert([self.snapshotTestController saveReferenceImage:image
                                                         selector:testSelector
                                                       identifier:nil error:&error],
                  @"Error ocurred: %@", error);
    }
    
    XCTAssert([self.snapshotTestController compareReferenceImage:referenceImage
                                                         toImage:image
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

- (void)setUp
{
    [super setUp];
    
    self.cassetteBaseName = NSStringFromClass([self class]);
    self.client = [CDAClient new];
    
    self.snapshotTestController = [[FBSnapshotTestController alloc] initWithTestClass:[self class]];
    self.snapshotTestController.referenceImagesDirectory = [[NSBundle bundleForClass:[self class]]
                                                            bundlePath];
}

- (void)stubHTTPRequestUsingFixtures:(NSDictionary*)fixtureMap inDirectory:(NSString*)directoryName
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* JSONName = fixtureMap[request.URL.absoluteString];
        
        if (JSONName) {
            return [OHHTTPStubsResponse responseWithFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:JSONName ofType:@"json" inDirectory:directoryName] statusCode:200 headers:@{ @"Content-Type": @"application/vnd.contentful.delivery.v1+json" }];
        }
        
        return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
    }];
}

-(void)tearDown {
    [OHHTTPStubs removeAllStubs];
}

@end
