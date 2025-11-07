/*
 *  Copyright (c) 2017-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Romain Kolb (romain.kolb@skyrock.com)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Utils/NSString+Utils.h>

#import "NotificationViewController.h"

#import "CellActionView.h"
#import "DeleteConfirmView.h"
#import "NotificationCell.h"
#import "UINotification.h"
#import "UIView+Toast.h"

#import "ConversationViewController.h"
#import "ShowContactViewController.h"
#import "ShowExternalCallViewController.h"
#import "ShowGroupViewController.h"
#import "ShowRoomViewController.h"
#import "AcceptGroupInvitationViewController.h"
#import "AcceptInvitationViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/GroupService.h>
#import <TwinmeCommon/NotificationService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "UIViewController+ProgressIndicator.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_CELL_HEIGHT = 124;

static NSString *NOTIFICATION_CELL_IDENTIFIER = @"NotificationCellIdentifier";

//
// Interface: NotificationViewController ()
//

@class NotificationViewControllerNotificationServiceDelegate;

@interface NotificationViewController () <NotificationServiceDelegate, GroupServiceDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noNotificationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noNotificationTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noNotificationLabel;
@property (nonatomic) UIBarButtonItem *resetNotificationBarButtonItem;

@property (nonatomic) NSMutableArray<UINotification *> *notifications;
@property (nonatomic) NSIndexPath* deletedIndexPath;
@property (nonatomic) BOOL updateMessageCell;

@property (nonatomic) NotificationService *notificationService;
@property (nonatomic) GroupService *groupService;

@property (nonatomic) BOOL openGroupFromNotification;
@property (nonatomic) BOOL resetAllNotification;
@property (nonatomic) TLNotification *selectedNotification;

@property (nonatomic) BOOL needsRefresh;
@property (nonatomic) BOOL refreshTableScheduled;

- (nonnull UINotification *)createUINotification:(nonnull TLNotification *)notification;

@end

//
// Implementation: NotificationViewController
//

#undef LOG_TAG
#define LOG_TAG @"NotificationViewController"

@implementation NotificationViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _notifications = [[NSMutableArray alloc] init];
        
        _notificationService = [[NotificationService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _groupService = [[GroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _openGroupFromNotification = NO;
        _resetAllNotification = NO;
        _needsRefresh = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UISceneDidActivateNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    if (self.needsRefresh) {
        self.needsRefresh = NO;
        [self.notificationService getNotifications];
    }
    
    [self setLeftBarButtonItem:self.notificationService profile:self.defaultProfile];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    self.needsRefresh = YES;
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    return NO;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationDidEnterBackground", LOG_TAG);
    
    self.needsRefresh = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationDidBecomeActive", LOG_TAG);
    
    if (self.needsRefresh) {
        self.needsRefresh = NO;
        [self.notificationService getNotifications];
    }
}

#pragma mark - NotificationServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.notificationService profile:space.profile];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.notificationService profile:space.profile];
}

- (void)onGetNotifications:(NSArray *)notifications {
    DDLogVerbose(@"%@ onGetNotifications: %@", LOG_TAG, notifications);
    
    [self.notifications removeAllObjects];
    self.refreshTableScheduled = YES;
    for (TLNotification *notification in notifications) {
        [self addNotification:notification];
    }

    [self reloadData];
}

- (void)onAddNotification:(TLNotification *)notification {
    DDLogVerbose(@"%@ onAddNotification: %@", LOG_TAG, notification);

    self.refreshTableScheduled = YES;
    [self addNotification:notification];
    [self reloadData];
}

- (void)onAcknowledgeNotification:(TLNotification *)notification {
    DDLogVerbose(@"%@ onAcknowledgeNotification: %@", LOG_TAG, notification);
    
    NSInteger count = self.notifications.count;
    for (NSInteger i = 0; i < count; i++) {
        TLNotification *lNotification = [self.notifications[i] getLastNotification];
        if ([lNotification.uuid isEqual:notification.uuid]) {
            [self.notifications replaceObjectAtIndex:i withObject:[self createUINotification:notification]];
            break;
        }
    }
}

- (void)onDeleteNotificationsWithList:(nonnull NSArray<NSUUID *> *)list {
    DDLogVerbose(@"%@ onDeleteNotificationsWithList: %@", LOG_TAG, list);
    
    for (NSUUID *notificationId in list) {
        NSInteger count = self.notifications.count;
        for (NSInteger i = 0; i < count; i++) {
            UINotification *uiNotification = self.notifications[i];

            if ([uiNotification removeNotification:notificationId]) {
                [self.tableView beginUpdates];
                NSUInteger index = [self.notifications count] - i - 1;
                if ([uiNotification getCount] == 0) {
                    [self.notifications removeObjectAtIndex:i];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
                [self.tableView endUpdates];
                break;
            }
        }
    }
    
    if (self.resetAllNotification && self.notifications.count == 0) {
        self.resetAllNotification = NO;
        self.resetNotificationBarButtonItem.enabled = NO;
        [self hideProgressIndicator];
        [self reloadData];
    } else if (self.notifications.count == 0) {
        [self reloadData];
    }
}

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@ onAddNotification: %@", LOG_TAG, hasPendingNotifications ? @"YES" : @"NO");
    
}

#pragma mark - GroupServiceDelegate

- (void) onGetGroup:(TLGroup *)group groupMembers:(NSArray<TLGroupMember *> *)groupMembers conversation:(id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onGetGroup: %@ groupMembers:%@ conversation:%@", LOG_TAG, group, groupMembers,conversation);
    
    if (self.openGroupFromNotification) {
        self.openGroupFromNotification = NO;
        
        ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:group];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)onErrorGroupNotFound {
    DDLogVerbose(@"%@ onErrorGroupNotFound", LOG_TAG);
    
    if (self.openGroupFromNotification) {
        self.openGroupFromNotification = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_group_not_found",nil)];
        });
    }
}

- (void)showProgressIndicator {
    DDLogVerbose(@"%@ showProgressIndicator", LOG_TAG);
    [super showProgressIndicator];
}

- (void)hideProgressIndicator {
    DDLogVerbose(@"%@ hideProgressIndicator", LOG_TAG);
    [super hideProgressIndicator];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    NSUInteger index = [self.notifications count] - indexPath.row - 1;
    UINotification *notification = [self.notifications objectAtIndex:index];
    
    NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:NOTIFICATION_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NOTIFICATION_CELL_IDENTIFIER];
    }
    
    BOOL hideSeparator = indexPath.row + 1 == [self.notifications count] ? YES : NO;

    [cell bindNotification:notification hideSeparator:hideSeparator];
    [cell setNeedsLayout];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ willDisplayCell: %@ forRowAtIndexPath: %@", LOG_TAG, tableView, cell, indexPath);
    
    NSUInteger index = [self.notifications count] - indexPath.row - 1;
    
    UINotification *uiNotification = [self.notifications objectAtIndex:index];
    TLNotification *notification = [uiNotification getLastNotification];
    
    switch (notification.notificationType) {
        case TLNotificationTypeMissedVideoCall:
        case TLNotificationTypeMissedAudioCall:
        case TLNotificationTypeNewContact:
        case TLNotificationTypeUpdatedContact:
        case TLNotificationTypeUpdatedAvatarContact:
        case TLNotificationTypeDeletedContact:
        case TLNotificationTypeNewGroupJoined:
        case TLNotificationTypeResetConversation: {
            if (![uiNotification isAcknowledged]) {
                NSInteger count = [uiNotification getCount];
                for (NSInteger i = 0; i < count; i++) {
                    TLNotification *lNotification = [uiNotification.notifications objectAtIndex:i];
                    [self.notificationService acknowledgeNotification:lNotification];
                }
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger index = [self.notifications count] - indexPath.row - 1;
    UINotification *uiNotification = [self.notifications objectAtIndex:index];
    TLNotification *notification = [uiNotification getLastNotification];
    if (![notification acknowledged]) {
        NSInteger count = [uiNotification getCount];
        for (NSInteger i = 0; i < count; i++) {
            TLNotification *lNotification = [uiNotification.notifications objectAtIndex:i];
            [self.notificationService acknowledgeNotification:lNotification];
        }
    }
    
    [self redirectToViewControllerWithNotification:notification];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ trailingSwipeActionsConfigurationForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    // Get the notification now since the list could change while contextualActionWithStyle executes.
    NSUInteger index = [self.notifications count] - indexPath.row - 1;
    UINotification *uiNotification = [self.notifications objectAtIndex:index];
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        NSInteger count = [uiNotification getCount];
        for (NSInteger i = 0; i < count; i++) {
            TLNotification *lNotification = [uiNotification.notifications objectAtIndex:i];
            [self.notificationService deleteNotification:lNotification];
        }
    }];
    
    CellActionView *deleteActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"application_remove", nil) icon:@"ToolbarTrash" backgroundColor:[UIColor clearColor] iconWidth:32 iconHeight:38 iconTopMargin:28];
    deleteAction.image = [deleteActionView imageFromView];
    deleteAction.backgroundColor = Design.DELETE_COLOR_RED;
    
    UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
    
    return swipeActionConfiguration;
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    self.resetAllNotification = YES;
    self.resetNotificationBarButtonItem.enabled = NO;
    [self showProgressIndicator];
    
    NSInteger count = self.notifications.count;
    for (NSInteger i = 0; i < count; i++) {
        UINotification *uiNotification = [self.notifications objectAtIndex:i];
        NSInteger count2 = [uiNotification getCount];
        for (NSInteger j = 0; j < count2; j++) {
            TLNotification *lNotification = [uiNotification.notifications objectAtIndex:j];
            [self.notificationService deleteNotification:lNotification];
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
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_notifications", nil)];
    
    self.resetNotificationBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(handleResetTapGesture:)];
    self.resetNotificationBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"notification_view_controller_reset_title", nil);
    self.resetNotificationBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.resetNotificationBarButtonItem;
    
    self.tableView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationCell" bundle:nil] forCellReuseIdentifier:NOTIFICATION_CELL_IDENTIFIER];
    
    self.noNotificationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noNotificationImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noNotificationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noNotificationImageView.hidden = YES;
    
    self.noNotificationTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noNotificationTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noNotificationTitleLabel.font = Design.FONT_MEDIUM34;
    self.noNotificationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noNotificationTitleLabel.text = TwinmeLocalizedString(@"notification_view_controller_no_notification_title", nil);
    self.noNotificationTitleLabel.hidden = YES;
    
    self.noNotificationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noNotificationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noNotificationLabel.font = Design.FONT_MEDIUM28;
    self.noNotificationLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noNotificationLabel.text = TwinmeLocalizedString(@"notification_view_controller_no_notification_message", nil);
    self.noNotificationLabel.hidden = YES;
}

- (void)addNotification:(TLNotification *)notification {
    DDLogVerbose(@"%@ addNotification: %@", LOG_TAG, notification);
    
    NSInteger count = self.notifications.count;
    for (NSInteger i = 0; i < count; i++) {
        TLNotification *lNotification = [self.notifications[i] getLastNotification];
        if (lNotification.timestamp < notification.timestamp) {
            continue;
        }
        [self.notifications insertObject:[self createUINotification:notification] atIndex:i];
        return;
    }
    [self.notifications addObject:[self createUINotification:notification]];
    
    if (self.notifications.count > 0) {
        self.resetNotificationBarButtonItem.enabled = YES;
    }
}

- (void)onReadNotification:(TLNotification *)notification {
    DDLogVerbose(@"%@ onReadNotification: %@", LOG_TAG, notification);
    
    if ([self.navigationController.topViewController isKindOfClass:[NotificationViewController class]]) {
        [self redirectToViewControllerWithNotification:notification];
    }
}

- (void)redirectToViewControllerWithNotification:(TLNotification *)notification {
    DDLogVerbose(@"%@ redirectToViewControllerWithNotification: %@", LOG_TAG, notification);
    
    id<TLRepositoryObject> subject = notification.subject;
    switch (notification.notificationType) {
        case TLNotificationTypeNewTextMessage:
        case TLNotificationTypeNewImageMessage:
        case TLNotificationTypeNewAudioMessage:
        case TLNotificationTypeNewVideoMessage:
        case TLNotificationTypeNewFileMessage:
        case TLNotificationTypeUpdatedAnnotation:
        case TLNotificationTypeResetConversation: {
            if ([subject isKindOfClass:[TLGroup class]]) {
                self.openGroupFromNotification = YES;
                self.selectedNotification = notification;
                [self.groupService getGroupWithGroupId:subject.objectId];
            } else if ([subject isKindOfClass:[TLGroupMember class]]) {
                self.openGroupFromNotification = YES;
                self.selectedNotification = notification;
                TLGroupMember *groupMember = (TLGroupMember *)subject;
                [self.groupService getGroupWithGroupId:groupMember.group.uuid];
            } else if ([subject conformsToProtocol:@protocol(TLOriginator)]) {
                ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
                [conversationViewController initWithContact:(id<TLOriginator>) subject];
                [self.navigationController pushViewController:conversationViewController animated:YES];
            }
            break;
        }
            
        case TLNotificationTypeMissedVideoCall:
        case TLNotificationTypeMissedAudioCall:
        case TLNotificationTypeNewContact:
        case TLNotificationTypeUpdatedContact:
        case TLNotificationTypeUpdatedAvatarContact:
        case TLNotificationTypeDeletedContact: {
            
            if ([subject isKindOfClass:[TLCallReceiver class]]) {
                TLCallReceiver *callReceiver = (TLCallReceiver *)subject;
                if (callReceiver) {
                    ShowExternalCallViewController *showExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowExternalCallViewController"];
                    [showExternalCallViewController initWithCallReceiver:callReceiver];
                    [self.navigationController pushViewController:showExternalCallViewController animated:YES];
                }
            } else if ([subject isKindOfClass:[TLGroup class]]) {
                TLGroup * group = (TLGroup *)subject;
                ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
                [showGroupViewController initWithGroup:group];
                [self.navigationController pushViewController:showGroupViewController animated:YES];
            } else if ([subject conformsToProtocol:@protocol(TLOriginator)]) {
                TLContact * contact = (TLContact *)subject;
                if (contact.isTwinroom) {
                    ShowRoomViewController *showRoomViewController = [[UIStoryboard storyboardWithName:@"Room" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowRoomViewController"];
                    [showRoomViewController initWithRoom:contact];
                    [self.navigationController pushViewController:showRoomViewController animated:YES];
                } else if (contact) {
                    ShowContactViewController *showContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
                    [showContactViewController initWithContact:contact];
                    [self.navigationController pushViewController:showContactViewController animated:YES];
                }
            }
            
            break;
        }
            
        case TLNotificationTypeNewGroupJoined: {
            self.openGroupFromNotification = YES;
            [self.groupService getGroupWithGroupId:subject.objectId];
            break;
        }
            
        case TLNotificationTypeNewGroupInvitation: {
            AcceptGroupInvitationViewController *acceptGroupInvitationViewController = (AcceptGroupInvitationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AcceptGroupInvitationViewController"];
            [acceptGroupInvitationViewController initWithInvitationId:notification.descriptorId contactId:subject.objectId];
            [acceptGroupInvitationViewController showInView:self.tabBarController.view];
            [self reloadData];
            break;
        }
            
        case TLNotificationTypeNewContactInvitation: {
            AcceptInvitationViewController *acceptInvitationViewController = (AcceptInvitationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
            [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:notification.descriptorId  originatorId:subject.objectId isGroup:[(NSObject *)subject isKindOfClass:[TLGroup class]] notification:notification popToRootViewController:NO];
            [acceptInvitationViewController showInView:self.tabBarController.view];
            [self reloadData];
            break;
        }
            
        case TLNotificationTypeDeletedGroup:
        default:
            break;
    }
}

- (void)handleResetTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (self.notifications.count > 0) {
        [self.notificationService getImageWithProfile:self.currentSpace.profile withBlock:^(UIImage *image) {
            DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
            deleteConfirmView.confirmViewDelegate = self;
            deleteConfirmView.deleteConfirmType = DeleteConfirmTypeHistory;
            NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"application_operation_irreversible", nil), TwinmeLocalizedString(@"notification_view_controller_reset", nil)];
            [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:image icon:[UIImage imageNamed:@"ActionBarDelete"]];
            [deleteConfirmView setConfirmTitle:TwinmeLocalizedString(@"notification_view_controller_reset_title", nil)];
            
            [self.tabBarController.view addSubview:deleteConfirmView];
            [deleteConfirmView showConfirmView];
        }];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.groupService dispose];
    [self.notificationService dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.noNotificationTitleLabel.font = Design.FONT_MEDIUM34;
    self.noNotificationLabel.font = Design.FONT_MEDIUM28;
    [self reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.noNotificationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noNotificationLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.tableView.backgroundColor = Design.WHITE_COLOR;
}

- (nonnull UINotification *)createUINotification:(nonnull TLNotification *)notification {
    DDLogVerbose(@"%@ createUINotification: %@", LOG_TAG, notification);
    
    id<TLRepositoryObject> subject = notification.subject;
    UINotification *uiNotification = [[UINotification alloc] initWithNotification:[NSMutableArray arrayWithObject:notification] avatar:[TLTwinmeAttributes DEFAULT_AVATAR]];
    
    if ([subject isKindOfClass:[TLGroup class]]) {
        if (notification.descriptorId) {
            [self.notificationService getGroupMemberWithNotification:notification withBlock:^(TLGroupMember* groupMember, UIImage *image) {
                uiNotification.avatar = image;
                uiNotification.groupMember = groupMember;
                [self refreshTable];
            }];
        } else {
            [self.notificationService getImageWithGroup:(TLGroup *)subject withBlock:^(UIImage *image) {
                uiNotification.avatar = image;
                [self refreshTable];
            }];
        }
    } else if ([subject isKindOfClass:[TLContact class]]) {
        if (![(TLContact *)subject hasPeer]) {
            uiNotification.avatar = [TLTwinmeAttributes DEFAULT_AVATAR];
        } else {
            TLContact *contact = (TLContact *)subject;
            uiNotification.isCertifiedContact = [contact certificationLevel] == TLCertificationLevel4;
            [self.notificationService getImageWithContact:(TLContact *)subject withBlock:^(UIImage *image) {
                uiNotification.avatar = image;
                [self refreshTable];
            }];
        }
    } else if ([subject isKindOfClass:[TLCallReceiver class]]) {
        [self.notificationService getImageWithCallReceiver:(TLCallReceiver *)subject withBlock:^(UIImage *image) {
            uiNotification.avatar = image;
            [self refreshTable];
        }];
    } else if ([subject isKindOfClass:[TLGroupMember class]]) {
        uiNotification.groupMember = (TLGroupMember *)subject;
        [self.notificationService getImageWithGroupMember:(TLGroupMember *)subject withBlock:^(UIImage *image) {
            uiNotification.avatar = image;
            [self refreshTable];
        }];
    }
    
    if (notification.user.avatarId) {
        [self.notificationService getImageWithImageId:notification.user.avatarId withBlock:^(UIImage *image) {
            uiNotification.annotationAvatar = image;
            [self refreshTable];
        }];
    }

    return uiNotification;
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    self.refreshTableScheduled = YES;
    if (self.notifications.count > 1) {
        NSMutableArray<UINotification *> *uiNotifications = [NSMutableArray arrayWithArray:self.notifications];
        UINotification *uiNotification = [uiNotifications lastObject];
                
        int index = (int)[self.notifications count] - 2;
        [self.notifications removeAllObjects];
        
        while (index >= 0) {
            UINotification *uiNotification2 = [uiNotifications objectAtIndex:index];
            
            if ([uiNotification sameNotification:uiNotification2]) {
                for (int i = (int)[uiNotification getCount] - 1; i >= 0; i--) {
                    [uiNotification2 addNotification:[uiNotification.notifications objectAtIndex:i]];
                }
            } else {
                [self.notifications insertObject:uiNotification atIndex:0];
            }
            
            if (index == 0) {
                [self.notifications insertObject:uiNotification2 atIndex:0];
            } else {
                uiNotification = uiNotification2;
            }
            
            index--;
        }
    }
    
    self.refreshTableScheduled = NO;
    [self.tableView reloadData];
    
    if (self.notifications.count == 0) {
        self.noNotificationImageView.hidden = NO;
        self.noNotificationTitleLabel.hidden = NO;
        self.noNotificationLabel.hidden = NO;
        self.resetNotificationBarButtonItem.enabled = NO;
        self.tableView.hidden = YES;
    } else {
        self.noNotificationImageView.hidden = YES;
        self.noNotificationTitleLabel.hidden = YES;
        self.noNotificationLabel.hidden = YES;
        self.resetNotificationBarButtonItem.enabled = YES;
        self.tableView.hidden = NO;
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of notification images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.tableView reloadData];
        });
    }
}

@end
