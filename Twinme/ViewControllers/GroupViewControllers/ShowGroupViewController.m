/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/UIImage+Resize.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "ShowGroupViewController.h"
#import "GroupMemberViewController.h"
#import "EditIdentityViewController.h"
#import "EditGroupViewController.h"
#import "AddGroupMemberViewController.h"
#import "LastCallsViewController.h"
#import "ExportViewController.h"
#import "TypeCleanupViewController.h"
#import "ConversationViewController.h"
#import "ConversationFilesViewController.h"
#import "SettingsGroupViewController.h"
#import "GroupCapabilitiesViewController.h"

#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ShowGroupService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "ShowMemberCell.h"
#import "UIContact.h"

#import "InsideBorderView.h"
#import "SlideContactView.h"
#import "PremiumFeatureConfirmView.h"
#import "DeviceAuthorization.h"
#import "UIView+Toast.h"
#import "UIPremiumFeature.h"
#import "AlertMessageView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MEMBER_CELL_IDENTIFIER = @"ShowMemberCellIdentifier";
static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 120;
static int MAX_GROUP_MEMBER = 5;

//
// Interface: ShowGroupViewController ()
//

@interface ShowGroupViewController () <ShowGroupServiceDelegate, UICollectionViewDataSource, SettingsGroupDelegate, ConfirmViewDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatRoundedView;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoRoundedView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioRoundedView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *membersView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *configurationTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *permissionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *permissionsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *permissionsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *permissionsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *callsSettingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *callsSettingsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *callsSettingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsSettingsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *callsSettingsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lastCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lastCallLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *lastCallAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *conversationsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *filesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *filesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *exportView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *exportLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *cleanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cleanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fallbackImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fallbackLabel;

@property (nonatomic) NSMutableArray *uiMembers;
@property (nonatomic) CALayer *avatarContainerViewLayer;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) NSString *nameGroup;
@property (nonatomic) BOOL toRootView;
@property (nonatomic) BOOL canInvite;
@property (nonatomic) BOOL refreshTableScheduled;

@property (nonatomic) ShowGroupService *showGroupService;

@property (nonatomic) id<TLGroupConversation> groupConversation;

@end

#undef LOG_TAG
#define LOG_TAG @"ShowGroupViewController"

@implementation ShowGroupViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _toRootView = NO;
        _canInvite = NO;
        _uiMembers = [[NSMutableArray alloc] init];
        
        _showGroupService = [[ShowGroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
        
    // Ask the group service to get the group and its members.
    // Do this here so that we get fresh information if we are restored.
    [self.showGroupService getGroupWithGroupId:self.group.uuid];
}

#pragma mark - GroupServiceDelegate

- (void)onGetGroup:(nonnull TLGroup *)group groupMembers:(nonnull NSArray<TLGroupMember *> *)groupMembers conversation:(nonnull id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onGetGroup: %@ groupMembers: %@ conversation:%@", LOG_TAG, group, groupMembers, conversation);
    
    self.group = group;
    self.groupConversation = conversation;
    
    [self.uiMembers removeAllObjects];
    
    for (TLGroupMember *member in groupMembers) {
        [self updateUIContact:member avatar:nil];
    }
    
    self.canInvite = [self.groupConversation hasPermissionWithPermission:TLPermissionTypeInviteMember] && self.groupConversation.state == TLGroupConversationStateJoined;
    
    [self.showGroupService getTwincodeOutboundWithTwincodeOutboundId:self.group.twincodeOutboundId];
    
    [self updateGroup];
}

- (void)onGetTwincode:(TLTwincodeOutbound *)twincodeOutbound {
    DDLogVerbose(@"%@ onGetTwincode: %@", LOG_TAG, twincodeOutbound);
    
    TLGroupMember *member = [[TLGroupMember alloc] initWithOwner:self.group twincodeOutbound:twincodeOutbound];
    [self updateUIContact:member avatar:nil];
    
    [self updateGroup];
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
    self.group = group;
    self.avatar = avatar;
    
    [self updateGroup];
}

- (void)onDeleteGroup:(nonnull NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
    if ([self.group.uuid isEqual:groupId]) {
        self.toRootView = YES;
        [self finish];
    }
}

- (void)onLeaveGroup:(TLGroup *)group memberTwincodeId:(NSUUID *)memberTwincodeId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberTwincodeId: %@", LOG_TAG, group, memberTwincodeId);
    
    if ([group isLeaving]) {
        self.toRootView = YES;
        [self finish];
    } else {
        [self.showGroupService getGroupWithGroupId:self.group.uuid];
    }
}

