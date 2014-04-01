//
//  UIKitAdditionsTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "CDATextViewController.h"
#import "ContentfulBaseTestCase.h"
#import "UIImageView+CDAAsset.h"

@interface CDATextViewController ()

@property (nonatomic, readonly) UITextView* textView;

@end

#pragma mark -

@interface UIKitAdditionsTests : ContentfulBaseTestCase

@property (nonatomic) SEL currentTestSelector;
@property (nonatomic) BOOL waiting;

@end

#pragma mark -

@implementation UIKitAdditionsTests

- (void)imageViewTestHelperForAssetWithIdentifier:(NSString*)identifier
                                          success:(void (^)(UIImageView* imageView,
                                                            CDAAsset* asset))success
                                          failure:(CDARequestFailureBlock)failure {
    StartBlock();
    
    UIImageView* imageView = imageView = [UIImageView new];
    
    self.waiting = YES;
    
    [imageView addObserver:self forKeyPath:@"image" options:0 context:NULL];
    
    [self.client fetchAssetWithIdentifier:identifier
                                  success:^(CDAResponse *response, CDAAsset *asset) {
                                      success(imageView, asset);
                                      
                                      EndBlock();
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      failure(response, error);
                                      
                                      EndBlock();
                                  }];
    
    WaitUntilBlockCompletes();
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [imageView removeObserver:self forKeyPath:@"image" context:NULL];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
}

#pragma mark -

- (CDAFieldsViewController*)buildFieldsViewController {
    CDAEntry* entry = [self customEntryHelperWithFields:@{
                                                          @"someArray": [NSNull null],
                                                          @"someBool": @YES,
                                                          @"someDate": @"2014-01-01",
                                                          @"someInteger": @1,
                                                          @"someLink": [NSNull null],
                                                          @"someLocation": [NSNull null],
                                                          @"someNumber": @1.1,
                                                          @"someSymbol": @"text",
                                                          @"someText": @"text",
                                                          }];
    
    return [[CDAFieldsViewController alloc] initWithEntry:entry];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"entries"]) {
        CDAEntriesViewController* entriesVC = object;
        
        XCTAssertEqual(100U, entriesVC.items.count, @"");
        
        UITableViewCell* cell = [entriesVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        XCTAssertEqualObjects(@"2013-06-27 14:36:52 +0000", cell.detailTextLabel.text, @"");
        XCTAssertEqualObjects(@"La Puente, CA", cell.textLabel.text, @"");
    }
    
    if ([keyPath isEqualToString:@"image"]) {
        UIImageView* imageView = (UIImageView*)object;
        
        [self compareImage:imageView.image forTestSelector:self.currentTestSelector];
    }
    
    if ([keyPath isEqualToString:@"resources"]) {
        CDAResourcesCollectionViewController* resourcesVC = object;
      
        XCTAssertEqual(4U, resourcesVC.items.count, @"");
        XCTAssertEqual(4, [resourcesVC.collectionView.dataSource collectionView:resourcesVC.collectionView numberOfItemsInSection:0], @"");
        
        // FIXME: Does not work because dataSource is never consulted somehow.
#if 0
        UICollectionViewCell* cell = [resourcesVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        NSError* error;
        XCTAssert([self.snapshotTestController compareSnapshotOfView:cell
                                                            selector:self.currentTestSelector
                                                          identifier:nil
                                                               error:&error], @"Error: %@", error);
#endif
    }
    
    self.waiting = NO;
}

- (void)testEntriesViewController {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"fields.locationName", @"detailTextLabel.text": @"sys.updatedAt.description" }];
    entriesVC.client = self.client;
    entriesVC.query = @{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY", @"order": @"sys.createdAt" };
    
    self.waiting = YES;
    
    [entriesVC addObserver:self forKeyPath:@"entries" options:0 context:NULL];
    
    XCTAssertNotNil(entriesVC.view, @"");
    [entriesVC viewWillAppear:NO];
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [entriesVC removeObserver:self forKeyPath:@"entries" context:nil];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
}

