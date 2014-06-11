//
//  CDASpaceSelectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAboutUsViewController.h"
#import "CDAHelpViewController.h"
#import "CDASpaceViewController.h"
#import "CDATextEntryCell.h"
#import "CDASpaceSelectionViewController.h"
#import "UIApplication+Browser.h"

NSString* const CDAAccessTokenKey    = @"CDAAccessTokenKey";
NSString* const CDASpaceKey          = @"CDASpaceKey";

static NSString* const CDALogoAnimationKey  = @"SpinLogo";

@interface CDASpaceSelectionViewController () <CDAEntriesViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) BOOL done;
@property (nonatomic) UIButton* loadButton;
@property (nonatomic) UIImageView* logoView;

@end

#pragma mark -

@implementation CDASpaceSelectionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)showSpaceWithKey:(NSString*)spaceKey accessToken:(NSString*)accessToken
{
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:spaceKey accessToken:accessToken];
    [UIApplication sharedApplication].client = client;
    
    [self startSpinningLogo];
    
    [client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        [self stopSpinningLogo];
        
        CDASpaceViewController* spaceVC = [CDASpaceViewController new];
        [self presentViewController:spaceVC animated:YES completion:nil];
    } failure:^(CDAResponse *response, NSError *error) {
        [self stopSpinningLogo];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (UITextField*)textFieldAtRow:(NSInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:1];
    CDATextEntryCell* cell = (CDATextEntryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    return cell.textField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self stopSpinningLogo];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSpinningLogo];
}

#pragma mark - Actions

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)doneTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadDefaultSpaceTapped
{
    [self showSpaceWithKey:@"cfexampleapi" accessToken:@"b4c0n73n7fu1"];
}

- (void)loadSpaceTapped
{
    NSString* spaceKey = [self textFieldAtRow:0].text;
    NSString* accessToken = [self textFieldAtRow:1].text;
    
    [[NSUserDefaults standardUserDefaults] setValue:spaceKey forKey:CDASpaceKey];
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:CDAAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self showSpaceWithKey:spaceKey accessToken:accessToken];
}

- (void)logoTapped
{
    CDAAboutUsViewController* aboutUs = [CDAAboutUsViewController new];
    aboutUs.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    
    UINavigationController* navController = [[UINavigationController alloc]
                                             initWithRootViewController:aboutUs];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)showHelp
{
    CDAHelpViewController* help = [CDAHelpViewController new];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:help];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)textFieldChanged
{
    self.loadButton.enabled = self.done;
}

#pragma mark - Animations

- (void)startSpinningLogo
{
    [[self textFieldAtRow:0] resignFirstResponder];
    [[self textFieldAtRow:1] resignFirstResponder];
    
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
            cell.textField.placeholder = NSLocalizedString(@"Space", nil);
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDASpaceKey];
            cell.textLabel.text = cell.textField.placeholder;
            break;
        case 1:
            cell.textField.placeholder = NSLocalizedString(@"Access Token", nil);
            cell.textField.returnKeyType = UIReturnKeyGo;
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDAAccessTokenKey];
            cell.textLabel.text = cell.textField.placeholder;
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
    return section == 1 ? 118.0 : UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 220.0 : UITableViewAutomaticDimension;
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
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 118.0)];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10.0, 10.0, view.frame.size.width - 20.0, 44.0);
    
    [button addTarget:self action:@selector(loadSpaceTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Load Space", nil) forState:UIControlStateNormal];
    
    self.loadButton = button;
    self.loadButton.enabled = self.done;
    
    [view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(self.loadButton.frame.origin.x, CGRectGetMaxY(self.loadButton.frame) + 10.0,
                              self.loadButton.frame.size.width, self.loadButton.frame.size.height);
    
    [button addTarget:self
               action:@selector(loadDefaultSpaceTapped)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Demo Space", nil) forState:UIControlStateNormal];
    
    [view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(view.frame.size.width - 64.0, view.frame.size.height - 64.0, 44.0, 44.0);
    
    [button addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    
    [view addSubview:button];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoView.frame = CGRectMake(0.0, 40.0, tableView.frame.size.width, 200.0);
        self.logoView.userInteractionEnabled = YES;
        [containerView addSubview:self.logoView];
        
        [self.logoView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(logoTapped)]];
        
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
    if (textField.returnKeyType == UIReturnKeyNext) {
        [[self textFieldAtRow:1] becomeFirstResponder];
        return NO;
    }
    
    if (self.done) {
        [self loadSpaceTapped];
        return NO;
    }
    
    return YES;
}

@end
