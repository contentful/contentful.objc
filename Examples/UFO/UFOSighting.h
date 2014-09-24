//
//  UFOSighting.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import MapKit;

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

@interface UFOSighting : CDAEntry <MKAnnotation>

@property (nonatomic) NSString* sightingDescription;

@end
