//
//  CoreDataFetchDataSource.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import "CDAUtilities.h"
#import "CoreDataFetchDataSource.h"

@interface CoreDataFetchDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, copy) NSString* cellIdentifier;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSMutableArray* objectChanges;
@property (nonatomic, strong) NSMutableArray* sectionChanges;
@property (nonatomic, weak) UITableView* tableView;

@end

#pragma mark -

@implementation CoreDataFetchDataSource

-(id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                       collectionView:(UICollectionView *)collectionView
                       cellIdentifier:(NSString *)cellIdentifier {
    NSParameterAssert(collectionView);

    self = [super init];
    if (self) {
        self.cellIdentifier = cellIdentifier;
        self.collectionView = collectionView;
        self.fetchedResultsController = fetchedResultsController;
        self.fetchedResultsController.delegate = self;
    }
    return self;
}

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
                            tableView:(UITableView *)tableView
                       cellIdentifier:(NSString*)cellIdentifier {
    NSParameterAssert(tableView);

    self = [super init];
    if (self) {
        self.cellIdentifier = cellIdentifier;
        self.fetchedResultsController = fetchedResultsController;
        self.fetchedResultsController.delegate = self;
        self.tableView = tableView;
    }
    return self;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

-(void)performFetch {
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

    if (self.collectionView) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.objectChanges = [@[] mutableCopy];
    self.sectionChanges = [@[] mutableCopy];

    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSParameterAssert(self.cellConfigurator);

    NSMutableDictionary* change = [@{} mutableCopy];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;

            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;

            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            self.cellConfigurator([self.collectionView cellForItemAtIndexPath:indexPath], indexPath);

            self.cellConfigurator([self.tableView cellForRowAtIndexPath:indexPath], indexPath);
            break;
            
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[ indexPath, newIndexPath ];

            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }

    [self.objectChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary* change = [@{} mutableCopy];

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);

            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);

            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }

    [self.sectionChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary* change in self.sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber* type, NSNumber* sectionIndex, BOOL *s) {
                NSIndexSet* set = [NSIndexSet indexSetWithIndex:sectionIndex.unsignedIntegerValue];

                switch ((NSFetchedResultsChangeType)type.integerValue) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:set];
                        break;

                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:set];
                        break;

                    case NSFetchedResultsChangeMove:
                    case NSFetchedResultsChangeUpdate:
                        break;
                }
            }];
        }

        for (NSDictionary* change in self.objectChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber* type, id change, BOOL *stop) {
                switch ((NSFetchedResultsChangeType)type.integerValue) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[ change ]];
                        break;

                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[ change ]];
                        break;

                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:((NSIndexPath*)change).section]];
                        break;

                    case NSFetchedResultsChangeMove:
                        [self.collectionView deleteItemsAtIndexPaths:@[ change[0] ]];
                        [self.collectionView insertItemsAtIndexPaths:@[ change[1] ]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.objectChanges = nil;
        self.sectionChanges = nil;
    }];

    NSMutableArray* sectionWasReloaded = [@[] mutableCopy];
    for (int i = 0; i < self.fetchedResultsController.sections.count; i++) {
        [sectionWasReloaded addObject:@(NO)];
    }

    for (NSDictionary* change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber* type, id change, BOOL *stop) {
            NSIndexPath* indexPath = (NSIndexPath*)change;

            switch ((NSFetchedResultsChangeType)type.integerValue) {
                case NSFetchedResultsChangeUpdate:
                    if (!sectionWasReloaded[indexPath.section]) {
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                        sectionWasReloaded[indexPath.section] = @YES;
                    }
                    break;

                default:
                    break;
            }
        }];
    }

    [self.tableView endUpdates];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)ip {
    NSParameterAssert(self.cellConfigurator);

    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                               forIndexPath:ip];
    self.cellConfigurator(cell, ip);
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(self.cellConfigurator);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    self.cellConfigurator(cell, indexPath);
    return cell;
}

@end
