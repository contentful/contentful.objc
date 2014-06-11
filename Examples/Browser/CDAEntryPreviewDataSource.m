//
//  CDAEntryPreviewDataSource.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDAAssetPreviewCell.h"
#import "CDAAssetPreviewController.h"
#import "CDAAssetThumbnailOperation.h"
#import "CDAEntryPreviewDataSource.h"
#import "CDAEntryPreviewController.h"
#import "CDAInlineMapCell.h"
#import "CDAMarkdownCell.h"
#import "CDAPrimitiveCell.h"

NSString* const kAssetCell       = @"AssetCell";
NSString* const kItemCell        = @"ItemCell";
NSString* const kMapCell         = @"MapCell";
NSString* const kPrimitiveCell   = @"PrimitiveCell";
NSString* const kTextCell        = @"TextCell";

@interface CDAEntryPreviewDataSource ()

@property (nonatomic) NSMutableDictionary* customCellSizes;
@property (nonatomic, weak) CDAEntry* entry;
@property (nonatomic) NSOperationQueue* thumbnailQueue;

@end

#pragma mark -

@implementation CDAEntryPreviewDataSource

-(UITableViewCell*)buildItemCellForTableView:(UITableView*)tableView withValue:(id)value {
    if ([value isKindOfClass:[CDAAsset class]]) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAssetCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        
        CDAAsset* asset = (CDAAsset*)value;
        
        if (asset.isImage) {
            [cell.imageView cda_setImageWithAsset:asset];
        } else {
            CGSize thumbSize = CGSizeMake(cell.frame.size.width, cell.frame.size.width * 1.25);
            CDAAssetThumbnailOperation* thumbOperation = [[CDAAssetThumbnailOperation alloc]
                                                          initWithAsset:asset
                                                          thumbnailSize:thumbSize];
            
            __weak typeof(thumbOperation) weakOperation = thumbOperation;
            thumbOperation.completionBlock = ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    cell.imageView.image = weakOperation.snapshot;
                    NSCAssert(cell.imageView.image, @"Snapshot should not be nil.");
                });
            };
            
            [self.thumbnailQueue addOperation:thumbOperation];
        }
        
        [cell setNeedsLayout];
        return cell;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kItemCell];
    
    if ([value isKindOfClass:[CDAEntry class]]) {
        CDAEntry* entry = (CDAEntry*)value;
        
        if (entry.contentType.displayField) {
            cell.textLabel.text = entry.fields[entry.contentType.displayField];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        NSAssert(!value || [value isKindOfClass:[NSString class]], @"Symbol array expected.");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = value;
    }
    
    return cell;
}

-(CDAField*)fieldForSection:(NSInteger)section {
    return self.entry.contentType.fields[section];
}

