//
//  CDAInlineMapCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import <MapKit/MapKit.h>

#import "CDAInlineMapCell.h"

@interface CDAInlineMapCell ()

@end

#pragma mark -

@implementation CDAInlineMapCell

- (void)addAnnotationWithTitle:(NSString *)title location:(CLLocationCoordinate2D)location {
    MKMapSnapshotOptions* options = [MKMapSnapshotOptions new];
    options.region = MKCoordinateRegionMakeWithDistance(location, 250.0, 250.0);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(self.bounds.size.width - 20.0, self.bounds.size.height);
    
    UIImageView* pin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin"]];
    pin.frame = CGRectMake((options.size.width - pin.image.size.width)  / 2,
                           options.size.height / 2 - pin.image.size.height,
                           pin.image.size.width,
                           pin.image.size.height);
    pin.hidden = YES;
    [self.imageView addSubview:pin];
    
    MKMapSnapshotter* snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        self.imageView.image = snapshot.image;
        pin.hidden = NO;
    }];
}

@end
