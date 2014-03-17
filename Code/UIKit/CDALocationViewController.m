//
//  CDALocationViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import <MapKit/MapKit.h>

#import "CDALocationViewController.h"

@interface CDALocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D location;

@end

#pragma mark -

@implementation CDALocationAnnotation

+(instancetype)annotationWithLocation:(CLLocationCoordinate2D)location {
    CDALocationAnnotation* annotation = [[self class] new];
    annotation.location = location;
    return annotation;
}

-(CLLocationCoordinate2D)coordinate {
    return self.location;
}

@end

#pragma mark -

@interface CDALocationViewController ()

@property (nonatomic) MKMapView* mapView;

@end

#pragma mark -

@implementation CDALocationViewController

-(void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    
    [self.mapView setCenterCoordinate:location];
    [self.mapView addAnnotation:[CDALocationAnnotation annotationWithLocation:location]];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    [self setLocation:self.location];
}

@end
