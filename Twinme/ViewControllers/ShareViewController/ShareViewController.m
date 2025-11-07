/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "MessageItem.h"
#import "PeerMessageItem.h"
#import "LinkItem.h"
#import "PeerLinkItem.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "AudioItem.h"
#import "PeerAudioItem.h"
#import "VideoItem.h"
#import "PeerVideoItem.h"
#import "FileItem.h"
#import "PeerFileItem.h"

#import "MessageItemCell.h"
#import "PeerMessageItemCell.h"
#import "LinkItemCell.h"
#import "PeerLinkItemCell.h"
#import "ImageItemCell.h"
#import "PeerImageItemCell.h"
#import "AudioItemCell.h"
#import "PeerAudioItemCell.h"
#import "VideoItemCell.h"
#import "PeerVideoItemCell.h"
#import "FileItemCell.h"
#import "PeerFileItemCell.h"
#import "AddCommentCell.h"

#import <TwinmeCommon/ShareService.h>

#import "ShareViewController.h"
#import "ConversationViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/MainViewController.h>
#import "ShareSectionHeaderCell.h"

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"

#import "AddGroupMemberCell.h"
#import "SelectedMembersCell.h"
#import "UIContact.h"
#import <TwinmeCommon/ApplicationDelegate.h>

#import <TwinmeCommon/AsyncManager.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_SELECTED_MEMBERS_HEIGHT = 116;

static NSString *ADD_GROUP_MEMBER_CELL_IDENTIFIER = @"AddGroupMemberCellIdentifier";
static NSString *SHARE_SECTION_HEADER_CELL_IDENTIFIER = @"ShareSectionHeaderCellIdentifier";
static NSString *SELECTED_MEMBERS_CELL_IDENTIFIER = @"SelectedMembersCellIdentifier";
static NSString *MESSAGE_ITEM_CELL_IDENTIFIER = @"MessageItemCellIdentifier";
static NSString *PEER_MESSAGE_ITEM_CELL_IDENTIFIER = @"PeerMessageItemCellIdentifier";
static NSString *LINK_ITEM_CELL_IDENTIFIER = @"LinkItemCellIdentifier";
static NSString *PEER_LINK_ITEM_CELL_IDENTIFIER = @"PeerLinkItemCellIdentifier";
static NSString *IMAGE_ITEM_CELL_IDENTIFIER = @"ImageItemCellIdentifier";
static NSString *PEER_IMAGE_ITEM_CELL_IDENTIFIER = @"PeerImageItemCellIdentifier";
static NSString *TIME_CELL_IDENTIFIER = @"TimeCellIdentifier";
static NSString *AUDIO_ITEM_CELL_IDENTIFIER = @"AudioItemCellIdentifier";
static NSString *PEER_AUDIO_ITEM_CELL_IDENTIFIER = @"PeerAudioItemCellIdentifier";
static NSString *VIDEO_ITEM_CELL_IDENTIFIER = @"VideoItemCellIdentifier";
static NSString *PEER_VIDEO_ITEM_CELL_IDENTIFIER = @"PeerVideoItemCellIdentifier";
static NSString *FILE_ITEM_CELL_IDENTIFIER = @"FileItemCellIdentifier";
static NSString *PEER_FILE_ITEM_CELL_IDENTIFIER = @"PeerFileItemCellIdentifier";
static NSString *ADD_COMMENT_CELL_IDENTIFIER = @"AddCommentCellIdentifier";

static CGFloat DESIGN_SECTION_HEIGHT = 110;
static CGFloat DESIGN_SECTION_CONTACT_HEIGHT = 60;
static CGFloat DESIGN_COMMENT_CELL_HEIGHT = 140;

static const int SHARE_VIEW_SECTION_COUNT = 3;

static const int SELECTED_VIEW_SECTION = 0;
static const int CONTACTS_VIEW_SECTION = 1;
static const int GROUPS_VIEW_SECTION = 2;

//
// Interface: ShareViewController ()
//

@interface ShareViewController () <ShareServiceDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AddCommentDelegate, AsyncLoaderDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *previewTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UIBarButtonItem *sendBarButtonItem;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) BOOL uiInitialized;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) CGFloat yOffset;

