//
//  CDAEntryPreviewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDAAssetPreviewCell.h"
#import "CDAEntryPreviewController.h"
#import "CDAMarkdownCell.h"
#import "CDAPrimitiveCell.h"

static NSString* const kAssetCell       = @"AssetCell";
static NSString* const kItemCell        = @"ItemCell";
static NSString* const kMapCell         = @"MapCell";
static NSString* const kPrimitiveCell   = @"PrimitiveCell";
static NSString* const kTextCell        = @"TextCell";

@interface CDAEntryPreviewController ()

@property (nonatomic) NSMutableDictionary* customCellSizes;
@property (nonatomic) CDAEntry* entry;

@end

#pragma mark -

@implementation CDAEntryPreviewController

-(UITableViewCell*)buildItemCellForTableView:(UITableView*)tableView withValue:(id)value {
    if ([value isKindOfClass:[CDAAsset class]]) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAssetCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.imageView cda_setImageWithAsset:(CDAAsset*)value];
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
        NSAssert([value isKindOfClass:[NSString class]], @"Symbol array expected.");
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
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.customCellSizes = [@{} mutableCopy];
        self.entry = entry;
        
        [self.tableView registerClass:[CDAAssetPreviewCell class] forCellReuseIdentifier:kAssetCell];
        [self.tableView registerClass:NSClassFromString(@"CDAResourceTableViewCell")
               forCellReuseIdentifier:kItemCell];
        [self.tableView registerClass:[CDAInlineMapCell class] forCellReuseIdentifier:kMapCell];
        [self.tableView registerClass:[CDAPrimitiveCell class] forCellReuseIdentifier:kPrimitiveCell];
        [self.tableView registerClass:[CDAMarkdownCell class] forCellReuseIdentifier:kTextCell];
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
            
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText: {
            cell = [tableView dequeueReusableCellWithIdentifier:kTextCell];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [(CDAMarkdownCell*)cell setMarkdownText:value];
            
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
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:kPrimitiveCell];
            cell.detailTextLabel.text = [value isKindOfClass:[NSString class]] ? value : [value description];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = field.name;
            break;
    }
    
    return cell;
    
    // TODO: Asset preview cell (test with PDF and .docx)
    // TODO: Locations
    // TODO: Date time -> localized formatting?
    // TODO: JSON Objects
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CDAField* field = [self fieldForSection:section];
    if (field.type == CDAFieldTypeArray || field.type == CDAFieldTypeLink) {
        return 44.0;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* customHeight = self.customCellSizes[indexPath];
    if (customHeight) {
        return [customHeight floatValue];
    }
    
    CDAField* field = [self fieldForSection:indexPath.section];
    id value = [self valueForIndexPath:indexPath];
    
    if (field.type == CDAFieldTypeSymbol || field.type == CDAFieldTypeText) {
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

@end
