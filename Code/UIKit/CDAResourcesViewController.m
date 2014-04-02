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

@interface CDAResourcesViewController ()

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

-(void)didSelectRowWithResource:(CDAResource*)resource {
    if ([resource isKindOfClass:[CDAAsset class]]) {
        CDAImageViewController* imageVC = [CDAImageViewController new];
        imageVC.asset = (CDAAsset*)resource;
        imageVC.title = imageVC.asset.fields[@"title"];
        [self.navigationController pushViewController:imageVC animated:YES];
        return;
    }
    
    if (![resource isKindOfClass:[CDAEntry class]]) {
        return;
    }
    
    CDAFieldsViewController* fieldsVC = [[CDAFieldsViewController alloc]
                                         initWithEntry:(CDAEntry*)resource];
    fieldsVC.client = self.client;
    [self.navigationController pushViewController:fieldsVC animated:YES];
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
                              } failure:^(CDAResponse *response, NSError *error) {
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
    
    CDAEntry* entry = self.items[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.cellMapping enumerateKeysAndObjectsUsingBlock:^(NSString* cellKeyPath,
                                                          NSString* entryKeyPath,
                                                          BOOL *stop) {
        [cell setValue:[entry valueForKeyPath:entryKeyPath] forKeyPath:cellKeyPath];
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
