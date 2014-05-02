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

@interface CDASpaceSelectionViewController () <CDAEntriesViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) BOOL done;
@property (nonatomic) UIButton* loadButton;

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
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    CDATextEntryCell* cell = (CDATextEntryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    return cell.textField;
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
}

- (void)textFieldChanged
{
    self.loadButton.enabled = self.done;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    return 64.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Enter access information", nil);
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
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
