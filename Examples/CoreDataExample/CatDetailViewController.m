//
//  CatDetailViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import "Asset.h"
#import "CatDetailViewController.h"
#import "ManagedCat.h"
#import "UIImageView+CDAAsset.h"

@interface CatDetailViewController ()

@property (nonatomic) ManagedCat* cat;

@end

#pragma mark -

@implementation CatDetailViewController

-(id)initWithCat:(ManagedCat *)cat {
    self = [super init];
    if (self) {
        self.cat = cat;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = self.cat.name;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0, 60.0, 200.0, 200.0)];
    imageView.offlineCaching_cda = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    if (self.cat.picture) {
        [imageView cda_setImageWithPersistedAsset:self.cat.picture
                                           client:self.client
                                             size:imageView.frame.size
                                 placeholderImage:nil];
    }
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                   CGRectGetMaxY(imageView.frame) + 50.0,
                                                                   self.view.frame.size.width,
                                                                   50.0)];
    nameLabel.font = [UIFont systemFontOfSize:40.0];
    nameLabel.text = self.cat.name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
}

@end