- (void)onErrorGroupNotFound {
    DDLogVerbose(@"%@ onErrorGroupNotFound", LOG_TAG);
    
    self.scrollView.hidden = YES;
    self.fallbackView.hidden = NO;
    self.backClickableView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self setNavigationTitle:TwinmeLocalizedString(@"show_group_view_controller_title", nil)];
}

- (void)updateUIContact:(nonnull TLGroupMember *)groupMember avatar:(nullable UIImage *)avatar {
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
        [self.showGroupService getImageWithGroupMember:groupMember withBlock:^(UIImage *image) {
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

#pragma mark - Public methods

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    [self.showGroupService initWithGroup:group];
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    EditIdentityViewController *editIdentityViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
    [editIdentityViewController initWithGroup:self.group];
    [self.navigationController pushViewController:editIdentityViewController animated:YES];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditGroupViewController *editGroupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditGroupViewController"];
    [editGroupViewController initWithGroup:self.group];
    [self.navigationController pushViewController:editGroupViewController animated:YES];
}

- (BOOL)showNavigationBar {
    DDLogVerbose(@"%@ showNavigationBar", LOG_TAG);
    
    if (self.group) {
        return self.group.hasPeer;
    }
    return NO;
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    return self.cleanView.frame.origin.y + self.cleanViewHeightConstraint.constant + safeAreaInset;
}

#pragma mark - Setters/Getters

- (void)setGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ setGroup: %@", LOG_TAG, group);
    
    _group = group;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.uiMembers.count <= MAX_GROUP_MEMBER) {
        return self.uiMembers.count;
    }
    
    return MAX_GROUP_MEMBER + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = MIN(DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO, roundf((Design.DISPLAY_WIDTH - (self.membersCollectionViewLeadingConstraint.constant * 2)) / 6));
    return CGSizeMake(heightCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    ShowMemberCell *showRoomMemberCell = [collectionView dequeueReusableCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.row < MAX_GROUP_MEMBER) {
        UIContact *uiMember = self.uiMembers[indexPath.row];
        [showRoomMemberCell bindWithName:uiMember.name avatar:uiMember.avatar memberCount:self.uiMembers.count];
    } else {
        [showRoomMemberCell bindWithName:nil avatar:nil memberCount:self.uiMembers.count - MAX_GROUP_MEMBER];
    }
    return showRoomMemberCell;
}

#pragma mark - SettingsGroupDelegate

- (void)updatePermissions:(BOOL)allowInvitation allowMessage:(BOOL)allowMessage allowInviteMemberAsContact:(BOOL)allowInviteMemberAsContact {
    DDLogVerbose(@"%@ updatePermissions: %@ allowMessage: %@ allowInviteMemberAsContact: %@", LOG_TAG, allowInvitation ? @"YES":@"NO", allowMessage ? @"YES":@"NO", allowInviteMemberAsContact ? @"YES":@"NO");
    
    [self.showGroupService updatePermissions:allowInvitation allowMessage:allowMessage allowInviteMemberAsContact:allowInviteMemberAsContact];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];
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
    
    [abstractConfirmView removeFromSuperview];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.chatViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.chatViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.chatViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *chatViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChatTapGesture:)];
    [self.chatView addGestureRecognizer:chatViewGestureRecognizer];
    
    self.chatRoundedView.backgroundColor = Design.CHAT_COLOR;
    self.chatRoundedView.layer.cornerRadius = self.chatViewWidthConstraint.constant * 0.5;
    
    self.chatImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.chatLabel.font = Design.FONT_REGULAR28;
    self.chatLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.chatLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_chat", nil);
    
    self.videoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.videoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *videoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTapGesture:)];
    [self.videoView addGestureRecognizer:videoViewGestureRecognizer];
    
    self.videoRoundedView.backgroundColor = Design.VIDEO_CALL_COLOR;
    self.videoRoundedView.layer.cornerRadius = self.videoViewWidthConstraint.constant * 0.5;
    
    self.videoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_video", nil);
    
    self.audioViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *audioViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAudioTapGesture:)];
    [self.audioView addGestureRecognizer:audioViewGestureRecognizer];
    
    self.audioRoundedView.backgroundColor = Design.AUDIO_CALL_COLOR;
    self.audioRoundedView.layer.cornerRadius = self.audioViewWidthConstraint.constant * 0.5;
    
    self.audioImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_audio", nil);
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.membersViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.membersView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth  height:self.membersViewHeightConstraint.constant left:false right:false top:true bottom:true];
    self.membersView.userInteractionEnabled = true;
    self.membersView.backgroundColor = Design.WHITE_COLOR;
    
    UITapGestureRecognizer *membersViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersTapGesture:)];
    [self.membersView addGestureRecognizer:membersViewGestureRecognizer];
    self.membersLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.membersLabel.font = Design.FONT_BOLD26;
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_member", nil).uppercaseString;
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *inviteViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInviteTapGesture:)];
    [self.inviteView addGestureRecognizer:inviteViewGestureRecognizer];
    
    self.inviteLabel.font = Design.FONT_BOLD28;
    self.inviteLabel.textColor = Design.MAIN_COLOR;
    self.inviteLabel.text = [NSString stringWithFormat:@"+ %@", TwinmeLocalizedString(@"add_group_member_view_controller_add", nil)];
    
    self.membersCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = MIN(DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO, roundf((Design.DISPLAY_WIDTH - (self.membersCollectionViewLeadingConstraint.constant * 2)) / 6));
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.membersCollectionView setUserInteractionEnabled:NO];
    [self.membersCollectionView setCollectionViewLayout:viewFlowLayout];
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.membersCollectionView registerNib:[UINib nibWithNibName:@"ShowMemberCell" bundle:nil] forCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER];
    
    self.configurationTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.configurationTitleLabel.font = Design.FONT_BOLD26;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.configurationTitleLabel.text = TwinmeLocalizedString(@"application_configuration", nil).uppercaseString;
    
    self.permissionsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.permissionsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *permissionsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePermissionsTapGesture:)];
    [self.permissionsView addGestureRecognizer:permissionsViewGestureRecognizer];
    
    [self.permissionsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.permissionsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.permissionsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.permissionsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.permissionsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.permissionsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.permissionsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.permissionsLabel.text = TwinmeLocalizedString(@"settings_view_controller_authorization_title", nil);
    self.permissionsLabel.font = Design.FONT_REGULAR34;
    self.permissionsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.permissionsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.permissionsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.permissionsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.permissionsAccessoryView.image = [self.permissionsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.callsSettingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *callsSettingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCallsSettingsTapGesture:)];
    [self.callsSettingsView addGestureRecognizer:callsSettingsViewGestureRecognizer];
    
    [self.callsSettingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.callsSettingsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.callsSettingsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callsSettingsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.callsSettingsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.callsSettingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callsSettingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.callsSettingsLabel.text = TwinmeLocalizedString(@"contact_capabilities_view_controller_call_settings", nil);
    self.callsSettingsLabel.font = Design.FONT_REGULAR34;
    self.callsSettingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.callsSettingsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.callsSettingsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.callsSettingsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.callsSettingsAccessoryView.image = [self.callsSettingsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.historyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_history_title", nil).uppercaseString;
    
    self.lastCallAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.lastCallAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.lastCallAccessoryView.image = [self.lastCallAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.lastCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lastCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *lastCallViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLastCallsTapGesture:)];
    [self.lastCallView addGestureRecognizer:lastCallViewGestureRecognizer];
    
    [self.lastCallView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.lastCallViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.lastCallImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lastCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_last_calls", nil);
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.conversationsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.text = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
    
    self.filesViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.filesViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *filesViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilesTapGesture:)];
    [self.filesView addGestureRecognizer:filesViewGestureRecognizer];
    
    [self.filesView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.filesViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.filesImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.filesLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.filesLabel.text = TwinmeLocalizedString(@"conversation_files_view_controller_title", nil);
    self.filesLabel.font = Design.FONT_REGULAR34;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.filesAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.filesAccessoryView.image = [self.filesAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.exportViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *exportViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExportTapGesture:)];
    [self.exportView addGestureRecognizer:exportViewGestureRecognizer];
    
    [self.exportView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.exportViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.exportImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.exportLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.exportLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_export_contents", nil);
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.exportAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.exportAccessoryView.image = [self.exportAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.cleanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cleanViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCleanTapGesture:)];
    [self.cleanView addGestureRecognizer:cleanViewGestureRecognizer];
    
    [self.cleanView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.cleanViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.cleanImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.cleanLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cleanLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.cleanAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.cleanAccessoryView.image = [self.cleanAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.fallbackView.backgroundColor = Design.WHITE_COLOR;
    self.fallbackView.hidden = YES;
    
    self.fallbackImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.fallbackImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.fallbackImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fallbackLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.fallbackLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fallbackLabel.font = Design.FONT_MEDIUM34;
    self.fallbackLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fallbackLabel.text = TwinmeLocalizedString(@"application_group_not_found", nil);
    
    self.fallbackView.hidden = YES;
    
    if (![self.group hasPeer]) {
        self.scrollView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.fallbackView.hidden = NO;
        self.backClickableView.hidden = YES;
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.showGroupService) {
        [self.showGroupService dispose];
        self.showGroupService = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    if (self.toRootView) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleChatTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleChatTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && self.uiMembers.count > 1 && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationViewController *conversationViewController = (ConversationViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:self.group];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)handleVideoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleVideoTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall) {
        [self showPremiumFeatureAlertView];
    }
}

