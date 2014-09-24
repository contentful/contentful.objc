//
//  CDAFieldCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

@import MapKit;

#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDAField.h>

#import "CDAFieldCell.h"

@implementation CDAFieldCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

-(void)setField:(CDAField *)field {
    if (_field == field) {
        return;
    }
    _field = field;
    
    self.textLabel.text = field.name;
}

-(void)setValue:(id)value {
    if (_value == value) {
        return;
    }
    _value = value;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (self.field.type) {
        case CDAFieldTypeArray:
            self.detailTextLabel.text = [@([value count]) stringValue];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
            return;
            
        case CDAFieldTypeLink:
        case CDAFieldTypeObject:
            if (_value) {
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            return;
        
        case CDAFieldTypeBoolean:
            self.detailTextLabel.text = [value boolValue] ? NSLocalizedString(@"yes", nil) : NSLocalizedString(@"no", nil);
            return;
            
        case CDAFieldTypeDate:
            self.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
            return;
            
        case CDAFieldTypeLocation: {
            CLLocationCoordinate2D coordinate;
            [value getBytes:&coordinate length:sizeof(coordinate)];
            self.detailTextLabel.text = [NSString stringWithFormat:@"(%2.f, %.2f)",
                                         coordinate.latitude,
                                         coordinate.longitude];
            
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
            return;
        }
            
        case CDAFieldTypeInteger:
        case CDAFieldTypeNumber:
            self.detailTextLabel.text = [value stringValue];
            return;
            
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            self.detailTextLabel.text = value;
            
            if (self.detailTextLabel.text.length > 25) {
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            return;
            
        case CDAFieldTypeAsset:
        case CDAFieldTypeEntry:
        case CDAFieldTypeNone:
            return;
    }
    
    NSAssert(false, @"Unhandled field type %ld", (long)self.field.type);
}

@end
