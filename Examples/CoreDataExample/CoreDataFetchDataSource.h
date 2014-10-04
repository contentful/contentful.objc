//
//  CoreDataFetchDataSource.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

@import CoreData;
@import UIKit;

typedef void(^CDAConfigureCellAtIndexPath)(UITableViewCell* cell, NSIndexPath* indexPath);

@interface CoreDataFetchDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) CDAConfigureCellAtIndexPath cellConfigurator;

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
                            tableView:(UITableView*)tableView
                       cellIdentifier:(NSString*)cellIdentifier;
-(id)objectAtIndexPath:(NSIndexPath*)indexPath;
-(void)performFetch;

@end
