/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <UserNotifications/UserNotifications.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLInvocation.h>
#import <Twinme/TLPairInviteInvocation.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "AddProfileViewController.h"
#import "AddContactViewController.h"
#import "ConversationsViewController.h"
#import "ConversationViewController.h"
#import "NewConversationViewController.h"
#import "ShowContactViewController.h"
#import "ShowGroupViewController.h"
#import "ShowRoomViewController.h"
#import "QualityOfServicesViewController.h"
#import "AccountMigrationScannerViewController.h"

#import "ConversationCell.h"
#import "SearchContentMessageCell.h"
#import "ContactCell.h"
#import "EnableNotificationCell.h"
#import "SearchSectionCell.h"
#import "SearchSectionFooterCell.h"
#import "UIConversation.h"
#import "UIContact.h"
#import "UICustomTab.h"

#import "UIGroupConversation.h"

#import <TwinmeCommon/ChatService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "CellActionView.h"
#import "CustomTabView.h"
#import "ResetConversationConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *CONVERSATION_CELL_IDENTIFIER = @"ConversationCellIdentifier";
static NSString *CONTACT_CELL_IDENTIFIER = @"ContactCellIdentifier";
static NSString *SEARCH_SECTION_CELL_IDENTIFIER = @"SearchSectionCellIdentifier";
static NSString *SEARCH_SECTION_FOOTER_CELL_IDENTIFIER = @"SearchSectionFooterCellIdentifier";
static NSString *SEARCH_CONTENT_MESSAGE_CELL_IDENTIFIER = @"SearchContentMessageCellIdentifier";
static NSString *ENABLE_NOTIFICATION_CELL_IDENTIFIER = @"EnableNotificationCellIdentifier";

static CGFloat DESIGN_NO_CONTACT_IMAGE_HEIGHT = 480;
static CGFloat DESIGN_NO_CONVERSATION_IMAGE_HEIGHT = 586;

static CGFloat DESIGN_SECTION_SEARCH_HEIGHT = 90;
static CGFloat DESIGN_SECTION_FOOTER_SEARCH_HEIGHT = 60;
static CGFloat DESIGN_CELL_HEIGHT = 124;
// static CGFloat DESIGN_NOTIFICATION_CELL_HEIGHT = 208;
static CGFloat DESIGN_CELL_MARGIN_LINE = 2;
static CGFloat DESIGN_CELL_NAME_MARGIN = 16;

static const int CONVERSATIONS_VIEW_SECTION_COUNT = 1;
static const int SEARCH_VIEW_SECTION_COUNT = 3;
static const int MIN_RESULTS_VISIBLE = 3;

// Number of conversation to sort on the usage score and display at the top of the list.
static int MOST_USED_CONVERSATION_COUNT = 0;

// Number of conversation to sort on the last message date and display below the most used part.
static int LAST_USED_CONVERSATION_COUNT = 99999;

//
// Interface: ConversationsViewController
//

@interface ConversationsViewController () <UITableViewDataSource, UITableViewDelegate, ChatServiceDelegate, UISearchBarDelegate, UISearchControllerDelegate, ConversationsActionDelegate, ConfirmViewDelegate, CustomTabViewDelegate, SearchSectionDelegate, EnableNotificationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *conversationsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noConversationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noConversationLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noConversationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *startConversationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startConversationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startConversationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteContactView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteContactLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *inviteContactLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *transferLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *transferView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *customTabContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noResultFoundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundLabel;

@property (nonatomic) CustomTabView *customTabView;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) UIBarButtonItem *addChatBarButtonItem;
@property (nonatomic) ResetConversationConfirmView *resetConversationConfirmView;

@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, UIContact *> *uiContacts;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, UIContact *> *uiGroups;
@property (nonatomic, readonly, nonnull) NSMutableArray<UIConversation *> *uiConversations;
@property (nonatomic) NSArray<UIConversation *> *filteredConversations;
@property (nonatomic) NSMutableArray<UIConversation *> *searchContentConversations;
@property (nonatomic) NSMutableArray<UIConversation *> *searchContacts;
@property (nonatomic) NSMutableArray<UIConversation *> *searchGroups;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, UIConversation *> *uiConversationsMap;

@property (nonatomic) NSMutableDictionary<NSUUID*,TLGroupMember*> *groupMembers;
@property (nonatomic) NSMutableDictionary<NSUUID*,UIImage*> *groupMembersAvatar;
@property (nonatomic) NSMutableDictionary<NSUUID*,UIGroupConversation*> *membersToGroupConversations;
@property (nonatomic) UIConversation *resetConversation;

@property (nonatomic) ChatService *chatService;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL onlyGroups;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL isNotificationEnabled;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL showAllContacts;
@property (nonatomic) BOOL showAllGroups;

@property (nonatomic) SearchFilter searchFilter;
@property (nonatomic) NSMutableArray<UICustomTab *> *customTabs;

@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGFloat cellNameMargin;

@end

//
// Implementation: ConversationsViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationsViewController"

@implementation ConversationsViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableDictionary alloc] init];
        _uiGroups = [[NSMutableDictionary alloc] init];
        _uiConversations = [[NSMutableArray alloc] init];
        _groupMembers = [[NSMutableDictionary alloc] init];
        _groupMembersAvatar = [[NSMutableDictionary alloc] init];
        _uiConversationsMap = [[NSMutableDictionary alloc] init];
        _membersToGroupConversations = [[NSMutableDictionary alloc] init];
        _chatService = [[ChatService alloc] initWithTwinmeContext:self.twinmeContext callsMode:[self.twinmeApplication displayCallsMode] delegate:self];
        _needRefresh = NO;
        _visible = NO;
        _onlyGroups = NO;
        _keyboardHidden = YES;
        _isNotificationEnabled = NO;
        _showAllContacts = NO;
        _showAllGroups = NO;
        _cellHeight = 0;
        _cellNameMargin = 0;
        _searchFilter = SearchFilterAll;
        _customTabs = [[NSMutableArray alloc]init];
        _searchContentConversations = [[NSMutableArray alloc] init];
        _searchContacts = [[NSMutableArray alloc] init];
        _searchGroups = [[NSMutableArray alloc] init];
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
    
    self.visible = YES;
    self.cellHeight = 0;
    
    [super viewWillAppear:animated];
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.chatService getConversationsWithCallsMode:[self.twinmeApplication displayCallsMode]];
    }
    
    [self reloadData];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL notificatonEnable;
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                notificatonEnable = YES;
            } else {
                notificatonEnable = NO;
            }
            
            if (notificatonEnable != self.isNotificationEnabled) {
                self.isNotificationEnabled = notificatonEnable;
                [self reloadData];
            }
        });
    }];
    
    [self setLeftBarButtonItem:self.chatService profile:self.defaultProfile];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = YES;
    self.visible = NO;
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    return NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.conversationsTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.searchTableViewBottomConstraint.constant = self.conversationsTableViewBottomConstraint.constant;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.conversationsTableViewBottomConstraint.constant = 0;
    self.searchTableViewBottomConstraint.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    self.conversationsTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.searchTableViewBottomConstraint.constant = self.conversationsTableViewBottomConstraint.constant;
}

