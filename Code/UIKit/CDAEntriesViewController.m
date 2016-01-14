//
//  CDAEntriesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDAEntriesViewController.h>

@implementation CDAEntriesViewController

-(id)initWithCellMapping:(NSDictionary *)cellMapping {
    self = [super initWithCellMapping:cellMapping];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    [super didSelectRowWithResource:entry];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(entriesViewController:didSelectRowWithEntry:)]) {
        id entry = self.items[indexPath.row];
        if (entry) {
            [self.delegate entriesViewController:self didSelectRowWithEntry:entry];
        }
    }
}

@end
