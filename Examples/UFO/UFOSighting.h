//
//  UFOSighting.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <MapKit/MapKit.h>

@interface UFOSighting : CDAEntry <MKAnnotation>

@property (nonatomic) NSString* sightingDescription;

@end
