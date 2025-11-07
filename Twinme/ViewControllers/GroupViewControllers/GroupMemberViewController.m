/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "GroupMemberViewController.h"
#import <TwinmeCommon/GroupService.h>

#import "GroupMemberCell.h"
#import "GroupMemberSectionHeaderCell.h"
#import "AddGroupMemberViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "SelectedGroupMemberCell.h"
#import "MenuGroupMemberView.h"
#import "UIContact.h"
#import "UIInvitation.h"
#import "DeleteConfirmView.h"

#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *GROUP_MEMBER_CELL_IDENTIFIER = @"GroupMemberCellIdentifier";
static NSString *SELECTED_GROUP_MEMBER_CELL_IDENTIFIER = @"SelectedGroupMemberCellIdentifier";
static NSString *GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER = @"GroupMemberSectionHeaderCellIdentifier";

static CGFloat DESIGN_SECTION_HEIGHT = 50;
static CGFloat DESIGN_CELL_HEIGHT = 120;

static const int MEMBERS_VIEW_SECTION_COUNT = 3;

static const int CREATOR_GROUP_VIEW_SECTION = 0;
static const int MEMBERS_GROUP_VIEW_SECTION = 1;
static const int INVITATION_GROUP_VIEW_SECTION = 2;

@interface GroupMemberViewController () <GroupServiceDelegate, UITableViewDelegate, UITableViewDataSource, AlertMessageViewDelegate, MenuGroupMemberDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *membersTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersTableViewBottomConstraint;
@property (nonatomic) DeleteConfirmView *deleteConfirmView;
@property (nonatomic) UIBarButtonItem *addMemberBarButtonItem;

@property (nonatomic) NSMutableArray *uiMembers;
@property (nonatomic) NSMutableArray *uiMembersInvitations;
@property (nonatomic) BOOL canRemove;
@property (nonatomic) BOOL canInvite;
@property (nonatomic) BOOL canInviteMemberAsContact;
@property (nonatomic) BOOL needRefresh;

@property (nonatomic) GroupService *groupService;
@property (nonatomic) NSMutableDictionary<NSUUID *, TLInvitationDescriptor *> *pendingInvitations;

@property (nonatomic) TLGroup *group;
@property (nonatomic) UIContact *adminGroup;
@property (nonatomic) id<TLGroupConversation> groupConversation;

@property (nonatomic) UIContact *selectedContact;
@property (nonatomic) BOOL refreshTableScheduled;

@end

//
// Implementation: GroupMemberViewController
//

#undef LOG_TAG
#define LOG_TAG @"GroupMemberViewController"

@implementation GroupMemberViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiMembers = [[NSMutableArray alloc] init];
        _uiMembersInvitations = [[NSMutableArray alloc] init];
        _canRemove = NO;
        _canInvite = NO;
        _canInviteMemberAsContact = NO;
        
        _groupService = [[GroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    [super viewWillAppear:animated];
    
    // A full refresh is necessary when AddGroupMemberViewController has added some members:
    // it could have modified the uiMembers by adding some contacts but this is really some
    // invitations, not real members.
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.groupService getGroupWithGroupId:self.group.uuid];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = YES;
    [super viewWillDisappear:animated];
}

#pragma mark - Public methods

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    [self.groupService initWithGroup:group];
    [self.groupService getGroupWithGroupId:group.uuid];
}

#pragma mark - GroupServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

}

- (void)onGetGroup:(nonnull TLGroup *)group groupMembers:(nonnull NSArray<TLGroupMember *> *)groupMembers conversation:(nonnull id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onGetGroup: %@ groupMembers: %@ conversation:%@", LOG_TAG, group, groupMembers, conversation);
    
    self.group = group;
    self.groupConversation = conversation;
    
    if ([self.groupConversation hasPermissionWithPermission:TLPermissionTypeRemoveMember]) {
        self.canRemove = YES;
    }
    
    if ([self.groupConversation hasPermissionWithPermission:TLPermissionTypeSendTwincode]) {
        self.canInviteMemberAsContact = YES;
    }
    
    if ([self.groupConversation hasPermissionWithPermission:TLPermissionTypeInviteMember]) {
        self.canInvite = YES;
        self.addMemberBarButtonItem.tintColor = [UIColor whiteColor];
    } else {
        self.addMemberBarButtonItem.tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    }
    
    [self.uiMembers removeAllObjects];
    
    self.refreshTableScheduled = YES;
    for (TLGroupMember *member in groupMembers) {
        [self updateUIContact:member avatar:nil];
    }
    self.refreshTableScheduled = NO;

    [self.groupService getTwincodeOutboundWithTwincodeOutboundId:self.group.twincodeOutbound.uuid];
}

