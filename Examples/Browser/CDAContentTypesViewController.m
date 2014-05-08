//
//  CDAContentTypesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import "CDAContentTypesViewController.h"
#import "CDAEntryPreviewController.h"

@interface CDAContentTypesViewController () <CDAEntriesViewControllerDelegate>

@end

#pragma mark -

@implementation CDAContentTypesViewController

-(void)didSelectRowWithResource:(CDAResource *)resource {
    CDAContentType* contentType = (CDAContentType*)resource;
    
    NSDictionary* mapping = nil;
    if (contentType.displayField) {
        mapping = @{ @"textLabel.text": [@"fields." stringByAppendingString:contentType.displayField] };
    }
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:mapping];
    entriesVC.client = self.client;
    entriesVC.delegate = self;
    entriesVC.locale = self.locale;
    entriesVC.query = @{ @"content_type": contentType.identifier };
    
    [self.navigationController pushViewController:entriesVC animated:YES];
}

-(id)init {
    self = [super initWithCellMapping:@{ @"textLabel.text": @"name" }];
    if (self) {
        self.resourceType = CDAResourceTypeContentType;
        self.title = NSLocalizedString(@"Preview", nil);
    }
    return self;
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    CDAEntryPreviewController* previewController = [[CDAEntryPreviewController alloc] initWithEntry:entry];
    [self.navigationController pushViewController:previewController animated:YES];
}

@end
