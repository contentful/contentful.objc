//
//  CDADateQueryViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/04/14.
//
//

#import "CDADateQueryViewController.h"

@interface CDADateQueryViewController ()

@property (nonatomic) CDAClient* contentfulClient;

@end

#pragma mark -

@implementation CDADateQueryViewController

-(id)init {
    self = [super initWithCellMapping:@{ @"textLabel.text": @"fields.name" }];
    if (self) {
        self.contentfulClient = [CDAClient new];
        self.client = self.contentfulClient;
        
        /*
         When querying for dates, you should not use the current date as-is, because it will prevent
         your query for getting cached.
         */
        NSDate* date = [NSDate date];
        self.query = @{ @"content_type": @"cat", @"sys.updatedAt[lt]": date };
        NSLog(@"slowness using %@", date);
        
        /* 
         Better round to the nearest 10 minutes like this before performing your query.
         */
        NSTimeInterval time = round([date timeIntervalSinceReferenceDate] / 600.0) * 600.0;
        date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
        self.query = @{ @"content_type": @"cat", @"sys.updatedAt[lt]": date };
        NSLog(@"caching goodness using %@", date);
    }
    return self;
}

@end
