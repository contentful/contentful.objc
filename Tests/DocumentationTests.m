//
//  DocumentationTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface DocumentationTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation DocumentationTests

- (void)testHelloContent {
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        XCTAssertEqualObjects(@"Entry", entry.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", entry.identifier, @"");
        XCTAssertEqualObjects(@"nyancat", entry.sys[@"id"], @"");
        XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testSpaces {
    StartBlock();
    
    [self.client fetchSpaceWithSuccess:^(CDAResponse* response, CDASpace* space) {
        XCTAssertEqualObjects(@"Space", space.sys[@"type"], @"");
        XCTAssertEqualObjects(@"cfexampleapi", space.identifier, @"");
        XCTAssertEqualObjects(@"Contentful Example API", space.name, @"");
        XCTAssertEqual(2U, space.locales.count, @"");
        XCTAssertEqualObjects(@"en-US", space.locales[0][@"code"], @"");
        XCTAssertEqualObjects(@"English", space.locales[0][@"name"], @"");
        XCTAssertEqualObjects(@"tlh", space.locales[1][@"code"], @"");
        XCTAssertEqualObjects(@"Klingon", space.locales[1][@"name"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testContentTypes {
    StartBlock();
    
    [self.client fetchContentTypeWithIdentifier:@"cat" success:^(CDAResponse* r, CDAContentType* ct) {
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

-(void)testAllContentTypes {
    StartBlock();
    
    [self.client fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqualObjects(@"Array", array.sys[@"type"], @"");
        XCTAssertEqual(4U, array.total, @"");
        XCTAssertEqual(0U, array.skip, @"");
        XCTAssertEqual(100U, array.limit, @"");
        XCTAssertEqual(4U, array.items.count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testSingleEntry {
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        XCTAssertEqualObjects(@"CDAEntry", NSStringFromClass(entry.class), @"");
        XCTAssertEqualObjects(@"Entry", entry.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", entry.identifier, @"");
        XCTAssertEqualObjects(@(5), entry.sys[@"revision"], @"");
        XCTAssertEqualObjects(@"cfexampleapi", [entry.sys[@"space"] identifier], @"");
        XCTAssertEqualObjects(@"cat", [entry.sys[@"contentType"] identifier], @"");
        XCTAssert([entry.sys[@"createdAt"] isKindOfClass:[NSDate class]], @"");
        XCTAssert([entry.sys[@"updatedAt"] isKindOfClass:[NSDate class]], @"");
        
        XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
        XCTAssertEqualObjects(@(1337), entry.fields[@"lives"], @"");
        XCTAssertEqualObjects((@[ @"rainbows", @"fish" ]), entry.fields[@"likes"], @"");
        XCTAssertEqualObjects(@"rainbow", entry.fields[@"color"], @"");
        XCTAssertEqualObjects(@"2011-04-04 22:00:00 +0000",
                              [entry.fields[@"birthday"] description], @"");
        XCTAssertEqualObjects(@"happycat", [entry.fields[@"bestFriend"] identifier], @"");
        XCTAssertEqualObjects(@"Happy Cat", [entry.fields[@"bestFriend"] fields][@"name"], @"");
        XCTAssertEqualObjects([NSURL URLWithString:@"https://images.contentful.com/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png"],
                              [((CDAAsset*)entry.fields[@"image"]) URL], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testAllEntries {
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqualObjects(@"Array", array.sys[@"type"], @"");
        XCTAssertEqual(10U, array.total, @"");
        XCTAssertEqual(0U, array.skip, @"");
        XCTAssertEqual(100U, array.limit, @"");
        XCTAssertEqual(10U, array.items.count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testAsset {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        XCTAssertEqualObjects(@"Asset", asset.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", asset.sys[@"id"], @"");
        XCTAssertEqualObjects(@"Nyan Cat", asset.fields[@"title"], @"");
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", asset.fields[@"file"][@"fileName"], @"");
        XCTAssertEqualObjects(@"image/png", asset.fields[@"file"][@"contentType"], @"");
        XCTAssertEqualObjects(@"image/png", asset.MIMEType, @"");
        XCTAssertEqualObjects(@250, asset.fields[@"file"][@"details"][@"image"][@"width"], @"");
        XCTAssertEqualObjects(@250, asset.fields[@"file"][@"details"][@"image"][@"height"], @"");
        XCTAssertEqualObjects(@12273, asset.fields[@"file"][@"details"][@"size"], @"");
        XCTAssertEqualObjects([NSURL URLWithString:@"https://images.contentful.com/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png"],
                              asset.URL, @"");
        XCTAssertEqual(250.0f, asset.size.width, @"");
        XCTAssertEqual(250.0f, asset.size.height, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testAllAssets {
    StartBlock();
    
    [self.client fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqualObjects(@"Array", array.sys[@"type"], @"");
        XCTAssertEqual(4U, array.total, @"");
        XCTAssertEqual(0U, array.skip, @"");
        XCTAssertEqual(100U, array.limit, @"");
        XCTAssertEqual(4U, array.items.count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testLocalization {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"sys.id": @"nyancat",
                                         @"locale": @"tlh" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"Nyan vIghro'", [[array.items firstObject] fields][@"name"], @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testProtocolInServerConfiguration {
    StartBlock();

    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.server = @"http://cdn.contentful.com";
    self.client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi"
                                          accessToken:@"b4c0n73n7ful"
                                        configuration:configuration];

    [self.client fetchEntriesMatching:@{ @"sys.id": @"nyancat" }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(1U, array.items.count, @"");

                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);

                                  EndBlock();
                              }];
}

@end
