//
//  CDAResourcesCollectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAResourceCell.h>

#import "CDAResourcesCollectionViewController.h"

@interface CDAResourcesCollectionViewController ()

@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) CDAArray* resources;

@end

#pragma mark -

@implementation CDAResourcesCollectionViewController

+(Class)cellClass {
    return [CDAResourceCell class];
}

#pragma mark -

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
                      cellMapping:(NSDictionary*)cellMapping {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.cellMapping = cellMapping;
        self.resourceType = CDAResourceTypeEntry;
        
        [self.collectionView registerClass:[[self class] cellClass]
                forCellWithReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(NSArray *)items {
    return self.resources.items;
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
    
    NSAssert(self.client, @"You need to supply a client instance to CDAEntriesViewController.");
    
    [self.client fetchResourcesOfType:self.resourceType
                             matching:self.query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.resources = array;
                                  
                                  [self.collectionView reloadData];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  [self showError:error];
                              }];
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }
    
    CDAResourceCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    cell.imageView.image = nil;
    
    CDAResource* resource = self.items[indexPath.row];
    
    [self.cellMapping enumerateKeysAndObjectsUsingBlock:^(NSString* cellKeyPath,
                                                          NSString* entryKeyPath,
                                                          BOOL *stop) {
        [cell setValue:[resource valueForKeyPath:entryKeyPath] forKeyPath:cellKeyPath];
    }];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.items.count : 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

@end
