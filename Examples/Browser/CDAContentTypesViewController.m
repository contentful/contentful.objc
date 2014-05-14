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
    } else {
        mapping = @{ @"textLabel.text": @"sys.id" };
    }
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:mapping];
    entriesVC.client = self.client;
    entriesVC.delegate = self;
    entriesVC.locale = self.locale;
    entriesVC.query = @{ @"content_type": contentType.identifier };
    entriesVC.showSearchBar = YES;
    entriesVC.title = contentType.name;
    
    [self.navigationController pushViewController:entriesVC animated:YES];
}

-(id)init {
    self = [super initWithCellMapping:@{ @"textLabel.text": @"name",
                                         @"detailTextLabel.text": @"userDescription" } ];
    if (self) {
        self.resourceType = CDAResourceTypeContentType;
        self.tabBarItem.image = [UIImage imageNamed:@"entries"];
        self.title = NSLocalizedString(@"Entries", nil);
    }
    return self;
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    CDAEntryPreviewController* previewController = [[CDAEntryPreviewController alloc] initWithEntry:entry];
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDAContentType* contentType = self.items[indexPath.row];
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* entryCountLabel = nil;
    if (cell.contentView.subviews.count == 3) {
        entryCountLabel = [cell.contentView.subviews lastObject];
    } else {
        entryCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 120.0, 0.0,
                                                                    70.0, cell.frame.size.height)];
        
        entryCountLabel.font = cell.detailTextLabel.font;
        entryCountLabel.textAlignment = NSTextAlignmentRight;
        entryCountLabel.textColor = cell.detailTextLabel.textColor;
        
        [cell.contentView addSubview:entryCountLabel];
    }
    
    [self.client fetchEntriesMatching:@{ @"content_type": contentType.identifier, @"limit": @0 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  entryCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d entries", nil), array.total];
                                  
                                  if (array.total == 0) {
                                      cell.accessoryType = UITableViewCellAccessoryNone;
                                  }
                              } failure:nil];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