#pragma mark - ChatServiceDelegate

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    [self reloadData];
    [self setLeftBarButtonItem:self.chatService profile:space.profile];
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
    [navigationController setNavigationBarStyle];
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);

    [self setLeftBarButtonItem:self.chatService profile:space.profile];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.chatService profile:space.profile];
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    for (TLContact *contact in contacts) {
        UIContact *uiContact = [[UIContact alloc] initWithContact:contact];
        [self.uiContacts setObject:uiContact forKey:contact.uuid];
        if ([contact hasPeer]) {
            [self.chatService getImageWithContact:contact withBlock:^(UIImage *image) {
                [uiContact updateAvatar:image];
                [self refreshTable];
            }];
        }
    }
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
    [self.uiGroups removeAllObjects];
    
    for (TLGroup *group in groups) {
        UIContact *uiContact = [[UIContact alloc] initWithContact:group];
        [self.uiGroups setObject:uiContact forKey:group.uuid];
        [self.chatService getImageWithGroup:group withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    }
}

- (void)onCreateGroup:(TLGroup *)group conversation:(id<TLGroupConversation>)conversation avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateGroup: %@ conversation: %@ avatar: %@", LOG_TAG, group, conversation, avatar);
    
    // Remember the group object but display the group only when it is in the JOINED state.
    // (this may be triggered once the join response is received in onJoinGroup).
    UIContact *uiContact = [[UIContact alloc] initWithContact:group];
    [uiContact updateAvatar:avatar];
    [self.uiGroups setObject:uiContact forKey:group.uuid];
    if ([conversation state] == TLGroupConversationStateJoined) {
        [self onGetOrCreateConversation:conversation];
    }
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    UIContact *uiGroup = self.uiGroups[group.uuid];
    if (uiGroup) {
        [uiGroup setContact:group];
        [uiGroup updateAvatar:avatar];
        [self reloadData];
    }
}

- (void)onDeleteGroup:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
    [self.uiGroups removeObjectForKey:groupId];
}

- (void)onCreateContact:(nonnull TLContact *)contact avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    UIContact *uiContact = [[UIContact alloc] initWithContact:contact];
    [uiContact updateAvatar:avatar];
    [self.uiContacts setObject:uiContact forKey:contact.uuid];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    UIContact *uiContact = self.uiContacts[contact.uuid];
    if (uiContact) {
        [uiContact setContact:contact];
        [uiContact updateAvatar:avatar];
        [self reloadData];
    }
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    [self.uiContacts removeObjectForKey:contactId];
}

- (void)onGetGroupMember:(NSUUID *)groupMemberTwincodeId member:(TLGroupMember *)member avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetGroupMember: %@ member: %@", LOG_TAG, groupMemberTwincodeId, member);
    
    // Member was found, remember it.
    if (member) {
        [self.groupMembers setObject:member forKey:member.peerTwincodeOutboundId];
        [self.groupMembersAvatar setObject:avatar forKey:member.peerTwincodeOutboundId];
    }
    UIGroupConversation *conversation = [self.membersToGroupConversations objectForKey:groupMemberTwincodeId];
    if (conversation) {
        NSMutableArray *remain = [conversation updateVisibleMembers:self.groupMembers groupMemberTwincodeId:groupMemberTwincodeId groupMemberAvatar:avatar];
        
        int indexConversation = -1;
        for (UIConversation *uiConversation in self.uiConversations) {
            indexConversation++;
            if ([uiConversation.conversationId isEqual:conversation.conversationId]) {
                break;
            }
        }
        if (indexConversation != -1) {
            [self.uiConversations replaceObjectAtIndex:indexConversation withObject:conversation];
        }
        
        if (remain.count == 0) {
            [self reloadData];
        }
    }
}

- (void)onJoinGroup:(id <TLGroupConversation>)group memberId:(NSUUID *)memberId {
    DDLogVerbose(@"%@ onJoinGroup: %@ memberId:%@", LOG_TAG, group, memberId);
    
    if ([group state] != TLGroupConversationStateJoined) {
        return;
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[group.uuid];
    if (uiConversation) {
        uiConversation = [[UIGroupConversation alloc] initWithConversationId:group.uuid uiContact:uiConversation.uiContact];
        if ([uiConversation respondsToSelector:@selector(setVisibleMembers:)]) {
            [self updateGroupConversation:group uiConversation:(UIGroupConversation *)uiConversation];
        }
    } else {
        [self onGetOrCreateConversation:group];
    }
}

- (void)onLeaveGroup:(id<TLGroupConversation>)group memberId:(NSUUID *)memberId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberId:%@", LOG_TAG, group, memberId);
    
    if ([group state] != TLGroupConversationStateJoined) {
        return;
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[group.uuid];
    if (uiConversation) {
        [self updateGroupConversation:group uiConversation:(UIGroupConversation *)uiConversation];
    }
}

- (void)onGetConversations:(NSArray<TLConversationDescriptorPair *> *)conversations {
    DDLogVerbose(@"%@ onGetConversations: %@", LOG_TAG, conversations);
    
    [self.uiConversations removeAllObjects];
    
    for (TLConversationDescriptorPair *conversationDescriptor in conversations) {
        id<TLConversation> conversation = conversationDescriptor.conversation;
        if ([conversation isActive]) {
            UIContact *uiContact = ([conversation isGroup] ? self.uiGroups[conversation.contactId] : self.uiContacts[conversation.contactId]);
            UIConversation *uiConversation = uiContact.uiConversation;
            if (uiContact && (!uiConversation || ![uiConversation.conversationId isEqual:conversation.uuid])) {
                if (!conversation.isGroup) {
                    uiConversation = [[UIConversation alloc] initWithConversationId:conversation.uuid uiContact:uiContact];
                } else {
                    id<TLGroupConversation> groupConversation = (id<TLGroupConversation>)conversation;
                    uiConversation = [[UIGroupConversation alloc] initWithConversationId:conversation.uuid uiContact:uiContact groupConversationStateType:groupConversation.state];
                    [self updateGroupConversation:groupConversation uiConversation:(UIGroupConversation *)uiConversation];
                }
                uiContact.uiConversation = uiConversation;
            }
            if (uiConversation) {
                [uiConversation setDescriptor:conversationDescriptor.descriptor];
                
                [self updateUIConversation:uiConversation];
            }
        }
    }
    
    [self reloadData];
}

- (void)onFindConversationsbyName:(NSArray<TLConversationDescriptorPair *> *)conversations {
    DDLogVerbose(@"%@ onFindConversationsbyName: %@", LOG_TAG, conversations);
    
    for (TLConversationDescriptorPair *conversationDescriptor in conversations) {
        id<TLConversation> conversation = conversationDescriptor.conversation;
        UIContact *uiContact = ([conversation isGroup] ? self.uiGroups[conversation.contactId] : self.uiContacts[conversation.contactId]);
        if ([conversation isActive] && uiContact) {
            UIConversation *uiConversation = [[UIConversation alloc]initWithConversationId:conversation.uuid uiContact:uiContact];
            if ([conversation isGroup]) {
                [self.searchGroups addObject:uiConversation];
            } else {
                [self.searchContacts addObject:uiConversation];
            }
        }
    }
    
    if (self.searchContacts.count <= MIN_RESULTS_VISIBLE) {
        self.showAllContacts = YES;
    }
    
    if (self.searchGroups.count <= MIN_RESULTS_VISIBLE) {
        self.showAllGroups = YES;
    }
    
    [self reloadSearchResult];
}

- (void)onGetOrCreateConversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetOrCreateConversation: %@", LOG_TAG, conversation);

    if (!conversation.contactId) {
        return;
    }
    
    [self updateConversation:conversation];
    [self reloadData];
}

