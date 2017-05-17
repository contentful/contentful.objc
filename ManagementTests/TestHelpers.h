//
//  TestHelpers.h
//  ContentfulSDK
//
//  Created by JP Wright on 20.04.17.
//
//

#import <Foundation/Foundation.h>
#import <VCRURLConnection/VCR.h>


#define VCRTest_it(__testName) \
it(__testName, ^{ \
NSString *testName = __testName; \
[TestHelpers startRecordingOrLoadCassetteForTestNamed:testName \
                                             forClass:self.class];

#define VCRTestEnd [TestHelpers endRecordingAndSaveWithName:testName \
                                                   forClass:self.class]; \
});


@interface TestHelpers : NSObject


+ (void)startRecordingOrLoadCassetteForTestNamed:(NSString *)testName
                                        forClass:(Class)testClass;

+ (void)endRecordingAndSaveWithName:(NSString *)name
                           forClass:(Class)testClass;

@end