-(id)initWithEntry:(CDAEntry*)entry {
    self = [super init];
    if (self) {
        self.customCellSizes = [@{} mutableCopy];
        self.entry = entry;
        self.thumbnailQueue = [NSOperationQueue new];
        self.thumbnailQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

-(id)valueForIndexPath:(NSIndexPath*)indexPath {
    CDAField* field = [self fieldForSection:indexPath.section];
    id value = [self valueForSection:indexPath.section];
    return field.type == CDAFieldTypeArray ? [value objectAtIndex:indexPath.row] : value;
}

-(id)valueForSection:(NSInteger)section {
    CDAField* field = [self fieldForSection:section];
    return self.entry.fields[field.identifier];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.entry.fields.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    CDAField* field = [self fieldForSection:indexPath.section];
    id value = [self valueForIndexPath:indexPath];
    
    switch (field.type) {
        case CDAFieldTypeArray:
        case CDAFieldTypeLink:
            cell = [self buildItemCellForTableView:tableView withValue:value];
            break;
            
        case CDAFieldTypeLocation:
            cell = [tableView dequeueReusableCellWithIdentifier:kMapCell forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [(CDAInlineMapCell*)cell addAnnotationWithTitle:field.name location:[self.entry CLLocationCoordinate2DFromFieldWithIdentifier:field.identifier]];
            break;
            
        case CDAFieldTypeObject:
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText: {
            cell = [tableView dequeueReusableCellWithIdentifier:kTextCell];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (field.type == CDAFieldTypeObject) {
                [(CDAMarkdownCell*)cell textView].text = [value description];
            } else {
                [(CDAMarkdownCell*)cell setMarkdownText:value];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC),
                           dispatch_get_main_queue(),
                           ^{
                               CGFloat height = [(CDAMarkdownCell*)cell textView].contentSize.height;
                               self.customCellSizes[indexPath] = @(height);
                               
                               [tableView beginUpdates];
                               [tableView endUpdates];
                           });
            
            break;
        }
            
        default: {
            cell = [tableView dequeueReusableCellWithIdentifier:kPrimitiveCell];
            
            switch (field.type) {
                case CDAFieldTypeBoolean:
                    value = [value boolValue] ? NSLocalizedString(@"yes", nil) : NSLocalizedString(@"no", nil);
                    break;
                    
                case CDAFieldTypeDate:
                    value = [NSDateFormatter localizedStringFromDate:value
                                                           dateStyle:NSDateFormatterMediumStyle
                                                           timeStyle:NSDateFormatterShortStyle];
                    break;
                    
                default:
                    break;
            }
            
            cell.detailTextLabel.text = [value isKindOfClass:[NSString class]] ? value : [value description];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = field.name;
            break;
        }
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id value = [self valueForSection:section];
    return [self fieldForSection:section].type == CDAFieldTypeArray ? [value count] : 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CDAField* field = [self fieldForSection:section];
    
    switch (field.type) {
        case CDAFieldTypeArray:
        case CDAFieldTypeLink:
            return field.name;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id value = [self valueForIndexPath:indexPath];
    
    if ([value isKindOfClass:[CDAAsset class]]) {
        CDAAsset* asset = (CDAAsset*)value;
        if (!asset.isImage) {
            CDAAssetPreviewController* assetPreview = [[CDAAssetPreviewController alloc]
                                                       initWithAsset:asset];
            UINavigationController* navController = [(UIViewController*)[tableView nextResponder] navigationController];
            [navController pushViewController:assetPreview animated:YES];
        }
    }
    
    if ([value isKindOfClass:[CDAEntry class]]) {
        CDAEntry* entry = (CDAEntry*)value;
        CDAEntryPreviewController* entryPreview = [[CDAEntryPreviewController alloc] initWithEntry:entry];
        UINavigationController* navController = [(UIViewController*)[tableView nextResponder] navigationController];
        [navController pushViewController:entryPreview animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CDAField* field = [self fieldForSection:section];
    if (field.type == CDAFieldTypeArray || field.type == CDAFieldTypeLink) {
        return 10.0;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [(id)[tableView nextResponder] tableView:tableView heightForHeaderInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* customHeight = self.customCellSizes[indexPath];
    if (customHeight) {
        return [customHeight floatValue];
    }
    
    CDAField* field = [self fieldForSection:indexPath.section];
    id value = [self valueForIndexPath:indexPath];
    
    if ([@[ @(CDAFieldTypeObject), @(CDAFieldTypeText), @(CDAFieldTypeSymbol) ] containsObject:@(field.type)]) {
        value = [value isKindOfClass:[NSString class]] ? value : [value description];
        return [(NSString*)value boundingRectWithSize:CGSizeMake(tableView.frame.size.width, INT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName: [CDAMarkdownCell usedFont] }
                                              context:nil].size.height;
    }
    
    if (field.type == CDAFieldTypeLocation) {
        return tableView.frame.size.width;
    }
    
    if ([value isKindOfClass:[CDAAsset class]]) {
        CDAAsset* asset = (CDAAsset*)value;
        
        if (asset.isImage) {
            if (asset.size.width < tableView.frame.size.width) {
                return asset.size.height;
            }
            
            return (tableView.frame.size.width - 20.0) / asset.size.width * asset.size.height;
        }
        
        return tableView.frame.size.width * 1.25;
    }
    
    return UITableViewAutomaticDimension;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [(id)[tableView nextResponder] tableView:tableView viewForHeaderInSection:section];
}

@end
