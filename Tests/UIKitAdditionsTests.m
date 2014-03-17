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

@property (nonatomic) BOOL waiting;

@end

#pragma mark -

@implementation UIKitAdditionsTests

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"entries"]) {
        CDAEntriesViewController* entriesVC = object;
        
        XCTAssertEqual(100U, [[entriesVC valueForKeyPath:@"entries.items"] count], @"");
        
        UITableViewCell* cell = [entriesVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        XCTAssertEqualObjects(@"United States", cell.detailTextLabel.text, @"");
        XCTAssertEqualObjects(@"Doylestown, PA", cell.textLabel.text, @"");
    }
    
    if ([keyPath isEqualToString:@"image"]) {
        UIImageView* imageView = (UIImageView*)object;
        
        [self compareImage:imageView.image forTestSelector:@selector(testImageViewCategory)];
    }
    
    self.waiting = NO;
}

- (void)testEntriesViewController {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"fields.locationName", @"detailTextLabel.text": @"fields.country" }];
    entriesVC.client = self.client;
    entriesVC.query = @{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" };
    
    self.waiting = YES;
    
    [entriesVC addObserver:self forKeyPath:@"entries" options:0 context:NULL];
    [entriesVC viewWillAppear:NO];
    
    NSDate* now = [NSDate date];
    WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
    
    [entriesVC removeObserver:self forKeyPath:@"entries" context:nil];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
}

- (void)testImageViewCategory {
    StartBlock();
    
    __block UIImageView* imageView = nil;
    
    [self.client fetchAssetWithIdentifier:@"nyancat"
                                  success:^(CDAResponse *response, CDAAsset *asset) {
                                      imageView = [UIImageView new];
                                      [imageView cda_setImageWithAsset:asset];
                                      
                                      EndBlock();
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      XCTFail(@"Error: %@", error);
                                      
                                      EndBlock();
                                  }];
    
    WaitUntilBlockCompletes();
    
    if (imageView) {
        self.waiting = YES;
        
        [imageView addObserver:self forKeyPath:@"image" options:0 context:NULL];
        
        NSDate* now = [NSDate date];
        WaitWhile(self.waiting && [[NSDate date] timeIntervalSinceDate:now] < 3.0);
        
        [imageView removeObserver:self forKeyPath:@"image" context:NULL];
        
        XCTAssertFalse(self.waiting, @"Observer hasn't fired after 3 seconds.");
    }
}

@end
