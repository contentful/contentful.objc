//
//  CDAFieldsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAClient.h>
#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDAField.h>

#import "CDAEntriesViewController.h"
#import "CDAFieldCell.h"
#import "CDAFieldsViewController+Private.h"
#import "CDAImageViewController.h"
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
    switch (field.type) {
        case CDAFieldTypeArray: {
            NSArray* array = (NSArray*)value;
            if (![array isKindOfClass:[NSArray class]]) {
                return;
            }
            
            CDAEntry* entry = [array firstObject];
            if (![entry isKindOfClass:[CDAEntry class]] || !entry.fetched) {
                [self.client resolveLinksFromArray:array
                                           success:^(NSArray *items) {
                                               [self showResourcesFromArray:items withTitle:field.name];
                                           } failure:^(CDAResponse *response, NSError *error) {
                                               [self showError:error];
                                           }];
            } else {
                [self showResourcesFromArray:array withTitle:field.name];
            }
            break;
        }
            
            
        case CDAFieldTypeLink: {
            [value resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
                if ([resource isKindOfClass:[CDAAsset class]]) {
                    CDAImageViewController* imageVC = [CDAImageViewController new];
                    imageVC.asset = (CDAAsset*)resource;
                    imageVC.title = field.name;
                    [self.navigationController pushViewController:imageVC animated:YES];
                }
                
                if ([resource isKindOfClass:[CDAEntry class]]) {
                    CDAFieldsViewController* linkedFieldsVC = [[CDAFieldsViewController alloc]
                                                               initWithEntry:(CDAEntry*)resource];
                    linkedFieldsVC.client = self.client;
                    [self.navigationController pushViewController:linkedFieldsVC animated:YES];
                }
            } failure:^(CDAResponse *response, NSError *error) {
                [self showError:error];
            }];
            break;
        }
            
        case CDAFieldTypeLocation: {
            CDALocationViewController* locationViewController = [CDALocationViewController new];
            locationViewController.location = [self.entry CLLocationCoordinate2DFromFieldWithIdentifier:field.identifier];
            locationViewController.title = field.name;
            [self.navigationController pushViewController:locationViewController animated:YES];
            break;
        }
            
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            if ([value length] > 25) {
                CDATextViewController* textViewController = [CDATextViewController new];
                textViewController.text = value;
                textViewController.title = field.name;
                [self.navigationController pushViewController:textViewController animated:YES];
            }
            break;
            
        case CDAFieldTypeAsset:
        case CDAFieldTypeBoolean:
        case CDAFieldTypeDate:
        case CDAFieldTypeEntry:
        case CDAFieldTypeInteger:
        case CDAFieldTypeNone:
        case CDAFieldTypeNumber:
        case CDAFieldTypeObject:
            break;
    }
}

-(id)initWithEntry:(CDAEntry *)entry {
    self = [self initWithEntry:entry tableViewStyle:UITableViewStyleGrouped];
    return self;
}

-(id)initWithEntry:(CDAEntry*)entry tableViewStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.entry = entry;

        switch ([entry.contentType fieldForIdentifier:entry.contentType.displayField].type) {
            case CDAFieldTypeText:
            case CDAFieldTypeSymbol:
                self.title = entry.fields[entry.contentType.displayField];
                break;

            case CDAFieldTypeInteger:
            case CDAFieldTypeBoolean:
            case CDAFieldTypeNumber:
                self.title = [entry.fields[entry.contentType.displayField] stringValue];
                break;

            case CDAFieldTypeArray:
            case CDAFieldTypeAsset:
            case CDAFieldTypeDate:
            case CDAFieldTypeEntry:
            case CDAFieldTypeLink:
            case CDAFieldTypeLocation:
            case CDAFieldTypeNone:
            case CDAFieldTypeObject:
                break;
        }
        
        NSMutableArray* fields = [@[] mutableCopy];
        
        for (CDAField* field in self.entry.contentType.fields) {
            if (!field.disabled) {
                [fields addObject:field];
            }
        }
        
        self.fields = [fields copy];
        
        if (self.visibleFields) {
            NSMutableArray* fields = [@[] mutableCopy];
            
            for (NSString* visibleField in self.visibleFields) {
                for (CDAField* field in self.fields) {
                    if ([field.identifier isEqualToString:visibleField]) {
                        [fields addObject:field];
                    }
                }
            }
            
            self.fields = [fields copy];
        }
        
        [self.tableView registerClass:[[self class] cellClass]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(void)showResourcesFromArray:(NSArray*)array withTitle:(NSString*)title {
    NSDictionary* cellMapping = nil;
    CDAResource* resource = [array firstObject];
    
    if ([resource isKindOfClass:[CDAAsset class]]) {
        cellMapping = @{ @"textLabel.text": @"fields.title" };
    }
    
    if ([resource isKindOfClass:[CDAEntry class]]) {
        CDAEntry* entry = (CDAEntry*)resource;
        if (entry.contentType.displayField) {
            cellMapping = @{ @"textLabel.text": [@"fields." stringByAppendingString:entry.contentType.displayField] };
        }
    }
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc]
                                           initWithCellMapping:cellMapping items:array];
    
    entriesVC.client = self.client;
    entriesVC.title = title;
    
    [self.navigationController pushViewController:entriesVC animated:YES];
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
    
    NSString* fieldIdentifier = [self.fields[indexPath.row] identifier];
    
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
    [self didSelectRowWithValue:cell.value forField:cell.field];
}

@end