@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiContacts;
@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiGroups;
@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiSelectedContact;

@property (nonatomic, readonly, nonnull) ShareService *shareService;
@property (nonatomic) AsyncManager *asyncLoaderManager;

@property (nonatomic) NSString *comment;

@end

//
// Implementation: ShareViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShareViewController"

@implementation ShareViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiGroups = [[NSMutableArray alloc] init];
        _uiSelectedContact = [[NSMutableArray alloc] init];
        _descriptorId = nil;
        _keyboardHidden = YES;
        _needRefresh = NO;
        
        _shareService = [[ShareService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _asyncLoaderManager = [[AsyncManager alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.shareService getContactsAndGroups:self.currentSpace];
    }
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    self.needRefresh = YES;
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
    [self.asyncLoaderManager clear];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [self.asyncLoaderManager clear];
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = [self.previewTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        self.previewTableViewHeightConstraint.constant = rect.origin.y + rect.size.height;
    });
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.contactsTableViewBottomConstraint.constant = keyboardSize.height;
        
    [self.previewTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    [self.previewTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    self.contactsTableViewBottomConstraint.constant = 0;
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    if ([items containsObject:self.item]) {
        [items removeObject:self.item];
        ItemCell *itemCell = (ItemCell *)[self.previewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        switch (self.item.type) {
            case ItemTypeAudio:
            case ItemTypePeerAudio:
            case ItemTypeFile:
            case ItemTypePeerFile:
            case ItemTypeLink:
            case ItemTypePeerLink:
            case ItemTypeMessage:
            case ItemTypePeerMessage:
            case ItemTypeImage:
            case ItemTypePeerImage:
            case ItemTypeVideo:
            case ItemTypePeerVideo: {
                [itemCell bindWithItem:self.item conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                break;
            }
                
            default:
                [itemCell bindWithItem:self.item conversationViewController:self.conversationViewController];
                break;
        }
        if (items.count == 0) {
            return;
        }
    }
}


#pragma mark - ShareServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {

    [self.previewTableView reloadData];
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    self.refreshTableScheduled = YES;
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    [self reloadContactTableData];
}

- (void)onCreateContact:(TLContact *)contact avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);

    self.refreshTableScheduled = YES;
    [self updateUIContact:contact avatar:avatar];
    [self reloadContactTableData];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    self.refreshTableScheduled = YES;
    [self updateUIContact:contact avatar:avatar];
    [self reloadContactTableData];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    self.refreshTableScheduled = YES;
    for (UIContact *uiContact in self.uiContacts) {
        if ([uiContact.contact.uuid isEqual:contactId]) {
            [self.uiContacts removeObject:uiContact];
            break;
        }
    }
    [self reloadContactTableData];
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
    self.refreshTableScheduled = YES;
    [self.uiGroups removeAllObjects];
    
    for (TLGroup *group in groups) {
        [self updateUIGroup:group avatar:nil];
    }
    [self reloadContactTableData];
}

- (void)onCreateGroup:(TLGroup *)group conversation:(id<TLGroupConversation>)conversation {
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    self.refreshTableScheduled = YES;
    [self updateUIGroup:group avatar:avatar];
    [self reloadContactTableData];
}

- (void)onDeleteGroup:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
    self.refreshTableScheduled = YES;
    for (UIContact *uiContact in self.uiGroups) {
        if ([uiContact.contact.uuid isEqual:groupId]) {
            [self.uiGroups removeObject:uiContact];
            break;
        }
    }
    
    [self reloadContactTableData];
}