- (void)handleAudioTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAudioTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall) {
        [self showPremiumFeatureAlertView];
    }
}

- (void)showPremiumFeatureAlertView {
    DDLogVerbose(@"%@ showPremiumFeatureAlertView", LOG_TAG);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall] parentViewController:self.navigationController];
    [self.navigationController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (void)handleMembersTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleMembersTapGesture", LOG_TAG);
    
    if (self.groupConversation.state == TLGroupConversationStateJoined) {
        GroupMemberViewController *groupMemberViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
        [groupMemberViewController initWithGroup:self.group];
        [self.navigationController pushViewController:groupMemberViewController animated:YES];
    }
}

- (void)handleInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteTapGesture: %@", LOG_TAG, sender);

    if (sender.state == UIGestureRecognizerStateEnded && self.groupConversation.state == TLGroupConversationStateJoined) {
        if (!self.canInvite) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"group_member_view_controller_admin_not_authorize", nil)];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        } else {
            AddGroupMemberViewController *addGroupMemberViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupMemberViewController"];
            [addGroupMemberViewController initWithMembers:self.uiMembers fromCreateGroup:NO];
            [addGroupMemberViewController initWithGroup:self.group];
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:addGroupMemberViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
            self.startModal = YES;
        }
    }
}

- (void)handlePermissionsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlePermissionsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        SettingsGroupViewController *settingsGroupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsGroupViewController"];
        settingsGroupViewController.delegate = self;
        [settingsGroupViewController initWithGroup:self.group];
        [self.navigationController pushViewController:settingsGroupViewController animated:YES];
    }
}

