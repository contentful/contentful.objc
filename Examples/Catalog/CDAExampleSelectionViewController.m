//
//  CDAExampleSelectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import "CDAExampleSelectionViewController.h"

@interface CDAExampleSelectionViewController ()

@property (nonatomic) NSDictionary* examples;

@end

#pragma mark -

@implementation CDAExampleSelectionViewController

- (NSString*)exampleKeyAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.examples.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)][indexPath.row];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.examples = @{
                          @"Image gallery": NSClassFromString(@"CDAImageGalleryViewController"),
                          @"Loading assets": NSClassFromString(@"CDALoadAssetsViewController"),
                          @"Showing a map": NSClassFromString(@"CDASimpleMapViewController"),
                          };
        self.title = NSLocalizedString(@"Examples", nil);
        
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [self exampleKeyAtIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.examples.allKeys.count;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class viewControllerClass = self.examples[[self exampleKeyAtIndexPath:indexPath]];
    UIViewController* viewController = [viewControllerClass new];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