- (void)updateGroupConversation:(id<TLGroupConversation>)conversation uiConversation:(UIGroupConversation *)uiConversation {
    DDLogVerbose(@"%@ updateGroupConversation: %@ uiConversation:%@", LOG_TAG, conversation, uiConversation);
        
    NSMutableArray *members = [conversation groupMembersWithFilter:TLGroupMemberFilterTypeJoinedMembers];
    NSMutableArray *uiMemberList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5 && i < members.count; i++) {
        id<TLGroupMemberConversation> member = [members objectAtIndex:i];
        [uiMemberList addObject:member.memberTwincodeId];
        [self.membersToGroupConversations setObject:uiConversation forKey:member.memberTwincodeId];
    }
    [uiConversation setGroupMemberCount:members.count];
    [uiConversation setVisibleMembers:uiMemberList];
    
    for (NSUUID *uuid in uiMemberList) {
        UIImage *avatar = [self.groupMembersAvatar objectForKey:uuid];
        if (avatar) {
            [uiConversation addMembersAvatar:avatar];
        }
    }
    
    NSMutableArray *unknownMembers = [uiConversation updateVisibleMembers:self.groupMembers groupMemberTwincodeId:nil groupMemberAvatar:nil];
    [self.chatService getGroupMembers:(TLGroup *)uiConversation.uiContact.contact members:unknownMembers];
}

