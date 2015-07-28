//
//  DocumentListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>

#import "Asset.h"
#import "CoreDataFetchDataSource.h"
#import "CoreDataManager+SeedDB.h"
#import "Document.h"
#import "DocumentListViewController.h"
#import "DocumentTableViewCell.h"
#import "WebViewController.h"

@interface DocumentListViewController ()

@property (nonatomic, readonly) CoreDataFetchDataSource* dataSource;

@end

#pragma mark -

@implementation DocumentListViewController

@synthesize dataSource = _dataSource;

#pragma mark -

-(CoreDataFetchDataSource *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    
    NSFetchRequest* fetchRequest = [[CoreDataManager sharedManager] fetchRequestForEntriesOfContentTypeWithIdentifier:@"1sBoLkeKjGmSeqOysqAICc" matchingPredicate:nil];
    [fetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] ]];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[CoreDataManager sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _dataSource = [[CoreDataFetchDataSource alloc] initWithFetchedResultsController:controller
                                                                          tableView:self.tableView
                                                                     cellIdentifier:NSStringFromClass([self class])];
    
    __weak DocumentListViewController* welf = self;
    _dataSource.cellConfigurator = ^(UITableViewCell* cell, NSIndexPath* indexPath) {
        Document* doc = [welf.dataSource objectAtIndexPath:indexPath];
        cell.detailTextLabel.text = doc.abstract;
        cell.textLabel.text = doc.title;

        NSData* data = [CDAAsset cachedDataForPersistedAsset:doc.thumbnail client:[CoreDataManager sharedManager].client];
        if (data) {
            cell.imageView.image = [UIImage imageWithData:data];
        }
    };
    
    return _dataSource;
}

-(id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dogements", nil);
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    
    [self.tableView registerClass:[DocumentTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([self class])];
    
    [[CoreDataManager sharedManager] performSynchronizationWithSuccess:^{
        [self.dataSource performFetch];
    } failure:^(CDAResponse *response, NSError *error) {
        // For brevity's sake, we do not check the cause of the error, but a real app should.
        [self.dataSource performFetch];
    }];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Document* doc = [self.dataSource objectAtIndexPath:indexPath];
    WebViewController* controller = [WebViewController new];
    controller.title = doc.title;
    [controller loadData:[CDAAsset cachedDataForPersistedAsset:doc.document
                                                        client:[CoreDataManager sharedManager].client]
                MIMEType:@"application/pdf"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