- (void)handleCallsSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCallsSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        GroupCapabilitiesViewController *groupCapabilitiesViewController = (GroupCapabilitiesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupCapabilitiesViewController"];
        [groupCapabilitiesViewController initWithGroup:self.group];
        [self.navigationController pushViewController:groupCapabilitiesViewController animated:YES];
    }
}

- (void)handleLastCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLastCallsTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        LastCallsViewController *lastCallsViewController = (LastCallsViewController *)[[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"LastCallsViewController"];
        [lastCallsViewController initWithOriginator:self.group callReceiver:NO];
        [self.navigationController pushViewController:lastCallsViewController animated:YES];
    }
}

- (void)handleFilesTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleFilesTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationFilesViewController *conversationFilesViewController = (ConversationFilesViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationFilesViewController"];
        [conversationFilesViewController initWithOriginator:self.group];
        [self.navigationController pushViewController:conversationFilesViewController animated:YES];
    }
}

- (void)handleExportTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleExportTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ExportViewController *exportViewController = (ExportViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
        [exportViewController initExportWithGroup:self.group];
        [self.navigationController pushViewController:exportViewController animated:YES];
    }
}

- (void)handleCleanTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCleanTapGesture: %@", LOG_TAG, sender);
    
    if (self.group && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        TypeCleanUpViewController *typeCleanupViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
        [typeCleanupViewController initCleanUpWithGroup:self.group];
        [self.navigationController pushViewController:typeCleanupViewController animated:YES];
    }
}