- (void)onResetConversation:(id <TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversation: %@ clearMode: %d", LOG_TAG, conversation, clearMode);
    
    if (clearMode == TLConversationServiceClearMedia) {
        return;
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[conversation.uuid];
    
    // If a group conversation is reset, we must keep the entry in the UIConversation.
    if ([conversation isGroup] && self.resetConversation) {
        [self.conversationsTableView setEditing:NO];
        
        if (uiConversation) {
            uiConversation.lastDescriptor = nil;
        }
    } else if (uiConversation) {
        uiConversation.uiContact.uiConversation = nil;
        [self.uiConversationsMap removeObjectForKey:conversation.uuid];
        [self.uiConversations removeObject:uiConversation];
    }
    
    self.resetConversation = nil;
    [self reloadData];
}

- (void)onDeleteConversation:(NSUUID *)conversationId {
    DDLogVerbose(@"%@ onDeleteConversation: %@", LOG_TAG, conversationId);
    
    UIConversation *uiConversation = self.uiConversationsMap[conversationId];
    if (uiConversation) {
        uiConversation.uiContact.uiConversation = nil;
        [self.uiConversationsMap removeObjectForKey:conversationId];
        [self.uiConversations removeObject:uiConversation];
    }
    [self reloadData];
}

- (void)onPushDescriptor:(TLDescriptor *)descriptor conversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onPushDescriptor: %@ conversation: %@", LOG_TAG, descriptor, conversation);
    
    if (descriptor.getType == TLDescriptorTypeTransientObjectDescriptor) {
        return;
    }
    
    if ([conversation conformsToProtocol:@protocol(TLGroupMemberConversation)]) {
        conversation = [(id<TLGroupMemberConversation>)conversation groupConversation];
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[conversation.uuid];
    
    // If the conversation is not known, create it because we receive a first message.
    if (!uiConversation) {
        [self updateConversation:conversation];
        [self reloadData];
    } else {
        if (!uiConversation.lastDescriptor || (uiConversation.lastDescriptor && uiConversation.lastDescriptor.createdTimestamp < descriptor.createdTimestamp)) {
            [uiConversation setLastDescriptor:descriptor];
            [self updateUIConversation:uiConversation];
            [self reloadData];
        }
    }
}

- (void)onPopDescriptor:(TLDescriptor *)descriptor conversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onPopDescriptor: %@ conversation: %@", LOG_TAG, descriptor, conversation);
    
    if (descriptor.getType == TLDescriptorTypeTransientObjectDescriptor) {
        return;
    }
    
    if ([conversation conformsToProtocol:@protocol(TLGroupMemberConversation)]) {
        conversation = [(id<TLGroupMemberConversation>)conversation groupConversation];
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[conversation.uuid];
    
    // If the conversation is not known, create it because we receive a first message.
    if (!uiConversation) {
        [self updateConversation:conversation];
        
        if (!self.searchController.isActive || [self.searchController.searchBar.text isEqualToString:@""]) {
            [self reloadData];
        } else {
            [self updateConversations];
            [self.conversationsTableView reloadData];
        }
    } else {
        if (!uiConversation.lastDescriptor || (uiConversation.lastDescriptor && uiConversation.lastDescriptor.createdTimestamp < descriptor.createdTimestamp)) {
            [uiConversation setLastDescriptor:descriptor];
            [self updateUIConversation:uiConversation];
            if (!self.searchController.isActive || [self.searchController.searchBar.text isEqualToString:@""]) {
                [self reloadData];
            } else {
                [self updateConversations];
                [self.conversationsTableView reloadData];
            }
        }
    }
}

- (void)onUpdateDescriptor:(TLDescriptor *)descriptor conversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onUpdateDescriptor: %@ conversation: %@", LOG_TAG, descriptor, conversation);
    
    if (descriptor.getType == TLDescriptorTypeTransientObjectDescriptor) {
        return;
    }
    
    if ([conversation conformsToProtocol:@protocol(TLGroupMemberConversation)]) {
        conversation = [(id<TLGroupMemberConversation>)conversation groupConversation];
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[conversation.uuid];
    if (uiConversation) {
        if (uiConversation.lastDescriptor && [uiConversation.lastDescriptor.descriptorId isEqual:descriptor.descriptorId]) {
            [uiConversation setLastDescriptor:descriptor];
            [self updateUIConversation:uiConversation];
            if (!self.searchController.isActive || [self.searchController.searchBar.text isEqualToString:@""]) {
                [self reloadData];
            } else {
                [self updateConversations];
                [self.conversationsTableView reloadData];
            }
        }
    }
}

- (void)onDeleteDescriptors:(NSSet<TLDescriptorId *> *)descriptors conversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@ conversation: %@", LOG_TAG, descriptors, conversation);

    if ([conversation conformsToProtocol:@protocol(TLGroupMemberConversation)]) {
        conversation = [(id<TLGroupMemberConversation>)conversation groupConversation];
    }
    
    UIConversation *uiConversation = self.uiConversationsMap[conversation.uuid];
    if (uiConversation) {
        if (uiConversation.lastDescriptor && [descriptors containsObject:uiConversation.lastDescriptor.descriptorId]) {
            [self.chatService getLastDescriptorWithConversation:conversation withBlock:^(TLDescriptor *descriptor) {
                [uiConversation setLastDescriptor:descriptor];
                [self updateUIConversation:uiConversation];
                if (!self.searchController.isActive || [self.searchController.searchBar.text isEqualToString:@""]) {
                    [self reloadData];
                }
            }];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    if (tableView == self.conversationsTableView) {
        if (!self.isNotificationEnabled) {
            return CONVERSATIONS_VIEW_SECTION_COUNT + 1;
        }
        
        return CONVERSATIONS_VIEW_SECTION_COUNT;
    } else {
        return SEARCH_VIEW_SECTION_COUNT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.conversationsTableView) {
        if (!self.isNotificationEnabled && section == 0) {
            return 1;
        }
        
        return self.filteredConversations.count;
    } else {
        if (self.searchFilter == SearchFilterAll) {
            if (section == 0) {
                if (!self.showAllContacts) {
                    return self.searchContacts.count < MIN_RESULTS_VISIBLE ? self.searchContacts.count : MIN_RESULTS_VISIBLE;
                }
                return self.searchContacts.count;
            } else if (section == 1) {
                if (!self.showAllGroups) {
                    return self.searchGroups.count < MIN_RESULTS_VISIBLE ? self.searchGroups.count : MIN_RESULTS_VISIBLE;
                }
                return self.searchGroups.count;
            } else if (section == 2) {
                return self.searchContentConversations.count;
            }
        } else if (self.searchFilter == SearchFilterContacts && section == 0) {
            return self.searchContacts.count;
        } else if (self.searchFilter == SearchFilterGroup && section == 1) {
            return self.searchGroups.count;
        } else if (self.searchFilter == SearchFilterMessage && section == 2) {
            return self.searchContentConversations.count;
        }
        
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
            
    if (tableView == self.searchTableView && self.searchFilter == SearchFilterAll) {
        
        if ((section == 0 && self.searchContacts.count > 0) || (section == 1 && self.searchGroups.count > 0) || (section == 2 && self.searchContentConversations.count > 0)) {
            return (DESIGN_SECTION_SEARCH_HEIGHT * Design.HEIGHT_RATIO);
        }
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.searchTableView && self.searchFilter == SearchFilterAll) {
        
        if ((section == 0 && self.searchContacts.count > 0) || (section == 1 && self.searchGroups.count > 0) || (section == 2 && self.searchContentConversations.count > 0)) {
            return (DESIGN_SECTION_FOOTER_SEARCH_HEIGHT * Design.HEIGHT_RATIO);
        }
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.searchTableView && self.searchFilter == SearchFilterAll) {
        SearchSectionCell *searchSectionCell = (SearchSectionCell *)[tableView dequeueReusableCellWithIdentifier:SEARCH_SECTION_CELL_IDENTIFIER];
        if (!searchSectionCell) {
            searchSectionCell = [[SearchSectionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SEARCH_SECTION_CELL_IDENTIFIER];
        }
            
        UICustomTab *customTab = [self.customTabs objectAtIndex:section + 1];
        
        BOOL showAllAction = NO;
        if (section == 0) {
            showAllAction = !self.showAllContacts;
        } else if (section == 1) {
            showAllAction = !self.showAllGroups;
        }
        
        searchSectionCell.searchSectionDelegate = self;
        [searchSectionCell bindWithSearchFilter:customTab showAllAction:showAllAction];
        
        return searchSectionCell;
    } else {
        return [[UIView alloc]init];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.searchTableView && self.searchFilter == SearchFilterAll) {
        SearchSectionFooterCell *searchSectionFooterCell = (SearchSectionFooterCell *)[tableView dequeueReusableCellWithIdentifier:SEARCH_SECTION_FOOTER_CELL_IDENTIFIER];
        if (!searchSectionFooterCell) {
            searchSectionFooterCell = [[SearchSectionFooterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SEARCH_SECTION_FOOTER_CELL_IDENTIFIER];
        }
            
        return searchSectionFooterCell;
    } else {
        return [[UIView alloc]init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (tableView == self.conversationsTableView) {
        if (!self.isNotificationEnabled && indexPath.section == 0) {
            return UITableViewAutomaticDimension;
        }
        
        return [self getCellHeight];
    } else if (indexPath.section == 2) {
        return UITableViewAutomaticDimension;
    } else {
        return Design.CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (tableView == self.conversationsTableView) {
        if (!self.isNotificationEnabled && indexPath.section == 0) {
            EnableNotificationCell *enableNotificationCell = (EnableNotificationCell *)[tableView dequeueReusableCellWithIdentifier:ENABLE_NOTIFICATION_CELL_IDENTIFIER];
            if (!enableNotificationCell) {
                enableNotificationCell = [[EnableNotificationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ENABLE_NOTIFICATION_CELL_IDENTIFIER];
            }
            enableNotificationCell.enableNotificationDelegate = self;
            [enableNotificationCell bind];
            
            return enableNotificationCell;
        } else {
            ConversationCell *conversationCell = (ConversationCell *)[tableView dequeueReusableCellWithIdentifier:CONVERSATION_CELL_IDENTIFIER];
            if (!conversationCell) {
                conversationCell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONVERSATION_CELL_IDENTIFIER];
            }
            
            if (self.filteredConversations && indexPath.row < self.filteredConversations.count) {
                conversationCell.conversationsActionDelegate = self;
                
                
                UIConversation *uiConversation = self.filteredConversations[indexPath.row];
                BOOL hideSeparator = indexPath.row + 1 == self.filteredConversations.count ? YES : NO;
                [conversationCell bindWithConversation:uiConversation topMargin:self.cellNameMargin hideSeparator:hideSeparator];
            }
            
            return conversationCell;
        }
    } else {
        if (indexPath.section == 0) {
            ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
            if (!contactCell) {
                contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
            }
            
            UIConversation *uiConversation = self.searchContacts[indexPath.row];
            [contactCell bindWithContact:uiConversation.uiContact hideSeparator:YES];
            
            return contactCell;
        } else if (indexPath.section == 1) {
            ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
            if (!contactCell) {
                contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
            }
            
            UIConversation *uiConversation = self.searchGroups[indexPath.row];
            [contactCell bindWithContact:uiConversation.uiContact hideSeparator:YES];
            
            return contactCell;
        } else {
            
            if (indexPath.row == [self.searchContentConversations count] - 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getPreviousDescriptors];
                });
            }
            
            SearchContentMessageCell *searchContentMessageCell = (SearchContentMessageCell *)[tableView dequeueReusableCellWithIdentifier:SEARCH_CONTENT_MESSAGE_CELL_IDENTIFIER];
            if (!searchContentMessageCell) {
                searchContentMessageCell = [[SearchContentMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SEARCH_CONTENT_MESSAGE_CELL_IDENTIFIER];
            }
             
            UIConversation *uiConversation = self.searchContentConversations[indexPath.row];
            [searchContentMessageCell bindWithConversation:uiConversation search:self.searchController.searchBar.text];
            
            return searchContentMessageCell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (tableView == self.searchTableView) {
        UIConversation *uiConversation;
        
        if (indexPath.section == 0) {
            uiConversation = self.searchContacts[indexPath.row];
        } else if (indexPath.section == 1) {
            uiConversation = self.searchGroups[indexPath.row];
        } else if (indexPath.section == 2) {
            uiConversation = self.searchContentConversations[indexPath.row];
        }

        if (uiConversation) {
            ConversationViewController* conversationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
            [conversationViewController initWithContact:uiConversation.uiContact.contact];
            
            if (indexPath.section == 2) {
                [conversationViewController scrollToDescriptor:uiConversation.lastDescriptor.descriptorId];
            }
            
            [self.navigationController pushViewController:conversationViewController animated:YES];
        }
    } else {
        if (!self.isNotificationEnabled && indexPath.section == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.conversationsTableView) {
        // Get the UI conversation now since the list could change while contextualActionWithStyle executes.
        UIConversation *uiConversation = [self.filteredConversations objectAtIndex:indexPath.row];
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            // And record the UI conversatation instance to make sure we reset the correct one (using indexPath here is incorrect).
            self.resetConversation = uiConversation;
            [self openResetConversationConfirmView:self.resetConversation.uiContact.avatar];
        }];
        
        CellActionView *deleteActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil) icon:@"ToolbarTrash" backgroundColor:[UIColor clearColor] iconWidth:32 iconHeight:38 iconTopMargin:28];
        deleteAction.image = [deleteActionView imageFromView];
        deleteAction.backgroundColor = Design.DELETE_COLOR_RED;
        
        UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
        
        return swipeActionConfiguration;
    }
    
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    if (scrollView == self.searchTableView) {
        [self.searchController.searchBar resignFirstResponder];
    }
}

#pragma mark - EnableNotificationDelegate

- (void)didTapInfoEnableNotification {
    DDLogVerbose(@"%@ didTapInfoEnableNotification", LOG_TAG);
    
    QualityOfServicesViewController *qualityOfServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QualityOfServicesViewController"];
    [qualityOfServicesViewController showInView:self.tabBarController];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarTextDidBeginEditing: %@", LOG_TAG, searchBar);
    
    self.conversationsTableView.hidden = NO;
    self.customTabContainerView.hidden = YES;
    self.searchTableView.hidden = YES;
    self.noResultFoundImageView.hidden = YES;
    self.noResultFoundTitleLabel.hidden = YES;
    self.noResultFoundLabel.hidden = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.searchContentConversations removeAllObjects];
    [self.searchContacts removeAllObjects];
    [self.searchGroups removeAllObjects];
    
    self.showAllContacts = NO;
    self.showAllGroups = NO;
    
    if (![searchText isEqual:@""]) {
        [self.chatService findConversationsByName:searchText];
        
        [self.chatService searchDescriptorsByContent:searchText clearSearch:YES withBlock:^(NSArray<TLConversationDescriptorPair *> *descriptors) {
            
            for (TLConversationDescriptorPair *conversationDescriptorPair in descriptors) {
                id<TLConversation> conversation = conversationDescriptorPair.conversation;
                UIContact *uiContact = ([conversation isGroup] ? self.uiGroups[conversation.contactId] : self.uiContacts[conversation.contactId]);
                if ([conversation isActive] && uiContact) {
                    UIConversation *uiConversation = [[UIConversation alloc]initWithConversationId:conversation.uuid uiContact:uiContact];
                    [uiConversation setDescriptor:conversationDescriptorPair.descriptor];
                    [self.searchContentConversations addObject:uiConversation];
                }
            }
            
            [self reloadSearchResult];
        }];
    } else {
        [self reloadSearchResult];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.searchContentConversations removeAllObjects];
    [self.searchContacts removeAllObjects];
    [self.searchGroups removeAllObjects];
    [self reloadSearchResult];
    
    self.conversationsTableView.hidden = NO;
    self.customTabContainerView.hidden = YES;
    self.searchTableView.hidden = YES;
    self.noResultFoundImageView.hidden = YES;
    self.noResultFoundTitleLabel.hidden = YES;
    self.noResultFoundLabel.hidden = YES;
    
    [self.chatService getConversationsWithCallsMode:[self.twinmeApplication displayCallsMode]];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    DDLogVerbose(@"%@ willDismissSearchController: %@", LOG_TAG, searchController);
    
    [self.searchContentConversations removeAllObjects];
    [self.searchContacts removeAllObjects];
    [self.searchGroups removeAllObjects];
    [self reloadSearchResult];
    
    self.conversationsTableView.hidden = NO;
    self.customTabContainerView.hidden = YES;
    self.searchTableView.hidden = YES;
    self.noResultFoundImageView.hidden = YES;
    self.noResultFoundTitleLabel.hidden = YES;
    self.noResultFoundLabel.hidden = YES;
    
    [self.chatService getConversationsWithCallsMode:[self.twinmeApplication displayCallsMode]];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    UIConversation* uiConversation = self.resetConversation;
    [self.conversationsTableView setEditing:NO];
    [self.chatService resetConversation:uiConversation.uiContact.contact];
    
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [self.conversationsTableView setEditing:NO];
    self.resetConversation = nil;
    
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [self.conversationsTableView setEditing:NO];
    self.resetConversation = nil;
    
    [self.resetConversationConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [self.resetConversationConfirmView removeFromSuperview];
    self.resetConversationConfirmView = nil;
}


#pragma mark - ConversationsActionDelegate

- (void)didTapConversation:(UIConversation *)uiConversation {
    DDLogVerbose(@"%@ didTapConversation: %@", LOG_TAG, uiConversation);
    
    if (uiConversation.uiContact.contact) {
        if ([uiConversation isKindOfClass:[UIGroupConversation class]]) {
            UIGroupConversation *groupConversation = (UIGroupConversation *)uiConversation;
            if (groupConversation.groupMemberCount == 0) {
                [self showOriginator:uiConversation];
                return;
            }
        }
        ConversationViewController* conversationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:uiConversation.uiContact.contact];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)didLongPressConversation:(UIConversation *)uiConversation {
    DDLogVerbose(@"%@ didLongPressConversation: %@", LOG_TAG, uiConversation);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    
    if (self.searchController.active) {
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self showOriginator:uiConversation];
        }];
    } else {
        [self showOriginator:uiConversation];
    }
}

#pragma mark - CustomTabViewDelegate

- (void)didSelectTab:(UICustomTab *)uiCustomTab {
    DDLogVerbose(@"%@ didSelectTab: %@", LOG_TAG, uiCustomTab);
        
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    
    self.searchFilter = uiCustomTab.tag;
    [self reloadSearchResult];
}

#pragma mark - SearchSectionDelegate

- (void)didTapAll:(int)tag {
    DDLogVerbose(@"%@ didTapAll: %d", LOG_TAG, tag);
    
    if (tag == SearchFilterContacts) {
        self.showAllContacts = YES;
    } else if (tag == SearchFilterGroup) {
        self.showAllGroups = YES;
    }

    [self reloadSearchResult];
}

#pragma mark - Private Methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil).capitalizedString];
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[TwinmeLocalizedString(@"history_view_controller_all_call_segmented_control", nil), TwinmeLocalizedString(@"share_view_controller_group_list_title", nil)]];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    if (@available(iOS 13.0, *)) {
        self.segmentedControl.selectedSegmentTintColor = [UIColor whiteColor];
    }
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = self.segmentedControl;
    
    self.addChatBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarNewChat"] style:UIBarButtonItemStylePlain target:self action:@selector(handleAddChatTapGesture:)];
    self.addChatBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversations_view_controller_title", nil);
    self.navigationItem.rightBarButtonItem = self.addChatBarButtonItem;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    self.searchController.searchBar.backgroundColor = [UIColor clearColor];
    
    UISearchBar *conversationSearchBar = self.searchController.searchBar;
    conversationSearchBar.barStyle = UIBarStyleDefault;
    conversationSearchBar.searchBarStyle = UISearchBarStyleProminent;
    conversationSearchBar.translucent = NO;
    conversationSearchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    conversationSearchBar.tintColor = [UIColor whiteColor];
    conversationSearchBar.backgroundImage  = [UIImage new];
    conversationSearchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    conversationSearchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    conversationSearchBar.delegate = self;
    
    self.searchController.searchBar.translucent = YES;
    self.searchController.searchBar.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
        self.searchController.searchBar.translucent = YES;
        self.searchController.searchBar.delegate = self;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.conversationsTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    self.conversationsTableView.backgroundColor = Design.WHITE_COLOR;
    self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.conversationsTableView registerNib:[UINib nibWithNibName:@"ConversationCell" bundle:nil] forCellReuseIdentifier:CONVERSATION_CELL_IDENTIFIER];
    [self.conversationsTableView registerNib:[UINib nibWithNibName:@"EnableNotificationCell" bundle:nil] forCellReuseIdentifier:ENABLE_NOTIFICATION_CELL_IDENTIFIER];
    self.conversationsTableView.rowHeight = UITableViewAutomaticDimension;
    self.conversationsTableView.estimatedRowHeight = [self getCellHeight];
    self.conversationsTableView.tableFooterView = [[UIView alloc] init];
    
    self.noConversationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noConversationImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noConversationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noConversationImageView.hidden = YES;
    
    self.noConversationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noConversationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noConversationLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noConversationLabel.font = Design.FONT_MEDIUM34;
    self.noConversationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    [self.noConversationLabel setAdjustsFontSizeToFitWidth:YES];
    self.noConversationLabel.text = TwinmeLocalizedString(@"conversations_view_controller_no_conversation_message", nil);
    self.noConversationLabel.hidden = YES;
    
    self.inviteContactViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteContactViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteContactViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteContactViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteContactView.backgroundColor = Design.MAIN_COLOR;
    self.inviteContactView.userInteractionEnabled = YES;
    self.inviteContactView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.inviteContactView.clipsToBounds = YES;
    self.inviteContactView.hidden = YES;
    self.inviteContactView.isAccessibilityElement = YES;
    self.inviteContactView.accessibilityLabel = TwinmeLocalizedString(@"contacts_view_controller_invite_contact_title", nil);
    [self.inviteContactView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddContactTapGesture:)]];
    
    self.inviteContactLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteContactLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteContactLabel.font = Design.FONT_MEDIUM34;
    self.inviteContactLabel.textColor = [UIColor whiteColor];
    self.inviteContactLabel.text = TwinmeLocalizedString(@"contacts_view_controller_invite_contact_title", nil);
    
    self.transferLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.transferLabel.font = Design.FONT_REGULAR26;
    self.transferLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    NSMutableAttributedString *transferAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"account_view_controller_transfer_from_another_device", nil)];
    [transferAttributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,
                                                                                                    [transferAttributedString length])];
    [self.transferLabel setAttributedText:transferAttributedString];
    
    self.transferViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.transferViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.transferView.userInteractionEnabled = YES;
    [self.transferView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTransferTapGesture:)]];
    
    self.startConversationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.startConversationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startConversationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startConversationViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startConversationView.backgroundColor = Design.MAIN_COLOR;
    self.startConversationView.userInteractionEnabled = YES;
    self.startConversationView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startConversationView.clipsToBounds = YES;
    self.startConversationView.hidden = YES;
    self.startConversationView.isAccessibilityElement = YES;
    self.startConversationView.accessibilityLabel = TwinmeLocalizedString(@"conversations_view_controller_start", nil);
    [self.startConversationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddChatTapGesture:)]];
    
    self.startConversationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startConversationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.startConversationLabel.font = Design.FONT_MEDIUM34;
    self.startConversationLabel.textColor = [UIColor whiteColor];
    self.startConversationLabel.text = TwinmeLocalizedString(@"conversations_view_controller_start", nil);
    
    self.searchTableViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.searchTableView.backgroundColor = Design.WHITE_COLOR;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchTableView.estimatedRowHeight = Design.CELL_HEIGHT;
    self.searchTableView.hidden = YES;
    
    [self.searchTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:CONTACT_CELL_IDENTIFIER];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"SearchContentMessageCell" bundle:nil] forCellReuseIdentifier:SEARCH_CONTENT_MESSAGE_CELL_IDENTIFIER];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"SearchSectionCell" bundle:nil] forCellReuseIdentifier:SEARCH_SECTION_CELL_IDENTIFIER];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"SearchSectionFooterCell" bundle:nil] forCellReuseIdentifier:SEARCH_SECTION_FOOTER_CELL_IDENTIFIER];
    
    self.customTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.customTabContainerView.hidden = YES;
    
    self.noResultFoundImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noResultFoundImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noResultFoundImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noResultFoundImageView.hidden = YES;
    
    self.noResultFoundTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noResultFoundTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noResultFoundTitleLabel.font = Design.FONT_MEDIUM34;
    self.noResultFoundTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noResultFoundTitleLabel.text = TwinmeLocalizedString(@"conversations_view_controller_no_result_found", nil);
    self.noResultFoundTitleLabel.hidden = YES;
    
    self.noResultFoundLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noResultFoundLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noResultFoundLabel.font = Design.FONT_MEDIUM28;
    self.noResultFoundLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noResultFoundLabel.text = TwinmeLocalizedString(@"conversations_view_controller_no_result_found_message", nil);;
    self.noResultFoundLabel.hidden = YES;
        
    [self.customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"application_all", nil) tag:SearchFilterAll isSelected:YES]];
    [self.customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"contacts_view_controller_title", nil) tag:SearchFilterContacts isSelected:NO]];
    [self.customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"share_view_controller_group_list_title", nil) tag:SearchFilterGroup isSelected:NO]];
    [self.customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil) tag:SearchFilterMessage isSelected:NO]];
    
    self.customTabView = [[CustomTabView alloc] initWithCustomTab:self.customTabs];
    self.customTabView.customTabViewDelegate = self;
    [self.customTabView updateColor:Design.WHITE_COLOR mainColor:Design.MAIN_COLOR textSelectedColor:[UIColor whiteColor] borderColor:Design.GREY_ITEM];
    [self.customTabContainerView addSubview:self.customTabView];
}