- (void)onGetConversation:(id<TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
    if (self.descriptorId) {
        BOOL copyAllowed;
        
        if (self.descriptorType == TLDescriptorTypeObjectDescriptor) {
            copyAllowed = self.twinmeApplication.allowCopyText;
        } else {
            copyAllowed = self.twinmeApplication.allowCopyFile;
        }
        [self.shareService forwardDescriptor:self.descriptorId copyAllowed:copyAllowed];

    } else if (self.fileURL) {
        BOOL toBeDeleted = YES;

        if ([self isImageFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeImageDescriptor toBeDeleted:toBeDeleted copyAllowed:self.twinmeApplication.allowCopyFile];
        } else if ([self isVideoFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeVideoDescriptor toBeDeleted:toBeDeleted copyAllowed:self.twinmeApplication.allowCopyFile];
        } else if ([self isAudioFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:toBeDeleted copyAllowed:self.twinmeApplication.allowCopyFile];
        } else {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeNamedFileDescriptor toBeDeleted:toBeDeleted copyAllowed:self.twinmeApplication.allowCopyFile];
        }
    } else if (self.content) {
        [self.shareService pushMessage:self.content copyAllowed:self.twinmeApplication.allowCopyText];
    }
    
    if (self.comment && ![self.comment isEqualToString:@""]) {
        [self.shareService pushMessage:self.comment copyAllowed:self.twinmeApplication.allowCopyText];
    }

    if (self.uiSelectedContact.count == 0) {
        [self.shareService dispose];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIContact *selectedContact = [self.uiSelectedContact objectAtIndex:0];
        [self.uiSelectedContact removeObjectAtIndex:0];

        if (selectedContact.contact.isGroup) {
            [self.shareService getConversationWithGroup:(TLGroup *)selectedContact.contact];
        } else {
            [self.shareService getConversationWithContact:(TLContact *)selectedContact.contact];
        }
    }
}

#pragma mark - Private

- (void)updateUIContact:(TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiContacts) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiContacts removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact];
    }
    if (!avatar && [contact hasPeer]) {
        [self.shareService getImageWithContact:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiContacts.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiContacts[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiContacts insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiContacts addObject:uiContact];
    }
}

