//
//  CDAInlineMapCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import <MapKit/MapKit.h>

#import "CDAInlineMapCell.h"

@interface CDAInlineLocation : NSObject<MKAnnotation>

@end

#pragma mark -

@implementation CDAInlineLocation

@synthesize coordinate = _coordinate;
@synthesize title = _title;

-(id)initWithTitle:(NSString*)title location:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        _coordinate = location;
        _title = title;
    }
    return self;
}

@end

#pragma mark -

@interface CDAInlineMapCell ()

@property (nonatomic) MKMapView* mapView;

@end

#pragma mark -

@implementation CDAInlineMapCell

- (void)addAnnotationWithTitle:(NSString *)title location:(CLLocationCoordinate2D)location {
    CDAInlineLocation* inlineLocation = [[CDAInlineLocation alloc] initWithTitle:title location:location];
    [self.mapView addAnnotation:inlineLocation];
    self.mapView.centerCoordinate = location;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location, 250.0, 250.0) animated:NO];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.mapView];
    }
    return self;
}

- (void)layoutSubviews {
    self.mapView.frame = self.bounds;
    [self.contentView bringSubviewToFront:self.mapView];
}

@end
