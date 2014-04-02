//
//  CDASimpleMapViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import "CDASimpleMapViewController.h"

@interface CDASimpleMapViewController ()

@property (nonatomic) CDAClient* client;

@end

#pragma mark -

@implementation CDASimpleMapViewController

-(id)init {
    self = [super init];
    if (self) {
        self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
        self.coordinateFieldIdentifier = @"location";
        self.query = @{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" };
        self.titleFieldIdentifier = @"locationName";
    }
    return self;
}

@end
