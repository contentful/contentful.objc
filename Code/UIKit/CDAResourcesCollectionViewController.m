//
//  CDAResourcesCollectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAResourceCell.h>
#import <ContentfulDeliveryAPI/CDAResourcesCollectionViewController.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDAUtilities.h"

@interface CDAResourcesCollectionViewController () <UISearchBarDelegate>

@property (nonatomic, readonly) NSString* cacheFileName;
@property (nonatomic) NSDictionary* cellMapping;
@property (nonatomic) CDAArray* resources;
@property (nonatomic) UISearchBar* searchBar;

@end

#pragma mark -

@implementation CDAResourcesCollectionViewController

+(Class)cellClass {
    return [CDAResourceCell class];
}

#pragma mark -

-(NSString *)cacheFileName {
    return CDACacheFileNameForQuery(self.client, self.resourceType, self.query);
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
        
        self.collectionView.alwaysBounceVertical = YES;

        if ([self.collectionView respondsToSelector:@selector(keyboardDismissMode)]) {
            [self.collectionView setValue:@(UIScrollViewKeyboardDismissModeOnDrag)
                                   forKey:@"keyboardDismissMode"];
        }
        
        [self.collectionView registerClass:[[self class] cellClass]
                forCellWithReuseIdentifier:NSStringFromClass([self class])];
        
        [self.collectionView registerClass:[UICollectionReusableView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(NSArray *)items {
    return self.resources.items;
}

-(void)performQuery:(NSDictionary*)query {
    NSAssert(self.client, @"You need to supply a client instance to %@.",
             NSStringFromClass([self class]));
    
    [self.client fetchResourcesOfType:self.resourceType
                             matching:query
                              success:^(CDAResponse *response, CDAArray *array) {
                                  self.resources = array;
                                  
                                  [self.collectionView reloadData];
                                  
                                  [self handleCaching];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  CDAClient* client = self.client;
                                  NSParameterAssert(client);

                                  if (CDAIsNoNetworkError(error) && client) {
                                      self.resources = [CDAArray readFromFile:self.cacheFileName
                                                                       client:client];
                                      
                                      [self.collectionView reloadData];
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
                                                                       self.view.frame.size.width,
                                                                       44.0)];
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
    } else {
        self.searchBar = nil;
    }
    
    _showSearchBar = showSearchBar;
    
    [self.collectionView reloadData];
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
    
    self.resources = nil;
	[self.collectionView reloadData];
    
    [self performQuery:self.query];
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }
    
    CDAResourceCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class])
                                                                      forIndexPath:indexPath];
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

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader && self.searchBar) {
        UICollectionReusableView* container = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
        [container addSubview:self.searchBar];
        
        if (self.searchBar.text.length == 0) {
            [collectionView setContentOffset:CGPointMake(0.0, -10.0)];
        }
        
        return container;
    }
    
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.items.count : 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UISearchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [self.view endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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

@end
