//
//  CDASyncDemoViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import "CDASyncDemoViewController.h"

@interface CDASyncDemoViewController ()

@property (nonatomic) CDAClient* contentfulClient;
@property (nonatomic) CDASyncedSpace* syncedSpace;

@end

#pragma mark -

@implementation CDASyncDemoViewController

-(id)init {
    self = [super initWithCellMapping:@{ @"textLabel.text": @"fields.name" } items:@[ ]];
    if (self) {
        self.contentfulClient = [CDAClient new];
        self.client = self.contentfulClient;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTapped)];
    }
    return self;
}

-(NSArray *)items {
    return self.syncedSpace.entries;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        self.syncedSpace = space;
        
        [self.tableView reloadData];
    } failure:^(CDAResponse *response, NSError *error) {
        [self showError:error];
    }];
}

#pragma mark - Actions

-(void)refreshTapped {
    [self.syncedSpace performSynchronizationWithSuccess:^{
        [self.tableView reloadData];
    } failure:^(CDAResponse *response, NSError *error) {
        [self showError:error];
    }];
}

@end
