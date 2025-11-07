/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>

#import "TypeCleanUpViewController.h"
#import "CleanUpViewController.h"

#import "SettingsInformationCell.h"
#import "TwinmeSettingsItemCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ResetConversationService.h>

#import "ResetConversationConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif


static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

//
// Interface: TypeCleanUpViewController ()
//

@interface TypeCleanUpViewController ()<UITableViewDelegate, UITableViewDataSource, ResetConversationServiceDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) ResetConversationConfirmView *resetConversationConfirmView;

@property (nonatomic) TLContact *contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) TLSpace *space;

@property (nonatomic) ResetConversationService *resetConversationService;

@end

//
// Implementation: TypeCleanUpViewController
//

#undef LOG_TAG
#define LOG_TAG @"TypeCleanUpViewController"

@implementation TypeCleanUpViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _resetConversationService = [[ResetConversationService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initCleanUpWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initCleanUpWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    [self.resetConversationService initWithContact:self.contact];
}

- (void)initCleanUpWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initCleanUpWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    [self.resetConversationService initWithGroup:self.group];
}

- (void)initCleanUpWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initCleanUpWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if ([self showResetConversation]) {
        return 4;
    }
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        if (indexPath.row == 1) {
            text = TwinmeLocalizedString(@"cleanup_view_controller_info", nil);
        } else if (indexPath.row == 3) {
            text = TwinmeLocalizedString(@"cleanup_view_controller_info_both", nil);
        } else if (indexPath.row == 5) {
            text = TwinmeLocalizedString(@"cleanup_view_controller_reset_conversation_message", nil);
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        UIColor *color = Design.FONT_COLOR_DEFAULT;
        BOOL hiddenAccessory = NO;
        if (indexPath.row == 0) {
            title = TwinmeLocalizedString(@"cleanup_view_controller_local_cleanup", nil);
        } else if (indexPath.row == 2) {
            title = TwinmeLocalizedString(@"cleanup_view_controller_both_clean", nil);
        }  else if (indexPath.row == 4) {
            title = TwinmeLocalizedString(@"main_view_controller_reset_conversation_title", nil);
            color = Design.DELETE_COLOR_RED;
            hiddenAccessory = YES;
        }
        
        [cell bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:NO color:color];
        
        return cell;
    }
}

#pragma mark - ResetConversationServiceDelegate

- (void)onResetConversation:(nonnull id <TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversation: %@ clearMode: %u", LOG_TAG, conversation, clearMode);
    
    [self finish];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.resetConversationConfirmView) {
        return;
    }
    
    if (![self isInformationPath:indexPath] && indexPath.row != 4) {
        
        CleanUpViewController *cleanupViewController = (CleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"CleanUpViewController"];
        
        if (indexPath.row == 0) {
            cleanupViewController.cleanUpType = CleanUpTypeLocal;
        } else {
            cleanupViewController.cleanUpType = CleanUpTypeBoth;
        }
        
        if (self.contact) {
            [cleanupViewController initCleanUpWithContact:self.contact];
        } else if (self.group) {
            [cleanupViewController initCleanUpWithGroup:self.group];
        } else if (self.space) {
            [cleanupViewController initCleanUpWithSpace:self.space];
        } else {
            [cleanupViewController initCleanUpApplication];
        }
        
        [self.navigationController pushViewController:cleanupViewController animated:YES];
    } else if (indexPath.row == 4) {
        if (self.group) {
            [self.resetConversationService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                [self openResetConversationConfirmView:image];
            }];
        } else {
            [self.resetConversationService getImageWithContact:self.contact withBlock:^(UIImage *image) {
                [self openResetConversationConfirmView:image];
            }];
        }
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self.resetConversationService resetConversation];
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [self.resetConversationConfirmView removeFromSuperview];
    self.resetConversationConfirmView = nil;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.resetConversationService) {
        [self.resetConversationService dispose];
        self.resetConversationService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openResetConversationConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ openResetConversationConfirmView", LOG_TAG);
    
    NSString *alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_conversation_message", nil);
    if (self.group) {
        if (self.group.isOwner) {
            alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_group_conversation_admin_message", nil);
        } else {
            alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_group_conversation_message", nil);
        }
    }
    self.resetConversationConfirmView = [[ResetConversationConfirmView alloc] init];
    self.resetConversationConfirmView.confirmViewDelegate = self;
    [self.resetConversationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:alertMessage avatar:avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
    [self.tabBarController.view addSubview:self.resetConversationConfirmView];
    [self.resetConversationConfirmView showConfirmView];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ isInformationPath: %@", LOG_TAG, indexPath);
    
    if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5) {
        return YES;
    }
    
    return NO;
}

- (BOOL)showResetConversation {
    DDLogVerbose(@"%@ showResetConversation", LOG_TAG);
    
    return !self.contact && !self.group;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