- (void)updateUIGroup:(TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiGroups) {
        if ([lUIContact.contact.uuid isEqual:group.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiGroups removeObject:uiContact];
        [uiContact setContact:group];
    } else {
        uiContact = [[UIContact alloc] initWithContact:group];
    }
    if (!avatar) {
        [self.shareService getImageWithGroup:group withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiGroups.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiGroups[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiGroups insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiGroups addObject:uiContact];
    }
}

- (void)reloadContactTableData {
    DDLogVerbose(@"%@ reloadContactTableData", LOG_TAG);
    
    self.refreshTableScheduled = NO;
    if (self.uiInitialized) {
        [self.contactsTableView reloadData];
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.contactsTableView reloadData];
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiContacts removeAllObjects];
    [self.uiGroups removeAllObjects];
    
    if (![searchText isEqualToString:@""]) {
        [self.shareService findContactsAndGroupsByName:searchText space:self.currentSpace];
    } else {
        [self.shareService getContactsAndGroups: self.currentSpace];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.shareService getContactsAndGroups: self.currentSpace];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    if (tableView == self.contactsTableView) {
        return SHARE_VIEW_SECTION_COUNT;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.contactsTableView) {
        if (section == CONTACTS_VIEW_SECTION) {
            return self.uiContacts.count;
        } else if (section == GROUPS_VIEW_SECTION) {
            return self.uiGroups.count;
        }
        
        return 1;
    } else if (self.item && tableView == self.previewTableView) {
        return 2;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.contactsTableView) {
        switch (section) {
            case CONTACTS_VIEW_SECTION: {
                if (self.uiContacts.count > 0) {
                    if (self.item) {
                        return DESIGN_SECTION_CONTACT_HEIGHT * Design.HEIGHT_RATIO;
                    }
                    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
                }
                break;
            }
            case GROUPS_VIEW_SECTION: {
                if (self.uiGroups.count > 0) {
                    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
                }
                break;
            }
            default:
                break;
        }
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (tableView == self.contactsTableView) {
        if (indexPath.section == SELECTED_VIEW_SECTION) {
            if (self.uiSelectedContact.count > 0) {
                return DESIGN_SELECTED_MEMBERS_HEIGHT * Design.HEIGHT_RATIO;
            }
            return 1;
        }
        
        return Design.CELL_HEIGHT;
    } else {
        if (indexPath.row == 0) {
            return UITableViewAutomaticDimension;
        } else {
            return DESIGN_COMMENT_CELL_HEIGHT * Design.HEIGHT_RATIO;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.previewTableView || section == SELECTED_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    ShareSectionHeaderCell *shareSectionHeaderCell = (ShareSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    if (!shareSectionHeaderCell) {
        shareSectionHeaderCell = [[ShareSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    switch (section) {
        case CONTACTS_VIEW_SECTION: {
            if (self.uiContacts.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_contact_list_title", nil);
            }
            break;
        }
        case GROUPS_VIEW_SECTION: {
            if (self.uiGroups.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_group_list_title", nil);
            }
            break;
        }
        default:
            break;
    }
    [shareSectionHeaderCell bindWithTitle:sectionName];
    
    return shareSectionHeaderCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (tableView == self.contactsTableView) {
        if (indexPath.section == SELECTED_VIEW_SECTION) {
            SelectedMembersCell *selectedMemberCell = (SelectedMembersCell *)[tableView dequeueReusableCellWithIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
            if (!selectedMemberCell) {
                selectedMemberCell = [[SelectedMembersCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
            }
            
            [selectedMemberCell bindWithMembers:self.uiSelectedContact fromCreateGroup:NO adminAvatar:nil];
            
            return selectedMemberCell;
        } else {
            AddGroupMemberCell *contactCell = (AddGroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
            if (!contactCell) {
                contactCell = [[AddGroupMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
            }
            
            UIContact *uiContact = nil;
            BOOL hideSeparator = NO;
            if (indexPath.section == CONTACTS_VIEW_SECTION) {
                uiContact = self.uiContacts[indexPath.row];
                hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
            } else {
                uiContact = self.uiGroups[indexPath.row];
                hideSeparator = indexPath.row + 1 == self.uiGroups.count ? YES : NO;
            }
            
            if ([self isSelectedContact:uiContact]) {
                [contactCell setChecked:YES];
            } else {
                [contactCell setChecked:NO];
            }
            
            [contactCell bindWithName:uiContact.name avatar:uiContact.avatar isCertified:uiContact.isCertified hideSeparator:hideSeparator];
            
            return contactCell;
        }
    } else {
        if (indexPath.row == 0) {
            if (self.keyboardHidden) {
                self.item.mode = ItemModePreview;
            } else {
                self.item.mode = ItemModeSmallPreview;
            }
            
            self.item.replyAllowed = NO;
            switch (self.item.type) {
                case ItemTypeMessage: {
                    MessageItem *messageItem = (MessageItem *)self.item;
                    MessageItemCell *messageItemCell = (MessageItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [messageItemCell bindWithItem:messageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return messageItemCell;
                }
                    
                case ItemTypePeerMessage: {
                    PeerMessageItem *peerMessageItem = (PeerMessageItem *)self.item;
                    PeerMessageItemCell *peerMessageItemCell = (PeerMessageItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerMessageItemCell bindWithItem:peerMessageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerMessageItemCell;
                }
                    
                case ItemTypeLink: {
                    LinkItem *linkItem = (LinkItem *)self.item;
                    LinkItemCell *linkItemCell = (LinkItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [linkItemCell bindWithItem:linkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return linkItemCell;
                }
                    
                case ItemTypePeerLink: {
                    PeerLinkItem *peerLinkItem = (PeerLinkItem *)self.item;
                    PeerLinkItemCell *peerLinkItemCell = (PeerLinkItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerLinkItemCell bindWithItem:peerLinkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerLinkItemCell;
                }
                    
                case ItemTypeImage: {
                    ImageItem *imageItem = (ImageItem *)self.item;
                    ImageItemCell *imageItemCell = (ImageItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [imageItemCell bindWithItem:imageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return imageItemCell;
                }
                    
                case ItemTypePeerImage: {
                    PeerImageItem *peerImageItem = (PeerImageItem *)self.item;
                    PeerImageItemCell *peerImageItemCell = (PeerImageItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerImageItemCell bindWithItem:peerImageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerImageItemCell;
                }
                    
                case ItemTypeAudio: {
                    AudioItem *audioItem = (AudioItem *)self.item;
                    AudioItemCell *audioItemCell = (AudioItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [audioItemCell bindWithItem:audioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return audioItemCell;
                }
                    
                case ItemTypePeerAudio: {
                    PeerAudioItem *peerAudioItem = (PeerAudioItem *)self.item;
                    PeerAudioItemCell *peerAudioItemCell = (PeerAudioItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerAudioItemCell bindWithItem:peerAudioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerAudioItemCell;
                }
                    
                case ItemTypeVideo: {
                    VideoItem *videoItem = (VideoItem *)self.item;
                    VideoItemCell *videoItemCell = (VideoItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [videoItemCell bindWithItem:videoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return videoItemCell;
                }
                    
                case ItemTypePeerVideo: {
                    PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.item;
                    PeerVideoItemCell *peerVideoItemCell = (PeerVideoItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerVideoItemCell bindWithItem:peerVideoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerVideoItemCell;
                }
                    
                case ItemTypeFile: {
                    FileItem *fileItem = (FileItem *)self.item;
                    FileItemCell *fileItemCell = (FileItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [fileItemCell bindWithItem:fileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return fileItemCell;
                }
                    
                case ItemTypePeerFile: {
                    PeerFileItem *peerFileItem = (PeerFileItem *)self.item;
                    PeerFileItemCell *peerFileItemCell = (PeerFileItemCell *)[self.previewTableView dequeueReusableCellWithIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerFileItemCell bindWithItem:peerFileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    return peerFileItemCell;
                }
                    
                default:
                    break;
            }
            
            return [[UITableViewCell alloc]init];
        } else {
            AddCommentCell *addCommentCell = (AddCommentCell *)[tableView dequeueReusableCellWithIdentifier:ADD_COMMENT_CELL_IDENTIFIER];
            if (!addCommentCell) {
                addCommentCell = [[AddCommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_COMMENT_CELL_IDENTIFIER];
            }
            
            addCommentCell.addCommentDelegate = self;
            [addCommentCell bind];
            
            return addCommentCell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (tableView == self.contactsTableView) {
        [self.contactsTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (indexPath.section == SELECTED_VIEW_SECTION) {
            return;
        }
        
        UIContact *contact;
        
        if (indexPath.section == CONTACTS_VIEW_SECTION) {
            contact = [self.uiContacts objectAtIndex:indexPath.row];
        } else if (indexPath.section == GROUPS_VIEW_SECTION) {
            contact = [self.uiGroups objectAtIndex:indexPath.row];
        }
        
        if (!contact) {
            return;
        }
        
        AddGroupMemberCell *addGroupMemberCell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
        SelectedMembersCell *selectedMemberCell = [self.contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SELECTED_VIEW_SECTION]];
        NSInteger indexContact = [self indexForContact:contact];
        if (indexContact != -1) {
            NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForItem:indexContact inSection:0];
            [self.uiSelectedContact removeObjectAtIndex:indexContact];
            [selectedMemberCell.membersCollectionView deleteItemsAtIndexPaths:@[deletedIndexPath]];
            [addGroupMemberCell setChecked:NO];
        } else {
            [self.uiSelectedContact addObject:contact];
            NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForItem:self.uiSelectedContact.count - 1 inSection:0];
            [selectedMemberCell.membersCollectionView insertItemsAtIndexPaths:@[insertedIndexPath]];
            [selectedMemberCell.membersCollectionView scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [addGroupMemberCell setChecked:YES];
        }
        
        if (self.uiSelectedContact.count > 0) {
            self.sendBarButtonItem.enabled = YES;
        } else {
            self.sendBarButtonItem.enabled = NO;
        }
        
        [self.contactsTableView reloadData];
    }
}

#pragma mark - AddCommentDelegate

- (void)commentDidChange:(nullable NSString *)comment {
    DDLogVerbose(@"%@ commentDidChange: %@", LOG_TAG, comment);
    
    self.comment = comment;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    self.sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"feedback_view_controller_send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSendTapGesture:)];
    [self.sendBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.sendBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = self.sendBarButtonItem;
    self.sendBarButtonItem.enabled = NO;
    
    if (self.descriptorId) {
        [self setNavigationTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_forward_title", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedString(@"share_view_controller_title", nil)];
    }
    
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    
    UISearchBar *contactSearchBar = self.searchController.searchBar;
    contactSearchBar.barStyle = UIBarStyleDefault;
    contactSearchBar.searchBarStyle = UISearchBarStyleProminent;
    contactSearchBar.translucent = NO;
    contactSearchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    contactSearchBar.tintColor = [UIColor whiteColor];
    contactSearchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    contactSearchBar.backgroundImage = [UIImage new];
    contactSearchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    contactSearchBar.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.searchTextField.backgroundColor = [UIColor whiteColor];
        self.searchController.searchBar.searchTextField.tintColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.contactsTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.previewTableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.previewTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.previewTableView.delegate = self;
    self.previewTableView.dataSource = self;
    self.previewTableView.sectionHeaderHeight = 0;
    self.previewTableView.sectionFooterHeight = 0;
    self.previewTableView.rowHeight = UITableViewAutomaticDimension;
    self.previewTableView.estimatedRowHeight = Design.CELL_HEIGHT;
    self.previewTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.previewTableView.scrollEnabled = NO;
    
    [self.previewTableView registerNib:[UINib nibWithNibName:@"MessageItemCell" bundle:nil] forCellReuseIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerMessageItemCell" bundle:nil] forCellReuseIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"LinkItemCell" bundle:nil] forCellReuseIdentifier:LINK_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerLinkItemCell" bundle:nil] forCellReuseIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"ImageItemCell" bundle:nil] forCellReuseIdentifier:IMAGE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerImageItemCell" bundle:nil] forCellReuseIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"AudioItemCell" bundle:nil] forCellReuseIdentifier:AUDIO_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerAudioItemCell" bundle:nil] forCellReuseIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"VideoItemCell" bundle:nil] forCellReuseIdentifier:VIDEO_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerVideoItemCell" bundle:nil] forCellReuseIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:FILE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"PeerFileItemCell" bundle:nil] forCellReuseIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER];
    [self.previewTableView registerNib:[UINib nibWithNibName:@"AddCommentCell" bundle:nil] forCellReuseIdentifier:ADD_COMMENT_CELL_IDENTIFIER];
        
    self.contactsTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.sectionHeaderHeight = 0;
    self.contactsTableView.sectionFooterHeight = 0;
    
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"AddGroupMemberCell" bundle:nil] forCellReuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"SelectedMembersCell" bundle:nil] forCellReuseIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ShareSectionHeaderCell" bundle:nil] forCellReuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    
    self.uiInitialized = YES;
    
    [self.view layoutIfNeeded];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.asyncLoaderManager stop];
    self.asyncLoaderManager = nil;
    [self.shareService dispose];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)handleSendTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleSendTapGesture: %@", LOG_TAG, sender);
    
    self.sendBarButtonItem.enabled = NO;
         
    if (self.uiSelectedContact.count > 0) {
        UIContact *selectedContact = [self.uiSelectedContact objectAtIndex:0];
        
        [self.uiSelectedContact removeObjectAtIndex:0];
        if (selectedContact.contact.isGroup) {
            [self.shareService getConversationWithGroup:(TLGroup *)selectedContact.contact];
        } else {
            [self.shareService getConversationWithContact:(TLContact *)selectedContact.contact];
        }
    }
}

- (BOOL)isImageFile:(NSString *)file {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeImage);
    CFRelease(fileType);
    return result;
}

- (BOOL)isVideoFile:(NSString *)file {
    DDLogVerbose(@"%@ isVideoFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeMovie);
    CFRelease(fileType);
    return result;
}

- (BOOL)isAudioFile:(NSString *)file {
    DDLogVerbose(@"%@ isAudioFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeAudio);
    CFRelease(fileType);
    return result;
}

- (BOOL)isSelectedContact:(UIContact *)contact {
    DDLogVerbose(@"%@ isSelectedContact: %@", LOG_TAG, contact);

    for (UIContact *member in self.uiSelectedContact) {
        if ([contact.contact.uuid isEqual:member.contact.uuid]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)indexForContact:(UIContact *)contact {
    DDLogVerbose(@"%@ indexForContact: %@", LOG_TAG, contact);

    int index = -1;
    for (UIContact *member in self.uiSelectedContact) {
        index++;
        if ([contact.contact.uuid isEqual:member.contact.uuid]) {
            return index;
        }
    }
    return -1;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.sendBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.sendBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.contactsTableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
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
}

@end
