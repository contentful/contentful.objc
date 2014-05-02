//
//  CDAResourcesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAFieldsViewController+Private.h"
#import "CDAImageViewController.h"
#import "CDAResourcesViewController.h"
#import "CDAUtilities.h"

@interface CDAResourcesViewController ()

@property (nonatomic, readonly) NSString* cacheFileName;
@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) CDAArray* resources;
@property (nonatomic) NSArray* localItems;

@end

#pragma mark -

@implementation CDAResourcesViewController

+(Class)cellClass {
    return NSClassFromString(@"CDAResourceTableViewCell");
}

#pragma mark -

-(NSString *)cacheFileName {
    return CDACacheFileNameForQuery(self.client, self.resourceType, self.query);
}

-(void)didSelectRowWithResource:(CDAResource*)resource {
    if ([resource isKindOfClass:[CDAAsset class]]) {
        CDAImageViewController* imageVC = [CDAImageViewController new];
        imageVC.asset = (CDAAsset*)resource;
        imageVC.title = imageVC.asset.fields[@"title"];
        [self.navigationController pushViewController:imageVC animated:YES];
    }
    
    if ([resource isKindOfClass:[CDAContentType class]]) {
        CDAContentType* contentType = (CDAContentType*)resource;
        NSDictionary* cellMapping = contentType.displayField ? @{ @"textLabel.text": [@"fields." stringByAppendingString:contentType.displayField] } : nil;
        
        CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:cellMapping];
        entriesVC.client = self.client;
        entriesVC.query = @{ @"content_type": contentType.identifier };
        entriesVC.title = contentType.name;
        [self.navigationController pushViewController:entriesVC animated:YES];
    }
    
    if ([resource isKindOfClass:[CDAEntry class]]) {
        CDAFieldsViewController* fieldsVC = [[CDAFieldsViewController alloc]
                                             initWithEntry:(CDAEntry*)resource];
        fieldsVC.client = self.client;
        [self.navigationController pushViewController:fieldsVC animated:YES];
    }
}

-(void)handleCaching {
    if (self.offlineCaching) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.resources writeToFile:self.cacheFileName];
        });
    }
}

-(id)initWithCellMapping:(NSDictionary *)cellMapping {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.cellMapping = cellMapping;
        self.resourceType = CDAResourceTypeEntry;
        
        [self.tableView registerClass:[[self class] cellClass]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(id)initWithCellMapping:(NSDictionary *)cellMapping items:(NSArray *)items {
    self = [self initWithCellMapping:cellMapping];
    if (self) {
        self.localItems = items;
    }
    return self;
}

-(NSArray *)items {
    return self.localItems ?: self.resources.items;
}

-(void)showError:(NSError*)error {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.localItems) {
        return;
    }
    
    NSAssert(self.client, @"You need to supply a client instance to %@.",
             NSStringFromClass([self class]));
    
    [self.client fetchResourcesOfType:self.resourceType
                             matching:self.query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.resources = array;
                                  
                                  [self.tableView reloadData];
                                  [self handleCaching];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  if (CDAIsNoNetworkError(error)) {
                                      self.resources = [CDAArray readFromFile:self.cacheFileName
                                                                       client:self.client];
                                      
                                      [self.tableView reloadData];
                                      return;
                                  }
                                  
                                  [self showError:error];
                              }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.items.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }
    
    id item = self.items[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (![item isKindOfClass:[CDAResource class]]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [item respondsToSelector:@selector(stringValue)] ? [item stringValue] : item;
    }
    
    [self.cellMapping enumerateKeysAndObjectsUsingBlock:^(NSString* cellKeyPath,
                                                          NSString* entryKeyPath,
                                                          BOOL *stop) {
        [cell setValue:[item valueForKeyPath:entryKeyPath] forKeyPath:cellKeyPath];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    
    [self didSelectRowWithResource:self.items[indexPath.row]];
}

@end
