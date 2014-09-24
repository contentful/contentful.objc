//
//  CDALocationViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

@import MapKit;

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

-(void)adjustMapRectToAnnotations {
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

-(void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    
    [self.mapView setCenterCoordinate:location];
    [self.mapView addAnnotation:[CDALocationAnnotation annotationWithLocation:location]];
    [self adjustMapRectToAnnotations];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    [self setLocation:self.location];
}

@end
