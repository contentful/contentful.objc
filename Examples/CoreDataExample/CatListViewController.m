//
//  CatListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import "Asset.h"
#import "CatDetailViewController.h"
#import "CatListViewController.h"
#import "CoreDataFetchDataSource.h"
#import "CoreDataManager.h"
#import "ManagedCat.h"
#import "SyncInfo.h"

@interface CatListViewController ()

@property (nonatomic, readonly) CoreDataFetchDataSource* dataSource;
@property (nonatomic, readonly) CoreDataManager* manager;

@end

#pragma mark -

@implementation CatListViewController

@synthesize dataSource = _dataSource;
@synthesize manager = _manager;

#pragma mark -

- (CoreDataFetchDataSource *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    
    NSFetchRequest* fetchRequest = [self.manager fetchRequestForEntriesMatchingPredicate:@"contentTypeIdentifier == 'cat'"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *colorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"color" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor, colorDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:self.manager.managedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];
    
    _dataSource = [[CoreDataFetchDataSource alloc] initWithFetchedResultsController:controller
                                                                          tableView:self.tableView
                                                                     cellIdentifier:NSStringFromClass([self class])];
    
    __weak typeof(self) welf = self;
    _dataSource.cellConfigurator = ^(UITableViewCell* cell, NSIndexPath* indexPath) {
        ManagedCat* cat = [welf.dataSource objectAtIndexPath:indexPath];
        cell.textLabel.text = cat.name;
    };
    
    return _dataSource;
}

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        self.title = NSLocalizedString(@"Cats", nil);
    }
    return self;
}

- (CoreDataManager *)manager {
    if (_manager) {
        return _manager;
    }
    
    _manager = [[CoreDataManager alloc] initWithClient:[CDAClient new]
                                         dataModelName:@"CoreDataExample"];
    
    _manager.classForAssets = [Asset class];
    _manager.classForEntries = [ManagedCat class];
    _manager.classForSpaces = [SyncInfo class];
    
    _manager.mappingForEntries = @{ @"contentType.identifier": @"contentTypeIdentifier",
                                    @"fields.color": @"color",
                                    @"fields.lives": @"livesLeft",
                                    @"fields.name": @"name",
                                    @"fields.image": @"picture" };
    return _manager;
}

- (void)refresh {
    [self.manager performSynchronizationWithSuccess:^{
        NSLog(@"Synchronization finished.");
    } failure:^(CDAResponse *response, NSError *error) {
        // Replace this implementation with code to handle the error appropriately.
        NSLog(@"Error while loading content: %@, %@", error, [error userInfo]);
        abort();
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([self class])];
    
    [self.manager performSynchronizationWithSuccess:^{
        [self.dataSource performFetch];
    } failure:^(CDAResponse *response, NSError *error) {
        // For brevity's sake, we do not check the cause of the error, but a real app should.
        [self.dataSource performFetch];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ManagedCat* cat = [self.dataSource objectAtIndexPath:indexPath];
    CatDetailViewController* details = [[CatDetailViewController alloc] initWithCat:cat];
    details.client = self.manager.client;
    [self.navigationController pushViewController:details animated:YES];
}

@end
