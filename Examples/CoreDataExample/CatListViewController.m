//
//  CatListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import "Asset.h"
#import "CatListViewController.h"
#import "CoreDataManager.h"
#import "ManagedCat.h"
#import "SyncInfo.h"

@interface CatListViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic) CoreDataManager* manager;

@end

#pragma mark -

@implementation CatListViewController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [self.manager fetchRequestForEntriesMatchingPredicate:@"contentTypeIdentifier == 'cat'"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *colorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"color" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor, colorDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.manager.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([self class])];
    
    [self.manager performSynchronizationWithSuccess:^{
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use
             this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.tableView reloadData];
    } failure:^(CDAResponse *response, NSError *error) {
        // Replace this implementation with code to handle the error appropriately.
        NSLog(@"Error while loading content: %@, %@", error, [error userInfo]);
        abort();
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.fetchedResultsController = nil;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ManagedCat* cat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = cat.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