- (void)updateConversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ updateConversation: %@", LOG_TAG, conversation);
    
    UIContact *uiContact = ([conversation isGroup] ? self.uiGroups[conversation.contactId] : self.uiContacts[conversation.contactId]);
    UIConversation* uiConversation = uiContact.uiConversation;
    if (!uiConversation || ![uiConversation.conversationId isEqual:conversation.uuid]) {
        if (![conversation isGroup]) {
            uiConversation = [[UIConversation alloc] initWithConversationId:conversation.uuid uiContact:uiContact];
        } else {
            id<TLGroupConversation> groupConversation = (id<TLGroupConversation>)conversation;
            uiConversation = [[UIGroupConversation alloc] initWithConversationId:conversation.uuid uiContact:uiContact groupConversationStateType:groupConversation.state];
            [self updateGroupConversation:groupConversation uiConversation:(UIGroupConversation *)uiConversation];
        }
        uiContact.uiConversation = uiConversation;
    }
    if (uiConversation) {
        [self.chatService getLastDescriptorWithConversation:conversation withBlock:^(TLDescriptor *descriptor) {
            [uiConversation setLastDescriptor:descriptor];
            [self updateUIConversation:uiConversation];
            if (!self.searchController.isActive || [self.searchController.searchBar.text isEqualToString:@""]) {
                [self reloadData];
            }
        }];
    }
}

