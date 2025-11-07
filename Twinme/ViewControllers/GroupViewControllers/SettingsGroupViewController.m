/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "MessageSettingsViewController.h"
#import "SettingsGroupViewController.h"
#import "SettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"

#import <TwinmeCommon/Design.h>

#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

//
// Interface: SettingsGroupViewController ()
//

@interface SettingsGroupViewController () <SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) TLGroup *group;
@property (nonatomic) id<TLGroupConversation> groupConversation;

@property (nonatomic) BOOL allowInvitation;
@property (nonatomic) BOOL allowMessage;
@property (nonatomic) BOOL allowInviteMemberAsContact;

@end

typedef enum {
    SECTION_ALLOW_INVITATION,
    SECTION_ALLOW_MESSAGE,
    SECTION_ALLOW_INVITE_MEMBER_AS_CONTACT,
    SECTION_COUNT
} TLSettingsGroupSection;

typedef enum {
    TAG_ALLOW_INVITATION,
    TAG_ALLOW_MESSAGE,
    TAG_ALLOW_INVITE_MEMBER_AS_CONTACT
} TLSettingsGroupTag;

//
// Implementation: SettingsGroupViewController
//

#undef LOG_TAG
#define LOG_TAG @"SettingsGroupViewController"

@implementation SettingsGroupViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _allowInvitation = YES;
        _allowMessage = YES;
        _allowInviteMemberAsContact = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    self.groupConversation = (id<TLGroupConversation>)[[self.twinmeContext getConversationService] getConversationWithSubject:self.group];
    
    int64_t joinPermissions = self.groupConversation.joinPermissions;
    
    self.allowMessage = (joinPermissions & (1 << TLPermissionTypeSendMessage)) != 0;
    self.allowInvitation = (joinPermissions & (1 << TLPermissionTypeInviteMember)) != 0;
    self.allowInviteMemberAsContact = (joinPermissions & (1 << TLPermissionTypeSendTwincode)) != 0;
}

- (void)initWithPermissions:(BOOL)allowInvitation allowMessage:(BOOL)allowMessage allowInviteMemberAsContact:(BOOL)allowInviteMemberAsContact {
    DDLogVerbose(@"%@ initWithPermissions: %@ allowMessage: %@ allowInviteMemberAsContact: %@", LOG_TAG, allowInvitation ? @"YES":@"NO", allowMessage ? @"YES":@"NO", allowInviteMemberAsContact ? @"YES":@"NO");
    
    self.allowMessage = allowMessage;
    self.allowInvitation = allowInvitation;
    self.allowInviteMemberAsContact = allowInviteMemberAsContact;
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_INVITATION:
            self.allowInvitation = updatedSwitch.isOn;
            break;
            
        case TAG_ALLOW_MESSAGE:
            self.allowMessage = updatedSwitch.isOn;
            break;
            
        case TAG_ALLOW_INVITE_MEMBER_AS_CONTACT:
            self.allowInviteMemberAsContact = updatedSwitch.isOn;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
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
    
    if (section == SECTION_ALLOW_INVITATION) {
        return CGFLOAT_MIN;
    }
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:@"" backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        switch (indexPath.section) {
            case SECTION_ALLOW_INVITATION:
                text = TwinmeLocalizedString(@"create_group_view_controller_member_allow_invitation_message", nil);
                break;
                
            case SECTION_ALLOW_MESSAGE:
                text = TwinmeLocalizedString(@"create_group_view_controller_member_allow_post_message", nil);
                break;
            
            case SECTION_ALLOW_INVITE_MEMBER_AS_CONTACT:
                text = TwinmeLocalizedString(@"create_group_view_controller_member_allow_invite_member_as_contact_message", nil);
                break;
                                
            default:
                break;
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        
        NSString *title = @"";
        BOOL switchState = NO;
        int tag = 0;
        BOOL hiddenSwitch = NO;
        switch (indexPath.section) {
            case SECTION_ALLOW_INVITATION:
                switchState = self.allowInvitation;
                hiddenSwitch = NO;
                tag = TAG_ALLOW_INVITATION;
                title = TwinmeLocalizedString(@"create_group_view_controller_member_allow_invitation_title", nil);
                break;
                
            case SECTION_ALLOW_MESSAGE:
                switchState = self.allowMessage;
                hiddenSwitch = NO;
                tag = TAG_ALLOW_MESSAGE;
                title = TwinmeLocalizedString(@"create_group_view_controller_member_allow_post_title", nil);
                break;
                
            case SECTION_ALLOW_INVITE_MEMBER_AS_CONTACT:
                switchState = self.allowInviteMemberAsContact;
                hiddenSwitch = NO;
                tag = TAG_ALLOW_INVITE_MEMBER_AS_CONTACT;
                title = TwinmeLocalizedString(@"create_group_view_controller_member_allow_invite_member_as_contact_title", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_view_controller_authorization_title", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];

    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);

    if ([self.delegate respondsToSelector:@selector(updatePermissions:allowMessage:allowInviteMemberAsContact:)]) {
        [self.delegate updatePermissions:self.allowInvitation allowMessage:self.allowMessage allowInviteMemberAsContact:self.allowInviteMemberAsContact];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    return indexPath.row == 1;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.WHITE_COLOR;
}

@end