- (void)testEntriesViewControllerLocally {
    CDAEntry* entry = [self customEntryHelperWithFields:@{ @"someText": @"title" }];
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"fields.someText" } items:@[ entry ]];
    
    XCTAssertNotNil(entriesVC.view, @"");
    [entriesVC viewWillAppear:NO];
    
    XCTAssertEqual(1U, entriesVC.items.count, @"");
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell* cell = [entriesVC.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertEqualObjects(@"title", cell.textLabel.text, @"");
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:entriesVC];
    [entriesVC tableView:entriesVC.tableView didSelectRowAtIndexPath:indexPath];
    XCTAssert([navigationController.topViewController isKindOfClass:[CDAFieldsViewController class]],
              @"");
}

- (void)testFieldsViewController {
    CDAFieldsViewController* fieldsVC = [self buildFieldsViewController];
    
    XCTAssertEqual(9, [fieldsVC.tableView numberOfRowsInSection:0], @"");
}

- (void)testImageViewCategory {
    self.currentTestSelector = _cmd;
    
    [self imageViewTestHelperForAssetWithIdentifier:@"nyancat"
                                            success:^(UIImageView *imageView, CDAAsset *asset) {
                                                [imageView cda_setImageWithAsset:asset];
                                            } failure:^(CDAResponse *response, NSError *error) {
                                                XCTFail(@"Error: %@", error);
                                            }];
    
    self.currentTestSelector = NULL;
}

- (void)testImageViewCategoryWithPlaceholder {
    self.currentTestSelector = _cmd;
    
    [self imageViewTestHelperForAssetWithIdentifier:@"nyancat"
                                            success:^(UIImageView *imageView, CDAAsset *asset) {
                                                [imageView cda_setImageWithAsset:asset
                                                                placeholderImage:nil];
                                            } failure:^(CDAResponse *response, NSError *error) {
                                                XCTFail(@"Error: %@", error);
                                            }];
    
    self.currentTestSelector = NULL;
}

- (void)testImageViewCategoryWithPlaceholderAndSize {
    self.currentTestSelector = _cmd;
    
    [self imageViewTestHelperForAssetWithIdentifier:@"nyancat"
                                            success:^(UIImageView *imageView, CDAAsset *asset) {
                                                [imageView cda_setImageWithAsset:asset
                                                                            size:CGSizeMake(50.0, 50.0)
                                                                placeholderImage:nil];
                                            } failure:^(CDAResponse *response, NSError *error) {
                                                XCTFail(@"Error: %@", error);
                                            }];
    
    self.currentTestSelector = NULL;
}

- (void)testImageViewCategoryWithSize {
    self.currentTestSelector = _cmd;
    
    [self imageViewTestHelperForAssetWithIdentifier:@"nyancat"
                                            success:^(UIImageView *imageView, CDAAsset *asset) {
                                                [imageView cda_setImageWithAsset:asset
                                                                            size:CGSizeMake(50.0, 50.0)];
                                            } failure:^(CDAResponse *response, NSError *error) {
                                                XCTFail(@"Error: %@", error);
                                            }];
    
    self.currentTestSelector = NULL;
}

- (void)testResourcesCollectionViewController {
    self.currentTestSelector = _cmd;
    
    CDAResourcesCollectionViewController* resourcesVC = [[CDAResourcesCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new] cellMapping:@{@"imageURL": @"URL"}];
    resourcesVC.client = self.client;
    resourcesVC.resourceType = CDAResourceTypeAsset;
    
    self.waiting = YES;
    
    [resourcesVC addObserver:self forKeyPath:@"resources" options:0 context:NULL];
    
    XCTAssertNotNil(resourcesVC.view, @"");
    [resourcesVC viewWillAppear:NO];
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [resourcesVC removeObserver:self forKeyPath:@"resources" context:nil];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
    
    self.currentTestSelector = NULL;
}

- (void)testTextViewController {
    CDAFieldsViewController* fieldsVC = [self buildFieldsViewController];
    UINavigationController* navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:fieldsVC];
    
    CDAField* field = [self customEntryHelperWithFields:@{}].contentType.fields[8];
    NSString* textValue = @"texttexttexttexttexttexttexttexttext";
    [fieldsVC didSelectRowWithValue:textValue forField:field];
    
    CDATextViewController* topVC = (CDATextViewController*)navigationController.topViewController;
    XCTAssert([topVC isKindOfClass:[CDATextViewController class]], @"");
    XCTAssertEqualObjects(topVC.text, textValue, @"");
    XCTAssertNotNil(topVC.view, @"");
    XCTAssertEqualObjects(topVC.textView.text, textValue, @"");
}

@end
