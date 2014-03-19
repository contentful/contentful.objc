//
//  CDAEntriesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAEntriesViewController.h"
#import "CDAFieldsViewController+Private.h"
#import "CDAImageViewController.h"

@interface CDAEntriesViewController () <CDAEntriesViewControllerDelegate>

@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) CDAArray* entries;
@property (nonatomic) NSArray* localItems;

@end

#pragma mark -

@implementation CDAEntriesViewController

+(Class)cellClass {
    return NSClassFromString(@"CDAEntryCell");
}

#pragma mark -

-(id)initWithCellMapping:(NSDictionary *)cellMapping {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.cellMapping = cellMapping;
        self.delegate = self;
        
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
    return self.localItems ?: self.entries.items;
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
    
    NSAssert(self.client, @"You need to supply a client instance to CDAEntriesViewController.");
    
    [self.client fetchEntriesMatching:self.query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.entries = array;
                                  
                                  [self.tableView reloadData];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  [self showError:error];
                              }];
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    if ([entry isKindOfClass:[CDAAsset class]]) {
        CDAImageViewController* imageVC = [CDAImageViewController new];
        imageVC.asset = (CDAAsset*)entry;
        imageVC.title = entry.fields[@"title"];
        [self.navigationController pushViewController:imageVC animated:YES];
        return;
    }
    
    CDAFieldsViewController* fieldsVC = [[CDAFieldsViewController alloc] initWithEntry:entry];
    fieldsVC.client = self.client;
    [self.navigationController pushViewController:fieldsVC animated:YES];
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
    
    if ([self.delegate respondsToSelector:@selector(entriesViewController:didSelectRowWithEntry:)]) {
        [self.delegate entriesViewController:self didSelectRowWithEntry:self.items[indexPath.row]];
    }
}

@end