- (void)updateUIConversation:(UIConversation *)uiConversation {
    DDLogVerbose(@"%@ updateUIConversation: %@", LOG_TAG, uiConversation);
    
    UIConversation *lUIConversation = self.uiConversationsMap[uiConversation.conversationId];
    if (lUIConversation) {
        [self.uiConversations removeObject:lUIConversation];
    }
    
    // TBD Sort using id order when name are equals
    BOOL added = NO;
    NSInteger size = self.uiConversations.count;
    
    int64_t lastMessageDate = [uiConversation lastMessageDate];
    double score = [uiConversation usageScore];
    NSInteger i = 0;
    
    // Put the conversation at the top if it has the highest usage score.
    if (MOST_USED_CONVERSATION_COUNT > 0) {
        for (; i < size && i < MOST_USED_CONVERSATION_COUNT; i++) {
            UIConversation *lUIConversation = [self.uiConversations objectAtIndex:i];
            if (score > [lUIConversation usageScore]
                || (score == [lUIConversation usageScore] && [lUIConversation.uiContact.name caseInsensitiveCompare:uiConversation.uiContact.name] == NSOrderedDescending)) {
                [self.uiConversations insertObject:uiConversation atIndex:i];
                added = YES;
                break;
            }
        }
        
        // The most used area was full and we added one item: re-dispatch the last one.
        if (added && size > MOST_USED_CONVERSATION_COUNT) {
            uiConversation = [self.uiConversations objectAtIndex:MOST_USED_CONVERSATION_COUNT];
            [self.uiConversations removeObjectAtIndex:MOST_USED_CONVERSATION_COUNT];
            added = NO;
        }
    }
    
    // Put the conversation according to the highest access time.
    if (LAST_USED_CONVERSATION_COUNT > 0 && !added) {
        for (; i < size && i < LAST_USED_CONVERSATION_COUNT + MOST_USED_CONVERSATION_COUNT; i++) {
            UIConversation *lUIConversation = [self.uiConversations objectAtIndex:i];
            if (lastMessageDate > [lUIConversation lastMessageDate]
                || (lastMessageDate == [lUIConversation lastMessageDate] && score > [lUIConversation usageScore])
                || (lastMessageDate == [lUIConversation lastMessageDate] && score == [lUIConversation usageScore] && [lUIConversation.uiContact.name caseInsensitiveCompare:uiConversation.uiContact.name] == NSOrderedDescending)) {
                [self.uiConversations insertObject:uiConversation atIndex:i];
                added = YES;
                break;
            }
        }
        
        // The last used area was full and we added one item: re-dispatch the last one.
        if (added && size > LAST_USED_CONVERSATION_COUNT + MOST_USED_CONVERSATION_COUNT) {
            uiConversation = [self.uiConversations objectAtIndex:LAST_USED_CONVERSATION_COUNT + MOST_USED_CONVERSATION_COUNT];
            [self.uiConversations removeObjectAtIndex:LAST_USED_CONVERSATION_COUNT + MOST_USED_CONVERSATION_COUNT];
            added = NO;
        }
    }
    
    // Not part of the most used conversation, order by contact name.
    if (!added) {
        for (NSInteger i = LAST_USED_CONVERSATION_COUNT + MOST_USED_CONVERSATION_COUNT; i < size; i++) {
            UIConversation *lUIConversation = [self.uiConversations objectAtIndex:i];
            if ([lUIConversation.uiContact.name caseInsensitiveCompare:uiConversation.uiContact.name] == NSOrderedDescending) {
                [self.uiConversations insertObject:uiConversation atIndex:i];
                added = YES;
                break;
            }
        }
        if (!added) {
            [self.uiConversations addObject:uiConversation];
        }
    }
    
    [self.uiConversationsMap setObject:uiConversation forKey:uiConversation.conversationId];
}

