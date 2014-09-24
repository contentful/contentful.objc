//
//  ValueObjectsTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface Cat : CDAEntry

@property (nonatomic, readonly) NSString* name;

@end

#pragma mark -

@implementation Cat

-(NSString *)name {
    return self.fields[@"name"];
}

@end

#pragma mark -

@interface OtherCat : NSObject

@property (nonatomic, readonly) NSDate* creationDate;
@property (nonatomic, readonly) NSArray* likes;
@property (nonatomic, readonly) NSUInteger lives;
@property (nonatomic, readonly) NSString* string;

@end

#pragma mark -

@interface OtherCat ()

@property (nonatomic) NSDate* creationDate;
@property (nonatomic) NSArray* likes;
@property (nonatomic) NSUInteger lives;
@property (nonatomic, copy) NSString* name;

@end

#pragma mark -

@implementation OtherCat

@end

#pragma mark -

@interface ValueObjectsTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ValueObjectsTests

- (void)testEqualityOfEntries {
    StartBlock();
    
    [self.client registerClass:[Cat class] forContentTypeWithIdentifier:@"cat"];
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *cat) {
        [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response,
                                                                   CDAEntry *entry) {
            XCTAssertNotNil(cat, @"");
            XCTAssertEqualObjects(entry, cat, @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testCustomClassesWithContentTypeIdentifier {
    StartBlock();
    
    [self.client registerClass:[Cat class] forContentTypeWithIdentifier:@"cat"];
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *cat) {
        XCTAssert([cat isKindOfClass:[Cat class]], @"");
        XCTAssertEqualObjects(@"Nyan Cat", ((Cat*)cat).name, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testCustomClassesWithContentTypeInstance {
    StartBlock();
    
    [self.client fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        CDAContentType* catContentType = nil;
        for (CDAContentType* contentType in array.items) {
            if ([contentType.identifier isEqualToString:@"cat"]) {
                catContentType = contentType;
                break;
            }
        }
        
        [self.client registerClass:[Cat class] forContentType:catContentType];
        
        [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *r, CDAEntry *cat) {
            XCTAssert([cat isKindOfClass:[Cat class]], @"");
            XCTAssertEqualObjects(@"Nyan Cat", ((Cat*)cat).name, @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testLocationValues {
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    
    StartBlock();
    
    [client fetchEntriesMatching:@{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" }
                         success:^(CDAResponse *response, CDAArray *array) {
                             CDAEntry* firstEntry = [array.items firstObject];
                             CLLocationCoordinate2D coordinate = [firstEntry CLLocationCoordinate2DFromFieldWithIdentifier:@"location"];
                             XCTAssertEqualWithAccuracy(40.31, coordinate.latitude, 0.01, @"");
                             XCTAssertEqualWithAccuracy(-75.12, coordinate.longitude, 0.01, @"");
                             
                             EndBlock();
                         } failure:^(CDAResponse *response, NSError *error) {
                             XCTFail(@"Error: %@", error);
                             
                             EndBlock();
                         }];
    
    WaitUntilBlockCompletes();
}

- (void)testNonUSDefaultLocale {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"icgl406qq59m" accessToken:@"77a3cc4cfaef46d2d93d7924f571d45392a4abb998c1d17d301bc7dc62f3dfd4"];
    
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqual(1UL, array.items.count, @"");
        
        CDAEntry* entry = array.items.firstObject;
        XCTAssertEqualObjects(@"My first entry", entry.fields[@"title"], @"");
        XCTAssertEqualObjects(@"Hello, world!", entry.fields[@"body"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testObjectMapping {
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        OtherCat* cat = [entry mapFieldsToObject:[OtherCat new]
                                    usingMapping:@{ @"fields.name": @"name",
                                                    @"fields.likes": @"likes",
                                                    @"fields.lives": @"lives",
                                                    @"sys.createdAt": @"creationDate" }];
        XCTAssertEqualObjects(entry.fields[@"name"], cat.name, @"");
        XCTAssertEqualObjects(entry.sys[@"createdAt"], cat.creationDate, @"");
        XCTAssertEqualObjects((@[ @"rainbows", @"fish" ]), cat.likes, @"");
        XCTAssertEqual(1337U, cat.lives, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
