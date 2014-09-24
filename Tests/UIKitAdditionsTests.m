//
//  UIKitAdditionsTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "CDAFieldCell.h"
#import "CDAImageViewController.h"
#import "CDATextViewController.h"
#import "CDAResourceTableViewCell.h"
#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"
#import "UIImageView+CDAAsset.h"

@interface CDAFieldsViewController ()

@property (nonatomic, readonly) CDAEntry* entry;

@end

#pragma mark -

@interface CDATextViewController ()

@property (nonatomic, readonly) UITextView* textView;

@end

#pragma mark - 

@interface MyCDAFieldsViewController : CDAFieldsViewController

@end

#pragma mark -

@implementation MyCDAFieldsViewController

-(NSArray *)visibleFields {
    return @[ @"someText" ];
}

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
    
    UIImageView* imageView = imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                                       250.0, 250.0)];
    
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

- (CDAEntry*)buildEntry {
    return [self buildEntryWithLinkedAssetOrEntry:NO];
}

- (CDAEntry*)buildEntryWithLinkedAssetOrEntry:(BOOL)assetOrEntry {
    NSDictionary* linkedAsset = @{ @"sys": @{ @"id": @"foo", @"type": @"Asset" } };
    NSDictionary* linkedEntry = @{ @"sys": @{ @"id": @"bar", @"type": @"Entry",
                                              @"contentType": @{ @"sys": @{ @"id": @"trolololo" } } },
                                   @"fields": @{ @"someText": @"text" }, };
    return [self customEntryHelperWithFields:@{
                                               @"someArray": @[ linkedEntry ],
                                               @"someBool": @YES,
                                               @"someDate": @"2014-01-01",
                                               @"someInteger": @1,
                                               @"someLink": assetOrEntry ? linkedAsset : linkedEntry,
                                               @"someLocation": [NSNull null],
                                               @"someNumber": @1.1,
                                               @"someSymbol": @"text",
                                               @"someText": @"text",
                                               }];
}

- (CDAFieldsViewController*)buildFieldsViewController {
    return [[CDAFieldsViewController alloc] initWithEntry:[self buildEntry]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    self.waiting = NO;
    
    if ([object isKindOfClass:[CDAEntriesViewController class]]) {
        CDAEntriesViewController* entriesVC = object;
        
        XCTAssertEqual(100U, entriesVC.items.count, @"");
        
        UITableViewCell* cell = [entriesVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        XCTAssertEqualObjects(@"2013-06-27 14:36:52 +0000", cell.detailTextLabel.text, @"");
        XCTAssertEqualObjects(@"La Puente, CA", cell.textLabel.text, @"");
        
        return;
    }
    
    if ([keyPath isEqualToString:@"image"]) {
        UIImageView* imageView = (UIImageView*)object;
        
        [self compareView:imageView forTestSelector:self.currentTestSelector];
    }
    
    if ([keyPath isEqualToString:@"resources"]) {
        CDAResourcesCollectionViewController* resourcesVC = object;
        
        if (resourcesVC.items == nil) {
            self.waiting = YES;
            return;
        }
      
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
}

- (void)testEntriesViewController {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"fields.locationName", @"detailTextLabel.text": @"sys.updatedAt.description" }];
    entriesVC.client = self.client;
    entriesVC.query = @{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY", @"order": @"sys.createdAt" };
    
    self.waiting = YES;
    
    [entriesVC addObserver:self forKeyPath:@"resources" options:0 context:NULL];
    
    XCTAssertNotNil(entriesVC.view, @"");
    [entriesVC viewWillAppear:NO];
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [entriesVC removeObserver:self forKeyPath:@"resources" context:nil];
    
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

    StartBlock();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert([navigationController.topViewController isKindOfClass:[CDAFieldsViewController class]], @"");
        EndBlock();
    });

    WaitUntilBlockCompletes();
}

- (void)testFieldsViewController {
    CDAFieldsViewController* fieldsVC = [self buildFieldsViewController];
    
    XCTAssertNotNil(fieldsVC.view, @"");
    [fieldsVC viewWillAppear:NO];
    
    XCTAssertEqual(9, [fieldsVC.tableView numberOfRowsInSection:0], @"");
    
    [fieldsVC.entry.contentType.fields enumerateObjectsUsingBlock:^(CDAField* field,
                                                                    NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        CDAFieldCell* cell = (CDAFieldCell*)[fieldsVC.tableView cellForRowAtIndexPath:indexPath];
        
        XCTAssertEqualObjects(field.name, cell.textLabel.text, @"");
        XCTAssertEqualObjects(field, cell.field, @"");
        XCTAssertEqualObjects(fieldsVC.entry.fields[field.identifier], cell.value, @"");
    }];
}

- (void)testFieldsViewControllerCanHideFields {
    MyCDAFieldsViewController* fieldsVC = [[MyCDAFieldsViewController alloc]
                                           initWithEntry:[self buildEntry]];
    
    XCTAssertNotNil(fieldsVC.view, @"");
    [fieldsVC viewWillAppear:NO];
    
    XCTAssertEqual(1, [fieldsVC.tableView numberOfRowsInSection:0], @"");
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

- (void)testResourcesViewControllerDoesNotThrowWhenSelectingGarbage {
    CDAResourcesViewController* resourcesVC = [[CDAResourcesViewController alloc] initWithCellMapping:nil items:@[ [self customEntryHelperWithFields:@{}] ]];
    [resourcesVC didSelectRowWithResource:(CDAResource*)[NSDate date]];
}

- (void)testResourcesViewControllerShowsImageViewControllerForAssets {
    CDAAsset* asset = [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"foo" },
                                                              @"contentType": @"image/png" }
                                                              client:self.client];
    CDAResourcesViewController* resourcesVC = [[CDAResourcesViewController alloc] initWithCellMapping:nil items:@[ asset ]];
    
    XCTAssertNotNil(resourcesVC.view, @"");
    [resourcesVC viewWillAppear:NO];
    
    UINavigationController* navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:resourcesVC];
    [resourcesVC tableView:resourcesVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    StartBlock();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CDAImageViewController* topVC = (CDAImageViewController*)navigationController.topViewController;
                       XCTAssert([topVC isKindOfClass:[CDAImageViewController class]], @"");
                       XCTAssertNotNil(topVC.view, @"");
                       
                       EndBlock();
                   });

    WaitUntilBlockCompletes();
}

- (void)testResourceTableViewCell {
    CDAResourceTableViewCell* cell = [[CDAResourceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    XCTAssertNotNil(cell, @"");
    XCTAssertNotNil(cell.detailTextLabel, @"");
}

- (void)testTextViewController {
    CDAFieldsViewController* fieldsVC = [self buildFieldsViewController];
    UINavigationController* navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:fieldsVC];
    
    CDAField* field = [self customEntryHelperWithFields:@{}].contentType.fields[8];
    NSString* textValue = @"texttexttexttexttexttexttexttexttext";
    [fieldsVC didSelectRowWithValue:textValue forField:field];

    StartBlock();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CDATextViewController* topVC = (CDATextViewController*)navigationController.topViewController;
        XCTAssert([topVC isKindOfClass:[CDATextViewController class]], @"");
        XCTAssertEqualObjects(topVC.text, textValue, @"");
        XCTAssertNotNil(topVC.view, @"");
        XCTAssertEqualObjects(topVC.textView.text, textValue, @"");

        EndBlock();
    });

    WaitUntilBlockCompletes();
}

@end
