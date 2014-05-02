//
//  CDASpaceSelectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDASpaceViewController.h"
#import "CDATextEntryCell.h"
#import "CDASpaceSelectionViewController.h"
#import "UIApplication+Browser.h"

static NSString* const CDAAccessTokenKey    = @"CDAAccessTokenKey";
static NSString* const CDASpaceKey          = @"CDASpaceKey";
static NSString* const CDALogoAnimationKey  = @"SpinLogo";

@interface CDASpaceSelectionViewController () <CDAEntriesViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) BOOL done;
@property (nonatomic) UIButton* loadButton;
@property (nonatomic) UIImageView* logoView;

@end

#pragma mark -

@implementation CDASpaceSelectionViewController

- (BOOL)done
{
    return [self textFieldAtRow:0].text.length > 0 && [self textFieldAtRow:1].text.length > 0;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Space selection", nil);
        
        [self.tableView registerClass:[CDATextEntryCell class]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

- (UITextField*)textFieldAtRow:(NSInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:1];
    CDATextEntryCell* cell = (CDATextEntryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    return cell.textField;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSpinningLogo];
}

#pragma mark - Actions

- (void)loadSpaceTapped
{
    NSString* spaceKey = [self textFieldAtRow:0].text;
    NSString* accessToken = [self textFieldAtRow:1].text;
    
    [[NSUserDefaults standardUserDefaults] setValue:spaceKey forKey:CDASpaceKey];
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:CDAAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:spaceKey accessToken:accessToken];
    [UIApplication sharedApplication].client = client;
    
    CDASpaceViewController* spaceVC = [CDASpaceViewController new];
    [self presentViewController:spaceVC animated:YES completion:nil];
    
    [self startSpinningLogo];
}

- (void)textFieldChanged
{
    self.loadButton.enabled = self.done;
}

#pragma mark - Animations

- (void)startSpinningLogo
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 1.1;
    rotation.repeatCount = INT_MAX;
    
    [self.logoView.layer addAnimation:rotation forKey:CDALogoAnimationKey];
}

- (void)stopSpinningLogo
{
    [self.logoView.layer removeAnimationForKey:CDALogoAnimationKey];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDATextEntryCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                         forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDASpaceKey];
            cell.textLabel.text = NSLocalizedString(@"Space", nil);
            break;
        case 1:
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDAAccessTokenKey];
            cell.textLabel.text = NSLocalizedString(@"Access Token", nil);
            break;
    }
    
    cell.textField.delegate = self;
    
    [cell.textField addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 1 ? 64.0 : UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 240.0 : UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 0 : 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Enter access information", nil);
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 64.0)];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10.0, 10.0, view.frame.size.width - 20.0, view.frame.size.height - 20.0);
    
    [button addTarget:self action:@selector(loadSpaceTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Load Space", nil) forState:UIControlStateNormal];
    
    self.loadButton = button;
    self.loadButton.enabled = self.done;
    
    [view addSubview:button];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoView.frame = CGRectMake(0.0, 40.0, tableView.frame.size.width, 200.0);
        [containerView addSubview:self.logoView];
        
        return containerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self textFieldAtRow:indexPath.row] becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.done) {
        [self loadSpaceTapped];
        return NO;
    }
    
    return YES;
}

@end
