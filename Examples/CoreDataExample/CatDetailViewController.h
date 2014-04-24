//
//  CatDetailViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import <UIKit/UIKit.h>

@class CDAClient;
@class ManagedCat;

@interface CatDetailViewController : UIViewController

@property (nonatomic) CDAClient* client;

-(id)initWithCat:(ManagedCat*)cat;

@end
