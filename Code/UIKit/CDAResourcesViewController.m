//
//  CDAResourcesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAImageViewController.h>
#import <ContentfulDeliveryAPI/CDAResourcesViewController.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAFieldsViewController+Private.h"
#import "CDAUtilities.h"

@interface CDAResourcesViewController () <UISearchBarDelegate>

@property (nonatomic, readonly) NSString* cacheFileName;
@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) BOOL firstTime;
@property (nonatomic) CDAArray* resources;
@property (nonatomic) NSArray* localItems;
@property (nonatomic) UISearchBar* searchBar;

@end

#pragma mark -

@implementation CDAResourcesViewController

+(Class)cellClass {
    Class cellClass = NSClassFromString(@"CDAResourceTableViewCell");
    NSParameterAssert(cellClass);
    return cellClass;
}

#pragma mark -

-(NSString *)cacheFileName {
    return CDACacheFileNameForQuery(self.client, self.resourceType, self.query);
}

-(void)didSelectRowWithResource:(CDAResource*)resource {
    if (CDAClassIsOfType([resource class], CDAAsset.class)) {
        CDAImageViewController* imageVC = [CDAImageViewController new];
        imageVC.asset = (CDAAsset*)resource;
        imageVC.title = imageVC.asset.fields[@"title"];
        [self.navigationController pushViewController:imageVC animated:YES];
    }
    
    if (CDAClassIsOfType([resource class], CDAContentType.class)) {
        CDAContentType* contentType = (CDAContentType*)resource;
        NSString* displayField = contentType.displayField;
        NSDictionary* cellMapping = displayField ? @{ @"textLabel.text": [@"fields." stringByAppendingString:displayField] } : nil;
        
        CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:cellMapping];
        entriesVC.client = self.client;
        entriesVC.locale = self.locale;
        entriesVC.query = @{ @"content_type": contentType.identifier };
        entriesVC.title = contentType.name;
        [self.navigationController pushViewController:entriesVC animated:YES];
    }
    
    if (CDAClassIsOfType([resource class], CDAEntry.class)) {
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
        self.firstTime = YES;
        self.resourceType = CDAResourceTypeEntry;

        if ([self.tableView respondsToSelector:@selector(keyboardDismissMode)]) {
            [self.tableView setValue:@(UIScrollViewKeyboardDismissModeInteractive)
                              forKey:@"keyboardDismissMode"];
        }

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

-(void)performQuery:(NSDictionary*)query {
    NSAssert(self.client, @"You need to supply a client instance to %@.",
             NSStringFromClass([self class]));
    
    [self.client fetchResourcesOfType:self.resourceType
                             matching:query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.resources = array;
                                  
                                  [self.tableView reloadData];
                                  [self handleCaching];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  CDAClient* client = self.client;
                                  NSParameterAssert(client);

                                  if (CDAIsNoNetworkError(error) && client) {
                                      self.resources = [CDAArray readFromFile:self.cacheFileName
                                                                       client:client];
                                      
                                      [self.tableView reloadData];
                                      return;
                                  }
                                  
                                  [self showError:error];
                              }];
}

-(NSDictionary *)query {
    if (!self.locale) {
        return _query;
    }
    
    NSMutableDictionary* query = [_query mutableCopy];
    query[@"locale"] = self.locale;
    return query;
}

-(void)setShowSearchBar:(BOOL)showSearchBar {
    if (_showSearchBar == showSearchBar) {
        return;
    }
    
    if (showSearchBar) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                       self.tableView.frame.size.width,
                                                                       44.0)];
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        self.tableView.tableHeaderView = self.searchBar;
    } else {
        self.searchBar = nil;
        self.tableView.tableHeaderView = nil;
    }
    
    _showSearchBar = showSearchBar;
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
    
    [self performQuery:self.query];
    
    if (self.showSearchBar && self.firstTime) {
        self.firstTime = NO;
        self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [self.view endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.localItems) {
        NSAssert(@"Search is not supported for local content.", nil);
        return;
    }
    
    [self.view endEditing:YES];

    if (self.query) {
        NSDictionary* myQuery = self.query;
        NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithDictionary:myQuery];
        query[@"query"] = searchBar.text;
        [self performQuery:query];
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [self performQuery:self.query];
    }
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
    
    if (!CDAClassIsOfType([item class], CDAResource.class)) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [item respondsToSelector:@selector(stringValue)] ? [item stringValue] : item;
    }
    
    [self.cellMapping enumerateKeysAndObjectsUsingBlock:^(NSString* cellKeyPath,
                                                          NSString* entryKeyPath,
                                                          BOOL *stop) {
        id value = [item valueForKeyPath:entryKeyPath];

        if (![value isKindOfClass:[NSString class]]) {
            if ([value respondsToSelector:@selector(stringValue)]) {
                value = [value stringValue];
            } else {
                return;
            }
        }

        [cell setValue:value forKeyPath:cellKeyPath];
    }];
    
    if (cell.textLabel.text.length == 0 && CDAClassIsOfType([item class], CDAResource.class)) {
        cell.textLabel.text = [(CDAResource*)item identifier];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }

    id entry = self.items[indexPath.row];

    if (entry) {
        [self didSelectRowWithResource:entry];
    }
}

@end
