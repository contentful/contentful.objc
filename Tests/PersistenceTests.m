//
//  PersistenceTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 07/04/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface PersistenceTests : ContentfulBaseTestCase

@property (nonatomic) NSURL* temporaryFileURL;

@end

#pragma mark -

@implementation PersistenceTests

-(void)setUp {
    [super setUp];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",
                          [[NSProcessInfo processInfo] globallyUniqueString], @"file.data"];
    self.temporaryFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                    stringByAppendingPathComponent:fileName]];
}

-(void)testPersistArraysOfEntries {
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        [array writeToFile:self.temporaryFileURL.path];
        CDAArray* readArray = [CDAArray readFromFile:self.temporaryFileURL.path client:self.client];
        
        XCTAssertEqualObjects(array.sys[@"type"], readArray.sys[@"type"], @"");
        XCTAssertEqual(array.items.count, readArray.items.count, @"");
        
        for (int i = 0; i < array.items.count; i++) {
            XCTAssertEqualObjects(array.items[i], readArray.items[i], @"");
            
            NSDictionary* originalEntryFields = [array.items[i] fields];
            NSDictionary* readEntryFields = [readArray.items[i] fields];
            XCTAssertEqualObjects(originalEntryFields, readEntryFields, @"");
            
            if ([originalEntryFields.allKeys isEqual:readEntryFields.allKeys]) {
                for (NSString* key in originalEntryFields.allKeys) {
                    XCTAssertEqualObjects(originalEntryFields[key], readEntryFields[key],
                                          @"Fields differ for key '%@'", key);
                }
            }
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testPersistAsset {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        [asset writeToFile:self.temporaryFileURL.path];
        CDAAsset* readAsset = [CDAAsset readFromFile:self.temporaryFileURL.path client:self.client];
        
        XCTAssertEqualObjects(asset, readAsset, @"");
        XCTAssertEqualObjects(@"Asset", readAsset.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", readAsset.sys[@"id"], @"");
        XCTAssertEqualObjects(@"Nyan Cat", readAsset.fields[@"title"], @"");
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", readAsset.fields[@"file"][@"fileName"], @"");
        XCTAssertEqualObjects(@"image/png", readAsset.fields[@"file"][@"contentType"], @"");
        XCTAssertEqualObjects(@"image/png", readAsset.MIMEType, @"");
        XCTAssertEqualObjects(@250, readAsset.fields[@"file"][@"details"][@"image"][@"width"], @"");
        XCTAssertEqualObjects(@250, readAsset.fields[@"file"][@"details"][@"image"][@"height"], @"");
        XCTAssertEqualObjects(@12273, readAsset.fields[@"file"][@"details"][@"size"], @"");
        XCTAssertEqualObjects([NSURL URLWithString:@"https://images.contentful.com/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png"],
                              readAsset.URL, @"");
        XCTAssertEqual(250.0f, readAsset.size.width, @"");
        XCTAssertEqual(250.0f, readAsset.size.height, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testPersistContentType {
    StartBlock();
    
    [self.client fetchContentTypeWithIdentifier:@"cat" success:^(CDAResponse* r, CDAContentType* type) {
        [type writeToFile:self.temporaryFileURL.path];
        CDAContentType* ct = [CDAContentType readFromFile:self.temporaryFileURL.path
                                                   client:self.client];
        
        XCTAssertEqualObjects(@"ContentType", ct.sys[@"type"], @"");
        XCTAssertEqualObjects(@"cat", ct.identifier, @"");
        XCTAssertEqualObjects(@"cat", ct.sys[@"id"], @"");
        XCTAssertEqualObjects(@"name", ct.displayField, @"");
        XCTAssertEqualObjects(@"Cat", ct.name, @"");
        XCTAssertEqualObjects(@"Meow.", ct.userDescription, @"");
        
        XCTAssertEqual(8U, ct.fields.count, @"");
        [self assertField:ct.fields[0]
            hasIdentifier:@"name"
                     name:@"Name"
                     type:CDAFieldTypeText];
        [self assertField:ct.fields[1]
            hasIdentifier:@"likes"
                     name:@"Likes"
                     type:CDAFieldTypeArray];
        XCTAssertEqual(CDAFieldTypeSymbol, [ct.fields[1] itemType], @"");
        [self assertField:ct.fields[2]
            hasIdentifier:@"color"
                     name:@"Color"
                     type:CDAFieldTypeSymbol];
        [self assertField:ct.fields[3]
            hasIdentifier:@"bestFriend"
                     name:@"Best Friend"
                     type:CDAFieldTypeLink];
        [self assertField:ct.fields[4]
            hasIdentifier:@"birthday"
                     name:@"Birthday"
                     type:CDAFieldTypeDate];
        [self assertField:ct.fields[5]
            hasIdentifier:@"lifes"
                     name:@"Lifes left"
                     type:CDAFieldTypeInteger];
        XCTAssert([ct.fields[5] disabled], @"");
        [self assertField:ct.fields[6]
            hasIdentifier:@"lives"
                     name:@"Lives left"
                     type:CDAFieldTypeInteger];
        XCTAssertFalse([ct.fields[6] disabled], @"");
        [self assertField:ct.fields[7]
            hasIdentifier:@"image"
                     name:@"Image"
                     type:CDAFieldTypeLink];
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();

}

-(void)testPersistEntry {
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        [entry writeToFile:self.temporaryFileURL.path];
        CDAEntry* readEntry = [CDAEntry readFromFile:self.temporaryFileURL.path
                                              client:self.client];
        
        XCTAssertEqualObjects(entry, readEntry, @"");
        XCTAssertEqualObjects(@"Entry", readEntry.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", readEntry.identifier, @"");
        XCTAssertEqualObjects(@"nyancat", readEntry.sys[@"id"], @"");
        XCTAssertEqualObjects(@"Nyan Cat", readEntry.fields[@"name"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