- (void)onListPendingInvitations:(nonnull NSMutableDictionary<NSUUID *, TLInvitationDescriptor *> *)list {
    DDLogVerbose(@"%@ onListPendingInvitations: %@", LOG_TAG, list);

    self.pendingInvitations = list;
}

- (void)onInviteGroup:(id<TLConversation>)conversation invitation:(TLInvitationDescriptor *)invitation {
    DDLogVerbose(@"%@ onInviteGroup: %@", LOG_TAG, invitation);
    
    BOOL updateInvitation = NO;
    for (UIInvitation *uiInvitation in self.uiMembersInvitations) {
        if ([uiInvitation.invitationDescriptor.descriptorId isEqual:invitation.descriptorId]) {
            uiInvitation.invitationDescriptor = invitation;
            [self.membersTableView reloadData];
            updateInvitation = YES;
            break;
        }
    }
    
    if (!updateInvitation && self.pendingInvitations) {
        [self.pendingInvitations setObject:invitation forKey:conversation.contactId];
    }
}

- (void)onGetTwincode:(TLTwincodeOutbound *)twincodeOutbound {
    DDLogVerbose(@"%@ onGetTwincode: %@", LOG_TAG, twincodeOutbound);
    
    TLGroupMember *member = [[TLGroupMember alloc] initWithOwner:self.group twincodeOutbound:twincodeOutbound];
    [self updateUIContact:member avatar:nil];
    
    NSUUID *adminTwincode = self.group.createdByMemberTwincodeOutboundId;
    for (UIContact *member in self.uiMembers) {
        if (adminTwincode && [adminTwincode isEqual:member.contact.peerTwincodeOutboundId]) {
            self.adminGroup = member;
            [self.uiMembers removeObject:member];
            break;
        }
    }
    
    [self.uiMembersInvitations removeAllObjects];
    if (self.pendingInvitations.count > 0 ) {
        [self.groupService getContacts];
    } else {
        [self.membersTableView reloadData];
    }
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    self.refreshTableScheduled = YES;
    for (NSUUID *uuid in self.pendingInvitations.allKeys) {
        for (TLContact *contact in contacts) {
            if ([contact.uuid isEqual:uuid]) {
                [self updateUIContactInvitation:contact invitation:[self.pendingInvitations objectForKey:uuid]];
                break;
            }
        }
    }
    
    self.refreshTableScheduled = NO;
    [self.membersTableView reloadData];
}

- (void)updateUIContact:(TLGroupMember *)groupMember avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, groupMember);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiMembers) {
        if ([lUIContact.contact.uuid isEqual:groupMember.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiMembers removeObject:uiContact];
        [uiContact setContact:groupMember];
    } else {
        uiContact = [[UIContact alloc] initWithContact:groupMember];
    }
    if (!avatar) {
        [self.groupService getImageWithGroupMember:groupMember withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiMembers.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiMembers[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiMembers insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiMembers addObject:uiContact];
    }
}

- (void)updateUIContactInvitation:(TLContact *)contact invitation:(TLInvitationDescriptor *)invitation {
    DDLogVerbose(@"%@ updateUIContactInvitation: %@ invitation: %@", LOG_TAG, contact, invitation);
    
    UIInvitation *uiContact = nil;
    for (UIInvitation *lUIContact in self.uiMembersInvitations) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiMembersInvitations removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIInvitation alloc] initWithContact:contact];
    }
    [self.groupService getImageWithContact:contact withBlock:^(UIImage *image) {
        [uiContact updateAvatar:image];
        [self refreshTable];
    }];
    
    uiContact.invitationDescriptor = invitation;
    
    BOOL added = NO;
    NSInteger count = self.uiMembersInvitations.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiMembersInvitations[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiMembersInvitations insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiMembersInvitations addObject:uiContact];
    }
}