- (IBAction)segmentedControlValueDidChange:(id)sender {
    DDLogVerbose(@"%@ segmentedControlValueDidChange: %@", LOG_TAG, sender);
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.onlyGroups = NO;
    } else {
        self.onlyGroups = YES;
    }
    
    [self reloadData];
}

- (void)updateConversations {
    DDLogVerbose(@"%@ updateConversations", LOG_TAG);

    self.filteredConversations = nil;
    self.filteredConversations = [self.uiConversations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIConversation *uiConversation, NSDictionary *bindings) {
        return [self showConversation:uiConversation];
    }]];
}

- (BOOL)showConversation:(UIConversation *)uiConversation {
    DDLogVerbose(@"%@ showConversation: %@", LOG_TAG, uiConversation);
    
    if (!self.onlyGroups) {
        return YES;
    }
    
    UIContact *uiContact = uiConversation.uiContact;
    if (uiContact && uiContact.contact.isGroup) {
        return YES;
    }
    
    return NO;
}

- (IBAction)handleAddChatTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddChatTapGesture: %@", LOG_TAG, sender);
    
    if (!self.defaultProfile) {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        addProfileViewController.fromConversationsTab = YES;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    } else {
        NewConversationViewController *newConversationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewConversationViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:newConversationViewController];
        [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)handleAddContactTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    if (!self.defaultProfile) {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        addProfileViewController.fromConversationsTab = YES;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    } else {
        AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
        [addContactViewController initWithProfile:self.defaultProfile invitationMode:InvitationModeScan];
        [self.navigationController pushViewController:addContactViewController animated:YES];
    }
}

- (void)handleTransferTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTransferTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
        accountMigrationScannerViewController.fromCurrentDevice = NO;
        [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
    }
}

- (void)showOriginator:(UIConversation *)uiConversation {
    DDLogVerbose(@"%@ showOriginator: %@", LOG_TAG, uiConversation);
    
    if ([uiConversation.uiContact.contact isGroup]) {
        ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
        [showGroupViewController initWithGroup:(TLGroup*)uiConversation.uiContact.contact];
        [self.navigationController pushViewController:showGroupViewController animated:YES];
    } else if (uiConversation.uiContact.contact) {
        TLContact *contact = (TLContact *)uiConversation.uiContact.contact;
        if (contact.isTwinroom) {
            ShowRoomViewController *showRoomViewController = [[UIStoryboard storyboardWithName:@"Room" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowRoomViewController"];
            [showRoomViewController initWithRoom:contact];
            [self.navigationController pushViewController:showRoomViewController animated:YES];
        } else {
            ShowContactViewController *showContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
            [showContactViewController initWithContact:contact];
            [self.navigationController pushViewController:showContactViewController animated:YES];
        }
    }
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if (!self.visible) {
        return;
    }
    
    [self updateConversations];
    
    if (self.uiContacts.count == 0 && self.uiConversations.count == 0 && !self.searchController.active) {
        self.addChatBarButtonItem.enabled = NO;
        self.noConversationImageView.hidden = NO;
        self.noConversationLabel.hidden = NO;
        self.transferView.hidden = NO;
        self.conversationsTableView.hidden = YES;
        self.startConversationView.hidden = YES;
        self.inviteContactView.hidden = NO;
        self.noConversationImageViewHeightConstraint.constant = DESIGN_NO_CONTACT_IMAGE_HEIGHT * Design.HEIGHT_RATIO;
        self.noConversationImageView.image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingStep3Dark"] : [UIImage imageNamed:@"OnboardingStep3"];
        self.noConversationLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_onboarding_message", nil);
        
        self.navigationItem.titleView = nil;
        [self setNavigationTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil).capitalizedString];
        [self.navigationController.navigationBar setPrefersLargeTitles:NO];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = nil;
        }
    } else if (self.uiConversations.count == 0 && !self.searchController.active) {
        self.addChatBarButtonItem.enabled = YES;
        self.noConversationImageView.hidden = NO;
        self.noConversationLabel.hidden = NO;
        self.transferView.hidden = YES;
        self.conversationsTableView.hidden = YES;
        self.inviteContactView.hidden = YES;
        self.startConversationView.hidden = NO;
        self.noConversationImageViewHeightConstraint.constant = DESIGN_NO_CONVERSATION_IMAGE_HEIGHT * Design.HEIGHT_RATIO;
        self.noConversationImageView.image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingStep2Dark"] : [UIImage imageNamed:@"OnboardingStep2"];
        self.noConversationLabel.text = TwinmeLocalizedString(@"conversations_view_controller_no_conversation_message", nil);
        
        self.navigationItem.titleView = nil;
        [self setNavigationTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil).capitalizedString];
        
        [self.navigationController.navigationBar setPrefersLargeTitles:NO];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = nil;
        }
    } else {
        self.addChatBarButtonItem.enabled = YES;
        self.noConversationImageView.hidden = YES;
        self.noConversationLabel.hidden = YES;
        self.transferView.hidden = YES;
        self.conversationsTableView.hidden = NO;
        self.inviteContactView.hidden = YES;
        self.startConversationView.hidden = YES;
        
        self.navigationItem.titleView = self.segmentedControl;
        [self.navigationController.navigationBar setPrefersLargeTitles:YES];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = self.searchController;
        }
    }
    
    [self.conversationsTableView reloadData];
}

