//
//  CDAFieldsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDAField.h>

#import "CDAFieldCell.h"
#import "CDAFieldsViewController.h"
#import "CDALocationViewController.h"
#import "CDATextViewController.h"

@interface CDAFieldsViewController ()

@property (nonatomic) CDAEntry* entry;
@property (nonatomic) NSArray* fields;

@end

#pragma mark -

@implementation CDAFieldsViewController

+(Class)cellClass {
    return [CDAFieldCell class];
}

#pragma mark -

-(void)didSelectRowWithValue:(id)value forField:(CDAField *)field {
    if (field.type == CDAFieldTypeLink && [value fetched]) {
        CDAFieldsViewController* linkedFieldsVC = [[CDAFieldsViewController alloc] initWithEntry:value];
        [self.navigationController pushViewController:linkedFieldsVC animated:YES];
    }
}

-(id)initWithEntry:(CDAEntry*)entry {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.entry = entry;
        self.title = entry.fields[entry.contentType.displayField];
        
        self.fields = [self.entry.fields.allKeys
                       sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        if (self.visibleFields) {
            NSMutableArray* fields = [@[] mutableCopy];
            
            for (NSString* field in self.visibleFields) {
                if ([self.fields containsObject:field]) {
                    [fields addObject:field];
                }
            }
            
            self.fields = [fields copy];
        }
        
        [self.tableView registerClass:[[self class] cellClass]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(void)showError:(NSError*)error {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

-(NSArray*)visibleFields {
    return nil;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }
    
    NSString* fieldIdentifier = self.fields[indexPath.row];
    
    CDAFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                         forIndexPath:indexPath];
    cell.field = [self.entry.contentType fieldForIdentifier:fieldIdentifier];
    cell.value = self.entry.fields[fieldIdentifier];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.fields.count : 0;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    
    CDAFieldCell* cell = (CDAFieldCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    switch (cell.field.type) {
        case CDAFieldTypeArray:
        case CDAFieldTypeLink:
            [self didSelectRowWithValue:cell.value forField:cell.field];
            break;
            
        case CDAFieldTypeLocation: {
            CDALocationViewController* locationViewController = [CDALocationViewController new];
            locationViewController.location = [self.entry CLLocationCoordinate2DFromFieldWithIdentifier:cell.field.identifier];
            locationViewController.title = cell.field.name;
            [self.navigationController pushViewController:locationViewController animated:YES];
            break;
        }
            
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            if (cell.detailTextLabel.text.length > 25) {
                CDATextViewController* textViewController = [CDATextViewController new];
                textViewController.text = cell.value;
                textViewController.title = cell.field.name;
                [self.navigationController pushViewController:textViewController animated:YES];
            }
            break;
            
        default:
            break;
    }
}

@end