- (void)onLeaveGroup:(TLGroup *)group memberTwincodeId:(NSUUID *)memberTwincodeId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberTwincodeId:%@", LOG_TAG, group, memberTwincodeId);
    
    for (UIContact *member in self.uiMembers) {
        if ([member.contact.uuid isEqual:memberTwincodeId]) {
            [self.uiMembers removeObject:member];
            [self.membersTableView reloadData];
            break;
        }
    }
    
    // If the current member leaves the group, the group object is marked as isLeaving and deleted at the very end.
    if ([group isLeaving] && !self.selectedContact) {
        [self finish];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidEndEditing: %@", LOG_TAG, textField);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return MEMBERS_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATOR_GROUP_VIEW_SECTION) {
        if (self.adminGroup) {
            return 1;
        }
        return 0;
    } else if (section == MEMBERS_GROUP_VIEW_SECTION) {
        return self.uiMembers.count;
    } else {
        return self.uiMembersInvitations.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATOR_GROUP_VIEW_SECTION && !self.adminGroup) {
        return 0;
    } else if (section == MEMBERS_GROUP_VIEW_SECTION && self.uiMembers.count == 0) {
        return 0;
    } else if (section == INVITATION_GROUP_VIEW_SECTION && self.uiMembersInvitations.count == 0) {
        return 0;
    }
    
    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    GroupMemberSectionHeaderCell *groupMemberSectionHeader = (GroupMemberSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
    if (!groupMemberSectionHeader) {
        groupMemberSectionHeader = [[GroupMemberSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
    }
    
    if (section == CREATOR_GROUP_VIEW_SECTION) {
        groupMemberSectionHeader.titleLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_administrator", nil);
    } else if (section == MEMBERS_GROUP_VIEW_SECTION) {
        groupMemberSectionHeader.titleLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_member", nil);
    } else {
        groupMemberSectionHeader.titleLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_invitation", nil);
    }
    
    return groupMemberSectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    GroupMemberCell *groupMemberCell = (GroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:GROUP_MEMBER_CELL_IDENTIFIER];
    if (!groupMemberCell) {
        groupMemberCell = [[GroupMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:GROUP_MEMBER_CELL_IDENTIFIER];
    }
    
    UIContact *uiContact = nil;
    if (indexPath.section == CREATOR_GROUP_VIEW_SECTION && self.adminGroup) {
        [groupMemberCell bindWithContact:self.adminGroup invitation:nil hideSeparator:YES];
    } else if (indexPath.section  == MEMBERS_GROUP_VIEW_SECTION) {
        uiContact = self.uiMembers[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiMembers.count ? YES : NO;
        [groupMemberCell bindWithContact:uiContact invitation:nil hideSeparator:hideSeparator];
    } else if (indexPath.section  == INVITATION_GROUP_VIEW_SECTION) {
        uiContact = self.uiMembersInvitations[indexPath.row];
        UIInvitation *uiInvitation = (UIInvitation *)uiContact;
        BOOL hideSeparator = indexPath.row + 1 == self.uiMembersInvitations.count ? YES : NO;
        [groupMemberCell bindWithContact:uiInvitation invitation:uiInvitation hideSeparator:hideSeparator];
    }
    
    return groupMemberCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    BOOL canInvite = NO;
    BOOL canRemove = self.canRemove;
    
    if (indexPath.section == CREATOR_GROUP_VIEW_SECTION && self.adminGroup) {
        self.selectedContact = self.adminGroup;
        
        if (self.canInviteMemberAsContact && ![self.adminGroup.contact.peerTwincodeOutboundId isEqual:self.group.twincodeOutbound.uuid]) {
            canInvite = YES;
        }
    } else if (indexPath.section  == MEMBERS_GROUP_VIEW_SECTION) {
        self.selectedContact = self.uiMembers[indexPath.row];
        if (self.canInviteMemberAsContact && ![self.selectedContact.contact.peerTwincodeOutboundId isEqual:self.group.twincodeOutbound.uuid]) {
            canInvite = YES;
        }
    } else if (indexPath.section  == INVITATION_GROUP_VIEW_SECTION) {
        self.selectedContact = self.uiMembersInvitations[indexPath.row];
        canRemove = YES;
    }
    
    MenuGroupMemberView *menuGroupMemberView = [[MenuGroupMemberView alloc]init];
    menuGroupMemberView.menuGroupMemberDelegate = self;
    [self.navigationController.view addSubview:menuGroupMemberView];
    [menuGroupMemberView openMenu:self.selectedContact canInvite:canInvite canRemove:canRemove];
}

#pragma mark - MenuGroupMemberDelegate

- (void)inviteMemberAsContact:(MenuGroupMemberView *)menuGroupMemberView member:(UIContact *)member canInvite:(BOOL)canInvite {
    DDLogVerbose(@"%@ inviteMemberAsContact: %@ canInvite: %@", LOG_TAG, member, canInvite ? @"YES" : @"NO");
    
    if (canInvite) {
        self.selectedContact = member;

        DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
        defaultConfirmView.confirmViewDelegate = self;
        [defaultConfirmView initWithTitle:self.selectedContact.name message:[NSString stringWithFormat:TwinmeLocalizedString(@"group_member_view_controller_invitation_message %@", nil), member.name] image:nil avatar:self.selectedContact.avatar action:TwinmeLocalizedString(@"add_contact_view_controller_invite", nil) actionColor:nil cancel:nil];
        [self.tabBarController.view addSubview:defaultConfirmView];
        [defaultConfirmView showConfirmView];
    } else {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"group_member_view_controller_admin_not_authorize", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
    
    [menuGroupMemberView removeFromSuperview];
}

- (void)removeMember:(MenuGroupMemberView *)menuGroupMemberView uiContact:(UIContact *)uiContact canRemove:(BOOL)canRemove  {
    DDLogVerbose(@"%@ removeMember: %@ canRemove: %@", LOG_TAG, uiContact, canRemove ? @"YES" : @"NO");
    
    if (canRemove) {
        self.selectedContact = uiContact;
                
        self.deleteConfirmView = [[DeleteConfirmView alloc] init];
        self.deleteConfirmView.confirmViewDelegate = self;
        self.deleteConfirmView.deleteConfirmType = DeleteConfirmTypeGroupMember;
        [self.deleteConfirmView initWithTitle:self.selectedContact.name message:TwinmeLocalizedString(@"group_member_view_controller_remove_message", nil) avatar:self.selectedContact.avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
       
        [self.navigationController.view addSubview:self.deleteConfirmView];
        [self.deleteConfirmView showConfirmView];
        
    } else {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"group_member_view_controller_admin_not_authorize", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
    
    [menuGroupMemberView removeFromSuperview];
}

- (void)cancelMenuGroupMember:(MenuGroupMemberView *)menuGroupMemberView {
    DDLogVerbose(@"%@ cancelMenuGroupMember", LOG_TAG);
    
    [menuGroupMemberView removeFromSuperview];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        TLGroupMember *groupMember = [[TLGroupMember alloc]initWithOwner:self.group twincodeOutbound:self.selectedContact.contact.peerTwincodeOutbound];
        [self.groupService createInvitation:groupMember];
        
        self.selectedContact = nil;
    } else {
        UIInvitation *uiInvitation = nil;
        for (UIInvitation *luiInvitation in self.uiMembersInvitations) {
            if ([luiInvitation.contact.uuid isEqual:self.selectedContact.contact.uuid]) {
                uiInvitation = luiInvitation;
                break;
            }
        }
        
        if (uiInvitation) {
            [self.groupService withdrawInvitation:uiInvitation.invitationDescriptor];
            
            [self.uiMembersInvitations removeObject:uiInvitation];
            [self.membersTableView reloadData];
        } else {
            [self.groupService leaveGroupWithMemberTwincodeId:self.selectedContact.contact.peerTwincodeOutboundId];
        }
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    self.selectedContact = nil;
    [abstractConfirmView removeFromSuperview];
    
    if ([self.group isLeaving]) {
        [self finish];
    }
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    self.selectedContact = nil;
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"group_member_view_controller_title", nil)];
    
    self.addMemberBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarAddContact"] style:UIBarButtonItemStylePlain target:self action:@selector(handleAddMemberTapGesture:)];
    self.navigationItem.rightBarButtonItem = self.addMemberBarButtonItem;
    
    self.membersTableViewBottomConstraint.constant = 0;
    self.membersTableView.delegate = self;
    self.membersTableView.dataSource = self;
    self.membersTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.membersTableView.sectionHeaderHeight = 0;
    self.membersTableView.sectionFooterHeight = 60 * Design.HEIGHT_RATIO;
    
    [self.membersTableView registerNib:[UINib nibWithNibName:@"GroupMemberCell" bundle:nil] forCellReuseIdentifier:GROUP_MEMBER_CELL_IDENTIFIER];
    [self.membersTableView registerNib:[UINib nibWithNibName:@"GroupMemberSectionHeaderCell" bundle:nil] forCellReuseIdentifier:GROUP_MEMBER_SECTION_HEADER_CELL_IDENTIFIER];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.groupService) {
        [self.groupService dispose];
        self.groupService = nil;
    }
    
    if (self.deleteConfirmView) {
        [self.deleteConfirmView removeFromSuperview];
        self.deleteConfirmView = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleAddMemberTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddMemberTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canInvite) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"group_member_view_controller_admin_not_authorize", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    } else {
        AddGroupMemberViewController *addGroupMemberViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupMemberViewController"];
        NSMutableArray *members = [NSMutableArray arrayWithArray:self.uiMembers];
        if (self.adminGroup) {
            [members addObject:self.adminGroup];
        }
        [addGroupMemberViewController initWithMembers:members fromCreateGroup:NO];
        [addGroupMemberViewController initWithGroup:self.group];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:addGroupMemberViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.membersTableView reloadData];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.membersTableView reloadData];
        });
    }
}

@end
