//
//  TestHelpers.m
//  ContentfulSDK
//
//  Created by JP Wright on 20.04.17.
//
//

#import "TestHelpers.h"



@implementation TestHelpers

+ (void)startRecordingOrLoadCassetteForTestNamed:(NSString *)testName
                                        forClass:(Class)testClass {

    NSString *cassetteName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(testClass), testName];
    [VCR loadCassetteWithContentsOfURL:[[NSBundle bundleForClass:self]
                                        URLForResource:cassetteName
                                        withExtension:@"json"]];
    [VCR setRecording:YES];
//    [VCR setReplaying:YES];
//    [VCR start];
}

+ (void)endRecordingAndSaveWithName:(NSString *)name
                           forClass:(Class)testClass {
    
    NSString *fullCassettePath = [NSString stringWithFormat:@"/tmp/ObjC-CMA/%@_%@.json", NSStringFromClass(testClass), name];
    [VCR save:fullCassettePath];
    [VCR stop];
}

@end
