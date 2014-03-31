//
//  ContentfulBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//


#import <VCRURLConnection/VCR.h>

#import "ContentfulBaseTestCase.h"

#define SIG(class, selector) [class instanceMethodSignatureForSelector:selector]

extern void __gcov_flush();

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

- (void)setUp
{
    [super setUp];
    
    self.cassetteBaseName = NSStringFromClass([self class]);
    self.client = [CDAClient new];
    
    self.snapshotTestController = [[FBSnapshotTestController alloc] initWithTestClass:[self class]];
    self.snapshotTestController.referenceImagesDirectory = [[NSBundle bundleForClass:[self class]]
                                                            bundlePath];
}

@end
