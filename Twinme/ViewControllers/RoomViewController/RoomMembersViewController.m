/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLRoomCommand.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "RoomMembersViewController.h"

#import "RoomMemberCell.h"
#import "GroupMemberSectionHeaderCell.h"
#import "UIRoomMember.h"
#import "MenuRoomMemberView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/RoomMemberService.h>

#import "AlertView.h"
#import "AlertMessageView.h"


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ROOM_MEMBER_CELL_IDENTIFIER = @"RoomMemberCellIdentifier";
static NSString *GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER = @"GroupMemberSectionHeaderCellIdentifier";

static CGFloat DESIGN_SECTION_HEIGHT = 50;
static CGFloat DESIGN_CELL_HEIGHT = 120;

static const int MEMBERS_VIEW_SECTION_COUNT = 2;

static const int ADMINISTRATOR_VIEW_SECTION = 0;
static const int MEMBERS_VIEW_SECTION = 1;

static NSInteger DELETE_ALERT_VIEW_TAG = 1;
static NSInteger ADMIN_ALERT_VIEW_TAG = 2;
static NSInteger INVITATION_ALERT_VIEW_TAG = 3;
static NSInteger REMOVE_ADMIN_ALERT_VIEW_TAG = 4;

@interface RoomMembersViewController () <UITableViewDelegate, UITableViewDataSource, AlertViewDelegate, RoomMemberServiceDelegate, MenuRoomMembersDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *membersTableView;

@property (nonatomic) MenuRoomMemberView *menuRoomMemberView;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) NSMutableArray *uiRoomAdmins;
@property (nonatomic) NSMutableArray *uiRoomMembers;

@property (nonatomic) TLContact *room;
@property (nonatomic) UIRoomMember *selectedMember;

@property (nonatomic) RoomMemberService *roomMemberService;

@end

//
// Implementation: RoomMembersViewController
//

#undef LOG_TAG
#define LOG_TAG @"RoomMembersViewController"

