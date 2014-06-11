//
//  CDAAboutUsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/05/14.
//
//

#import "CDAAboutUsViewController.h"
#import "UILabel+Alignment.h"

@interface CDAAboutUsViewController ()

@property (nonatomic) CGFloat emptySpaceHeight;
@property (nonatomic) UILabel* versionLabel;

@end

#pragma mark -

@implementation CDAAboutUsViewController

-(CGFloat)emptySpaceHeight {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1
                                                inSection:0];
    CGRect lastRowFrame = [self.tableView rectForRowAtIndexPath:indexPath];
    return self.tableView.frame.size.height - (lastRowFrame.origin.y +
                                               lastRowFrame.size.height);
}

-(id)init {
    self = [super init];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"about"];
        self.title = NSLocalizedString(@"About Us", nil);
        
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"FAQ", nil);
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Send feedback", nil);
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Contact us", nil);
            break;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return 100.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* urlString = nil;
    
    switch (indexPath.row) {
        case 0:
            urlString = @"https://support.contentful.com/hc/en-us/?utm_source=Discovery%20app&utm_medium=iOS&utm_campaign=faq";
            break;
        case 1:
            urlString = @"https://support.contentful.com/hc/en-us/requests/new/?utm_source=Discovery%20app&utm_medium=iOS&utm_campaign=feedback";
            break;
        case 2:
            urlString = @"mailto:voice%40contentful.com?subject=Question%20about%20Contentful&body=%0A%0A%2F%2F%20sent%20via%20the%20Discovery%20app";
            break;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    [self.versionLabel performSelector:@selector(cda_alignBottom) withObject:nil afterDelay:0.1];
    return self.emptySpaceHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel* versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                               tableView.frame.size.width,
                                                               self.emptySpaceHeight)];
    
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"App version %@", nil),
                  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    
    return versionLabel;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                  tableView.frame.size.width, 100.0)];
    
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.frame = CGRectMake((headerView.frame.size.width - 70.0) / 2, 10.0, 70.0, 70.0);
    [headerView addSubview:logo];
    
    UILabel* companyName = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(logo.frame),
                                                                     headerView.frame.size.width, 20.0)];
    companyName.text = @"Contentful GmbH";
    companyName.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:companyName];
    
    return headerView;
}

@end
