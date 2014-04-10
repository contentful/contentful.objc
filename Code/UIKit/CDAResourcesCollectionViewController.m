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
#import "CDAUtilities.h"
#import "UIImageView+CDAAsset.h"

@interface CDAResourcesCollectionViewController ()

@property (nonatomic, readonly) NSString* cacheFileName;
@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) CDAArray* resources;

@end

#pragma mark -

@implementation CDAResourcesCollectionViewController

+(Class)cellClass {
    return [CDAResourceCell class];
}

#pragma mark -

-(NSString *)cacheFileName {
    return CDACacheFileNameForQuery(self.resourceType, self.query);
}

-(void)handleCaching {
    if (self.offlineCaching) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.resources writeToFile:self.cacheFileName];
        });
    }
}

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
    
    NSAssert(self.client, @"You need to supply a client instance to %@.",
             NSStringFromClass([self class]));
    
    [self.client fetchResourcesOfType:self.resourceType
                             matching:self.query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.resources = array;
                                  
                                  [self.collectionView reloadData];
                                  
                                  [self handleCaching];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  if (CDAIsNoNetworkError(error)) {
                                      self.resources = [CDAArray readFromFile:self.cacheFileName
                                                                       client:self.client];
                                      
                                      [self.collectionView reloadData];
                                      return;
                                  }
                                  
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
    cell.imageView.offlineCaching_cda = self.offlineCaching;
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