@implementation RoomMembersViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiRoomMembers = [[NSMutableArray alloc] init];
        _uiRoomAdmins = [[NSMutableArray alloc] init];
        _roomMemberService = [[RoomMemberService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - Public methods

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    
    [self.roomMemberService initWithRoom:self.room];
}

#pragma mark - RoomMemberServiceDelegate

- (void)onGetRoomAdmins:(nonnull NSArray *)roomAdmins {
    DDLogVerbose(@"%@ onGetRoomAdmins: %@", LOG_TAG, roomAdmins);
    
    for (TLTwincodeOutbound *twincodeOutbound in roomAdmins) {
        UIRoomMember *uiRoomAdmin = [[UIRoomMember alloc]initWithTwincodeOutbound:twincodeOutbound avatar:nil];
        [self.uiRoomAdmins addObject:uiRoomAdmin];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onGetRoomMembers:(nonnull NSArray *)roomMembers {
    DDLogVerbose(@"%@ onGetRoomMembers: %@", LOG_TAG, roomMembers);
    
    for (TLTwincodeOutbound *twincodeOutbound in roomMembers) {
        UIRoomMember *uiRoomMember = [[UIRoomMember alloc]initWithTwincodeOutbound:twincodeOutbound avatar:nil];
        [self.uiRoomMembers addObject:uiRoomMember];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onGetRoomAdminAvatar:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onGetRoomAdminAvatar: %@ avatar: %@", LOG_TAG, twincodeOutbound, avatar);
    
    for (UIRoomMember *uiRoomAdmin in self.uiRoomAdmins) {
        if ([twincodeOutbound.uuid isEqual:uiRoomAdmin.twincodeOutbound.uuid]) {
            [uiRoomAdmin setTwincodeOutbound:twincodeOutbound avatar:avatar];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onGetRoomMemberAvatar:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onGetRoomMemberAvatar: %@ avatar: %@", LOG_TAG, twincodeOutbound, avatar);
    
    for (UIRoomMember *uiRoomMember in self.uiRoomMembers) {
        if ([twincodeOutbound.uuid isEqual:uiRoomMember.twincodeOutbound.uuid]) {
            [uiRoomMember setTwincodeOutbound:twincodeOutbound avatar:avatar];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onSetAdministrator:(nonnull NSUUID *)adminId {
    DDLogVerbose(@"%@ onSetAdministrator: %@", LOG_TAG, adminId);
    
    for (UIRoomMember *uiRoomMember in self.uiRoomMembers) {
        if ([uiRoomMember.twincodeOutbound.uuid isEqual:adminId]) {
            [self.uiRoomAdmins addObject:uiRoomMember];
            [self.uiRoomMembers removeObject:uiRoomMember];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onRemoveAdministrator:(nonnull NSUUID *)adminId {
    DDLogVerbose(@"%@ onRemoveAdministrator: %@", LOG_TAG, adminId);
    
    for (UIRoomMember *uiRoomMember in self.uiRoomAdmins) {
        if ([uiRoomMember.twincodeOutbound.uuid isEqual:adminId]) {
            [self.uiRoomMembers addObject:uiRoomMember];
            [self.uiRoomAdmins removeObject:uiRoomMember];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

- (void)onRemoveMember:(nonnull NSUUID *)memberId {
    DDLogVerbose(@"%@ onRemoveMember: %@", LOG_TAG, memberId);
    
    for (UIRoomMember *uiRoomMember in self.uiRoomMembers) {
        if ([uiRoomMember.twincodeOutbound.uuid isEqual:memberId]) {
            [self.uiRoomMembers removeObject:uiRoomMember];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.membersTableView reloadData];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return MEMBERS_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ADMINISTRATOR_VIEW_SECTION) {
        return self.uiRoomAdmins.count;
    }
    
    return self.uiRoomMembers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ADMINISTRATOR_VIEW_SECTION && self.uiRoomAdmins.count > 0) {
        return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
    } else if (section == MEMBERS_VIEW_SECTION && self.uiRoomMembers.count > 0) {
        return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if ((section == ADMINISTRATOR_VIEW_SECTION && self.uiRoomAdmins.count == 0) || (section == MEMBERS_VIEW_SECTION && self.uiRoomMembers.count == 0)) {
        return [[UIView alloc]init];
    }
    
    GroupMemberSectionHeaderCell *groupMemberSectionHeader = (GroupMemberSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
    if (!groupMemberSectionHeader) {
        groupMemberSectionHeader = [[GroupMemberSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
    }
    
    if (section == ADMINISTRATOR_VIEW_SECTION) {
        groupMemberSectionHeader.titleLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_administrator", nil);
    } else {
        groupMemberSectionHeader.titleLabel.text = TwinmeLocalizedString(@"room_members_view_controller_participants_title", nil);
    }
    
    return groupMemberSectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section  == MEMBERS_VIEW_SECTION && indexPath.row + 1 == self.uiRoomMembers.count) {
        [self.roomMemberService nextMembers];
    }
    
    RoomMemberCell *roomMemberCell = (RoomMemberCell *)[tableView dequeueReusableCellWithIdentifier:ROOM_MEMBER_CELL_IDENTIFIER];
    if (!roomMemberCell) {
        roomMemberCell = [[RoomMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ROOM_MEMBER_CELL_IDENTIFIER];
    }
    
    if (indexPath.section == ADMINISTRATOR_VIEW_SECTION) {
        UIRoomMember *uiRoomAdmin = self.uiRoomAdmins[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiRoomAdmins.count ? YES : NO;
        [roomMemberCell bindWithMember:uiRoomAdmin hideSeparator:hideSeparator];
    } else if (indexPath.section  == MEMBERS_VIEW_SECTION) {
        UIRoomMember *uiRoomMember = self.uiRoomMembers[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiRoomMembers.count ? YES : NO;
        [roomMemberCell bindWithMember:uiRoomMember hideSeparator:hideSeparator];
    }
    
    return roomMemberCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == ADMINISTRATOR_VIEW_SECTION) {
        self.selectedMember = self.uiRoomAdmins[indexPath.row];
    } else {
        self.selectedMember = self.uiRoomMembers[indexPath.row];
    }
    
    BOOL showAdminAction = [self.room.capabilities hasAdmin];
    BOOL removeAdminAction = indexPath.section == ADMINISTRATOR_VIEW_SECTION;
    [self openMenu:showAdminAction removeAdminAction:removeAdminAction];
}

#pragma mark - MenuRoomMembersDelegate

- (void)cancelMenu {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [self closeMenu];
}

- (void)changeAdministrator:(UIRoomMember *)uiMember {
    DDLogVerbose(@"%@ changeAdministrator: %@", LOG_TAG, uiMember);
    
    AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"room_members_view_controller_change_admin_title", nil) message:TwinmeLocalizedString(@"application_confirm", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_no", nil) otherButtonTitles:TwinmeLocalizedString(@"application_yes", nil) alertViewDelegate:self];
    alertView.view.tag = ADMIN_ALERT_VIEW_TAG;
    [alertView showInView:self.tabBarController];
}

- (void)removeAdministrator:(UIRoomMember *)uiMember {
    DDLogVerbose(@"%@ removeAdministrator: %@", LOG_TAG, uiMember);
    
    if (self.uiRoomAdmins.count == 1) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"room_members_view_controller_remove_admin_title", nil) message:TwinmeLocalizedString(@"room_members_view_controller_only_admin_message", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        
    } else {
        AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"room_members_view_controller_remove_admin_title", nil) message:TwinmeLocalizedString(@"application_confirm", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_no", nil) otherButtonTitles:TwinmeLocalizedString(@"application_yes", nil) alertViewDelegate:self];
        alertView.view.tag = REMOVE_ADMIN_ALERT_VIEW_TAG;
        [alertView showInView:self.tabBarController];
    }
}

- (void)removeFromRoom:(UIRoomMember *)uiMember {
    DDLogVerbose(@"%@ removeFromRoom: %@", LOG_TAG, uiMember);
    
    BOOL isAdmin = NO;
    for (UIRoomMember *uiRoomMember in self.uiRoomAdmins) {
        if ([uiRoomMember.twincodeOutbound.uuid isEqual:uiMember.twincodeOutbound.uuid]) {
            isAdmin = YES;
            break;
        }
    }
    
    if (self.uiRoomAdmins.count == 1 && isAdmin) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"room_members_view_controller_remove_admin_title", nil) message:TwinmeLocalizedString(@"room_members_view_controller_only_admin_message", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    } else {
        AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"application_remove", nil) message:TwinmeLocalizedString(@"room_members_view_controller_delete_message", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_no", nil) otherButtonTitles:TwinmeLocalizedString(@"application_yes", nil) alertViewDelegate:self];
        alertView.view.tag = DELETE_ALERT_VIEW_TAG;
        [alertView showInView:self.tabBarController];
    }
}

- (void)inviteMember:(UIRoomMember *)uiMember {
    DDLogVerbose(@"%@ inviteMember: %@", LOG_TAG, uiMember);
    
    AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"group_member_view_controller_invitation_title", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"group_member_view_controller_invitation_message %@", nil), uiMember.name] cancelButtonTitle:TwinmeLocalizedString(@"application_cancel", nil) otherButtonTitles:TwinmeLocalizedString(@"application_ok", nil) alertViewDelegate:self];
    [alertView.view setTag:INVITATION_ALERT_VIEW_TAG];
    [alertView showInView:self.tabBarController];
}

#pragma mark - AlertViewDelegate

- (void)handleAcceptButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleAcceptButtonClick: %@", LOG_TAG, alertView);
    
    if (alertView.view.tag == DELETE_ALERT_VIEW_TAG) {
        [self.roomMemberService removeMember:self.selectedMember.twincodeOutbound.uuid];
    } else if (alertView.view.tag == ADMIN_ALERT_VIEW_TAG) {
        [self.roomMemberService setRoomAdministrator:self.selectedMember.twincodeOutbound.uuid];
    } else if (alertView.view.tag == INVITATION_ALERT_VIEW_TAG) {
        [self.roomMemberService inviteMember:self.selectedMember.twincodeOutbound.uuid];
    } else if (alertView.view.tag == REMOVE_ADMIN_ALERT_VIEW_TAG) {
        [self.roomMemberService removeAdministrator:self.selectedMember.twincodeOutbound.uuid];
    }
    [self closeMenu];
}

- (void)handleCancelButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCancelButtonClick: %@", LOG_TAG, alertView);
    
    [self closeMenu];
}

- (void)handleCloseButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCloseButtonClick: %@", LOG_TAG, alertView);
    
    [self closeMenu];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
        
    [alertMessageView removeFromSuperview];
}

#pragma mark - Private Methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"room_members_view_controller_participants_title", nil)];
    
    self.membersTableView.delegate = self;
    self.membersTableView.dataSource = self;
    self.membersTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.membersTableView.sectionHeaderHeight = 0;
    self.membersTableView.sectionFooterHeight = 60 * Design.HEIGHT_RATIO;
    
    [self.membersTableView registerNib:[UINib nibWithNibName:@"RoomMemberCell" bundle:nil] forCellReuseIdentifier:ROOM_MEMBER_CELL_IDENTIFIER];
    [self.membersTableView registerNib:[UINib nibWithNibName:@"GroupMemberSectionHeaderCell" bundle:nil] forCellReuseIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
    
    self.overlayView = [UIView new];
    self.overlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    self.overlayView.userInteractionEnabled = YES;
    [self.tabBarController.view addSubview:self.overlayView];
    
    self.menuRoomMemberView = [[MenuRoomMemberView alloc] init];
    self.menuRoomMemberView.hidden = YES;
    self.menuRoomMemberView.menuRoomMemberDelegate = self;
    [self.tabBarController.view addSubview:self.menuRoomMemberView];
    
    UITapGestureRecognizer *tapOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    [self.overlayView addGestureRecognizer:tapOverlayGesture];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.roomMemberService) {
        [self.roomMemberService dispose];
        self.roomMemberService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openMenu:(BOOL)showAdminAction removeAdminAction:(BOOL)removeAdminAction {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    BOOL showInviteAction = ![self.selectedMember.twincodeOutbound.uuid isEqual:self.room.twincodeOutbound.uuid];
    
    if (!showInviteAction && !showAdminAction) {
        self.selectedMember = nil;
        return;
    }
    
    self.overlayView.hidden = NO;
    self.menuRoomMemberView.hidden = NO;
    [self.tabBarController.view bringSubviewToFront:self.overlayView];
    [self.tabBarController.view bringSubviewToFront:self.menuRoomMemberView];
    
    CGRect rectMenu = self.menuRoomMemberView.frame;
    rectMenu.origin.y = Design.DISPLAY_HEIGHT - rectMenu.size.height;
    self.menuRoomMemberView.frame = rectMenu;
    
    [self.menuRoomMemberView openMenu:self.selectedMember showAdminAction:showAdminAction showInviteAction:showInviteAction removeAdminAction:removeAdminAction];
}

- (void)closeMenu {
    DDLogVerbose(@"%@ closeMenu", LOG_TAG);
    
    self.overlayView.hidden = YES;
    self.menuRoomMemberView.hidden = YES;
    self.selectedMember = nil;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.membersTableView reloadData];
}

@end
