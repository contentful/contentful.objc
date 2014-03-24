//
//  UIKitAdditionsTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "ContentfulBaseTestCase.h"
#import "UIImageView+CDAAsset.h"

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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"entries"]) {
        CDAEntriesViewController* entriesVC = object;
        
        XCTAssertEqual(100U, [[entriesVC valueForKeyPath:@"entries.items"] count], @"");
        
        UITableViewCell* cell = [entriesVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        XCTAssertEqualObjects(@"2013-06-27 14:36:52 +0000", cell.detailTextLabel.text, @"");
        XCTAssertEqualObjects(@"La Puente, CA", cell.textLabel.text, @"");
    }
    
    if ([keyPath isEqualToString:@"image"]) {
        UIImageView* imageView = (UIImageView*)object;
        
        [self compareImage:imageView.image forTestSelector:self.currentTestSelector];
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
    [entriesVC viewWillAppear:NO];
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [entriesVC removeObserver:self forKeyPath:@"entries" context:nil];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
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

@end