- (void)updateGroup {
    DDLogVerbose(@"%@ updateGroup", LOG_TAG);
    
    if (!self.group.hasPeer) {
        self.scrollView.hidden = YES;
        self.fallbackView.hidden = NO;
        self.backClickableView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        [self setNavigationTitle:self.group.name];
        return;
    }
        
    [self.membersCollectionView reloadData];
    
    self.identityLabel.text = self.group.identityName;
    
    NSString *groupDescription;
    
    if (self.group.objectDescription.length > 0) {
        groupDescription = self.group.objectDescription;
    } else {
        groupDescription = self.group.peerDescription;
    }
    
    if ([groupDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionLabel.text = @"";
    } else {
        self.descriptionLabel.text = groupDescription;
    }
    
    [self.showGroupService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
        self.identityAvatarView.image = image;
    }];
    
    self.avatarPlaceholderImageView.hidden = YES;
    
    if (self.group.hasPeer) {
        self.nameLabel.text = self.group.name;
        
        if (self.group.avatarId) {
            if (self.avatar) {
                self.avatarView.image = self.avatar;
            } else {
                [self.showGroupService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                    self.avatarView.image = image;
                }];
            }
        } else {
            self.avatarPlaceholderImageView.hidden = NO;
            self.avatarView.backgroundColor = Design.EDIT_AVATAR_BACKGROUND_COLOR;
        }
    }
    
    if (self.canInvite) {
        self.inviteView.alpha = 1.0f;
    } else {
        self.inviteView.alpha = 0.5f;
    }
    
    if ([self.group isOwner]) {
        self.configurationTitleLabel.hidden = NO;
        self.permissionsView.hidden = NO;
        self.callsSettingsView.hidden = NO;
    } else {
        self.configurationTitleLabel.hidden = YES;
        self.permissionsView.hidden = YES;
        self.callsSettingsView.hidden = YES;
        
        self.configurationTitleLabelTopConstraint.constant = 0;
        self.permissionsViewTopConstraint.constant = 0;
        self.permissionsViewHeightConstraint.constant = 0;
        self.callsSettingsViewHeightConstraint.constant = 0;
        self.configurationTitleLabel.font = [UIFont systemFontOfSize:0];
    }
    
    [self updateInCall];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.membersCollectionView reloadData];
        });
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.chatLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.fallbackLabel.font = Design.FONT_MEDIUM_ITALIC36;
    self.membersLabel.font = Design.FONT_BOLD26;
    self.inviteLabel.font = Design.FONT_BOLD28;
    self.configurationTitleLabel.font = Design.FONT_BOLD26;
    self.permissionsLabel.font = Design.FONT_REGULAR34;
    self.callsSettingsLabel.font = Design.FONT_REGULAR34;
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.chatLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fallbackLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.textColor = Design.MAIN_COLOR;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.permissionsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.callsSettingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (BOOL)hasSchedule {
    DDLogVerbose(@"%@ hasSchedule", LOG_TAG);
    
    if (self.group.capabilities.schedule && self.group.capabilities.schedule.enabled) {
        return ![self.group.capabilities.schedule isNowInRange];
    }
    
    return NO;
}

- (void)showSchedule {
    DDLogVerbose(@"%@ showSchedule", LOG_TAG);
    
    NSString *message = @"";
    
    TLSchedule *schedule = self.group.capabilities.schedule;
    
    if (schedule && schedule.timeRanges.count > 0) {
        TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[schedule.timeRanges objectAtIndex:0];
        TLDateTime *start = dateTimeRange.start;
        TLDateTime *end = dateTimeRange.end;
        
        if ([start.date isEqual:end.date]) {
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"show_call_view_controller_schedule_from_to", nil), [start.date formatDate], [start.time formatTime], [end.time formatTime]];
        } else {
            message = [NSString stringWithFormat:@"%@ %@", [start formatDateTime], [end formatDateTime]];
        }
    } else {
        message = TwinmeLocalizedString(@"show_call_view_controller_schedule_message", nil);
    }
            
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"show_call_view_controller_schedule_call", nil) message:message];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateInCall {
    DDLogVerbose(@"%@ updateInCall", LOG_TAG);
    
    BOOL inCall = self.twinmeApplication.inCall;
    if (self.uiMembers.count == 1 || self.uiMembers.count > MAX_CALL_GROUP_PARTICIPANTS || !self.group.capabilities.hasAudio  || [self hasSchedule] || inCall) {
        self.audioView.alpha = 0.5f;
    } else {
        self.audioView.alpha = 1.0f;
    }
    
    if (self.uiMembers.count == 1 || self.uiMembers.count > MAX_CALL_GROUP_PARTICIPANTS || !self.group.capabilities.hasVideo  || [self hasSchedule] || inCall) {
        self.videoView.alpha = 0.5f;
    } else {
        self.videoView.alpha = 1.0f;
    }
    
    if (self.uiMembers.count == 1) {
        self.chatView.alpha = 0.5f;
    } else {
        self.chatView.alpha = 1.0f;
    }
}

@end
