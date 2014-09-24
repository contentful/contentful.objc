//
//  UFOSighting.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "UFOSighting.h"

@implementation UFOSighting

-(CLLocationCoordinate2D)coordinate {
    return [self CLLocationCoordinate2DFromFieldWithIdentifier:@"location"];
}

-(void)setSightingDescription:(NSString *)sightingDescription {
}

-(NSString *)sightingDescription {
    return self.fields[@"description"];
}

-(NSString *)title {
    return self.fields[@"locationName"];
}

@end