- (void)reloadSearchResult {
    DDLogVerbose(@"%@ reloadSearchResult", LOG_TAG);
 
    if (self.searchFilter == SearchFilterAll) {
        if (self.searchContacts.count == 0 && self.searchGroups.count == 0 && self.searchContentConversations.count == 0) {
            if ([self.searchController.searchBar.text isEqualToString:@""]) {
                self.searchTableView.hidden = YES;
                self.conversationsTableView.hidden = NO;
                self.customTabContainerView.hidden = YES;
                self.noResultFoundImageView.hidden = YES;
                self.noResultFoundTitleLabel.hidden = YES;
                self.noResultFoundLabel.hidden = YES;
            } else {
                self.searchTableView.hidden = NO;
                self.conversationsTableView.hidden = YES;
                self.customTabContainerView.hidden = YES;
                self.noResultFoundImageView.hidden = NO;
                self.noResultFoundTitleLabel.hidden = NO;
                self.noResultFoundTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversations_view_controller_no_result_found", nil), self.searchController.searchBar.text];
                self.noResultFoundLabel.hidden = YES;
            }
        } else {
            self.searchTableView.hidden = NO;
            self.conversationsTableView.hidden = YES;
            self.customTabContainerView.hidden = NO;
            self.noResultFoundImageView.hidden = YES;
            self.noResultFoundTitleLabel.hidden = YES;
            self.noResultFoundLabel.hidden = YES;
        }
    } else if ((self.searchFilter == SearchFilterContacts && self.searchContacts.count == 0) || (self.searchFilter == SearchFilterGroup && self.searchGroups.count == 0) || (self.searchFilter == SearchFilterMessage && self.searchContentConversations.count == 0)) {
        self.searchTableView.hidden = NO;
        self.customTabContainerView.hidden = NO;
        self.noResultFoundImageView.hidden = NO;
        self.noResultFoundTitleLabel.hidden = NO;
        self.noResultFoundTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversations_view_controller_no_result_found", nil), self.searchController.searchBar.text];
        self.noResultFoundLabel.hidden = YES;
    } else {
        self.searchTableView.hidden = NO;
        self.customTabContainerView.hidden = NO;
        self.noResultFoundImageView.hidden = YES;
        self.noResultFoundTitleLabel.hidden = YES;
        self.noResultFoundLabel.hidden = YES;
    }
    
    [self.searchTableView reloadData];
}

- (void)getPreviousDescriptors {
    DDLogVerbose(@"%@ getPreviousDescriptors", LOG_TAG);
    
    if ([self.chatService isGetDescriptorDone]) {
        return;
    }
    
    [self.chatService searchDescriptorsByContent:self.searchController.searchBar.text clearSearch:NO withBlock:^(NSArray<TLConversationDescriptorPair *> *descriptors) {
        
        for (TLConversationDescriptorPair *conversationDescriptorPair in descriptors) {
            id<TLConversation> conversation = conversationDescriptorPair.conversation;
            UIContact *uiContact = ([conversation isGroup] ? self.uiGroups[conversation.contactId] : self.uiContacts[conversation.contactId]);
            if ([conversation isActive] && uiContact) {
                UIConversation *uiConversation = [[UIConversation alloc]initWithConversationId:conversation.uuid uiContact:uiContact];
                [uiConversation setDescriptor:conversationDescriptorPair.descriptor];
                [self.searchContentConversations addObject:uiConversation];
            }
        }
        
        [self reloadSearchResult];
    }];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of notification images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.conversationsTableView reloadData];
        });
    }
}

- (void)openResetConversationConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ openResetConversationConfirmView", LOG_TAG);
        
    NSString *alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_conversation_message", nil);
    if ([self.resetConversation.uiContact.contact isGroup]) {
        TLGroup *group = (TLGroup *)self.resetConversation.uiContact.contact;
        if (group.isOwner) {
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

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.noConversationLabel.font = Design.FONT_MEDIUM34;
    self.inviteContactLabel.font = Design.FONT_MEDIUM34;
    self.transferLabel.font = Design.FONT_REGULAR26;
    
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

- (CGFloat)getCellHeight {
    DDLogVerbose(@"%@ getCellHeight", LOG_TAG);
    
    if (self.cellHeight == 0) {
        CGFloat textHeight = Design.FONT_MEDIUM34.lineHeight + Design.FONT_REGULAR30.lineHeight * 2 + (DESIGN_CELL_MARGIN_LINE * Design.HEIGHT_RATIO);
        CGFloat avatarHeight = Design.AVATAR_HEIGHT;
        CGFloat minHeight = round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
        
        CGFloat contentHeight = avatarHeight;
        if (textHeight > avatarHeight) {
            contentHeight = textHeight;
            self.cellNameMargin = (minHeight - avatarHeight) * 0.5;
        } else {
            self.cellNameMargin = DESIGN_CELL_NAME_MARGIN * Design.HEIGHT_RATIO;
        }
        
        self.cellHeight = self.cellNameMargin * 2 + contentHeight;
    }
   
    return round(self.cellHeight);
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.conversationsTableView.backgroundColor = Design.WHITE_COLOR;
    self.searchTableView.backgroundColor = Design.WHITE_COLOR;
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = Design.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.searchTextField.textColor = Design.FONT_COLOR_DEFAULT;
        
        UIImageView *glassIconImageView = (UIImageView *)self.searchController.searchBar.searchTextField.leftView;
        glassIconImageView.image = [glassIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        glassIconImageView.tintColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.searchController.searchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    }
    
    if ([self.twinmeApplication darkModeEnable]) {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    
    self.noConversationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteContactView.backgroundColor = Design.MAIN_COLOR;
    self.startConversationView.backgroundColor = Design.MAIN_COLOR;
    self.transferLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noResultFoundTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noResultFoundLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    
    [self.customTabView updateColor:Design.WHITE_COLOR mainColor:Design.MAIN_COLOR textSelectedColor:[UIColor whiteColor] borderColor:Design.GREY_ITEM];
}

@end
