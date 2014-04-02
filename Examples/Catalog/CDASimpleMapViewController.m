//
//  CDASimpleMapViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import "CDASimpleMapViewController.h"

@interface CDASimpleMapViewController ()

@property (nonatomic) CDAClient* contentfulClient;

@end

#pragma mark -

@implementation CDASimpleMapViewController

-(id)init {
    self = [super init];
    if (self) {
        self.contentfulClient = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
        self.client = self.contentfulClient;
        self.query = @{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" };
        
        self.coordinateFieldIdentifier = @"location";
        self.titleFieldIdentifier = @"locationName";
    }
    return self;
}

@end
