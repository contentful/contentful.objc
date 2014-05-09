//
//  CDAEntryPreviewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import "CDAAssetPreviewCell.h"
#import "CDAEntryPreviewController.h"
#import "CDAEntryPreviewDataSource.h"
#import "CDAInlineMapCell.h"
#import "CDAMarkdownCell.h"
#import "CDAPrimitiveCell.h"
#import "UIApplication+Browser.h"

@interface CDAEntryPreviewController ()

@property (nonatomic) CDAEntryPreviewDataSource* dataSource;

@end

#pragma mark -

@implementation CDAEntryPreviewController

-(CDAClient*)client {
    return [UIApplication sharedApplication].client;
}

-(id)initWithEntry:(CDAEntry*)entry {
    self = [super initWithEntry:entry tableViewStyle:UITableViewStylePlain];
    if (self) {
        self.dataSource = [[CDAEntryPreviewDataSource alloc] initWithEntry:entry];
        
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate = self.dataSource;
        
        [self.tableView registerClass:[CDAAssetPreviewCell class] forCellReuseIdentifier:kAssetCell];
        [self.tableView registerClass:NSClassFromString(@"CDAResourceTableViewCell")
               forCellReuseIdentifier:kItemCell];
        [self.tableView registerClass:[CDAInlineMapCell class] forCellReuseIdentifier:kMapCell];
        [self.tableView registerClass:[CDAPrimitiveCell class] forCellReuseIdentifier:kPrimitiveCell];
        [self.tableView registerClass:[CDAMarkdownCell class] forCellReuseIdentifier:kTextCell];
    }
    return self;
}

#pragma mark - Actions

-(void)displayTypeChanged:(UISegmentedControl*)segmentedControl {
    UIView* snapshotView = [self.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = self.view.bounds;
    
    if (segmentedControl.selectedSegmentIndex == 1) {
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate = self.dataSource;
    } else {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    [self.tableView reloadData];
    [self.view addSubview:snapshotView];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         snapshotView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [snapshotView removeFromSuperview];
                         
                         [self.tableView setContentOffset:CGPointMake(0.0, -60.0) animated:NO];
                     }];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 60.0 : UITableViewAutomaticDimension;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return nil;
    }
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                  tableView.frame.size.width, 60.0)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UISegmentedControl* displayTypeSelection = [[UISegmentedControl alloc]
                                                initWithItems:@[ @"List", @"Preview" ]];
    
    displayTypeSelection.frame = CGRectMake((headerView.frame.size.width - 250.0) / 2, 10.0,
                                            250.0, displayTypeSelection.frame.size.height);
    displayTypeSelection.selectedSegmentIndex = tableView.numberOfSections == 1 ? 0 : 1;
    
    [displayTypeSelection addTarget:self
                             action:@selector(displayTypeChanged:)
                   forControlEvents:UIControlEventValueChanged];
    
    [headerView addSubview:displayTypeSelection];
    
    return headerView;
}

@end
