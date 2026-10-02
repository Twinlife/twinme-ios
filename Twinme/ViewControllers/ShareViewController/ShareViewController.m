/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <UniformTypeIdentifiers/UTCoreTypes.h>
#import <UniformTypeIdentifiers/UTType.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "ShareViewController.h"
#import "ConversationViewController.h"
#import "SpacesViewController.h"
#import "ShareSectionHeaderCell.h"
#import "Item.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "VideoItem.h"
#import "PeerVideoItem.h"

#import "AddGroupMemberCell.h"
#import "SelectedGroupMemberCell.h"
#import "UIContact.h"
#import "UISpace.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/ShareService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ApplicationDelegate.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/AsyncManager.h>
#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/ShareService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import <Twinlife/TLConversationService.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_DEFAULT_TEXT_MARGIN = 24;

static NSString *ADD_GROUP_MEMBER_CELL_IDENTIFIER = @"AddGroupMemberCellIdentifier";
static NSString *SHARE_SECTION_HEADER_CELL_IDENTIFIER = @"ShareSectionHeaderCellIdentifier";
static NSString *SELECTED_GROUP_MEMBER_CELL_IDENTIFIER = @"SelectedGroupMemberCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 116;
static CGFloat DESIGN_SECTION_HEIGHT = 110;
static CGFloat DESIGN_SECTION_CONTACT_HEIGHT = 60;
static const CGFloat DESIGN_HEIGHT_INSET = 24;
static CGFloat DESIGN_RIGHT_BUTTON_WIDTH = 70.0;
static CGFloat DESIGN_RIGHT_BUTTON_HEIGHT = 44.0;
static CGFloat DESIGN_AVATAR_HEIGHT = 32.0;

static const int MAX_VISIBLE_LINES = 3;

static const int SHARE_VIEW_SECTION_COUNT = 2;

static const int CONTACTS_VIEW_SECTION = 0;
static const int GROUPS_VIEW_SECTION = 1;

//
// Interface: ShareViewController ()
//

@interface ShareViewController () <ShareServiceDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UITextViewDelegate, AsyncLoaderDelegate, SpacesPickerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *textContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *selectedCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *previewView;

@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UIImageView *spaceAvatarImageView;
@property (nonatomic) UILabel *spaceAvatarLabel;

@property (nonatomic) AsyncImageLoader *imageLoader;
@property (nonatomic) AsyncVideoLoader *videoLoader;
@property (nonatomic) AsyncManager *asyncLoaderManager;

@property (nonatomic) BOOL uiInitialized;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL needsCopyFile;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) CGFloat yOffset;

@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiContacts;
@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiGroups;
@property (nonatomic, readonly, nonnull) NSMutableArray<UIContact *> *uiSelectedContact;
@property (nonatomic) UIContact *selectedContact;

@property (nonatomic) TLSpace *space;
@property (nonatomic) UISpace *uiSpace;
@property (nonatomic, readonly, nonnull) ShareService *shareService;

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
        _needsCopyFile = YES;
        
        _shareService = [[ShareService alloc] initWithTwinmeContext:self.twinmeContext delegate:self fromExtension:NO];
        _asyncLoaderManager = [[AsyncManager alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self updateWithSpace:self.currentSpace];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.shareService getContactsAndGroups:self.space];
    }
    
    if (self.needsCopyFile && self.fileURL) {
        self.needsCopyFile = NO;
        [self copyFile];
    }
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self centerTextViewContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
     
    self.needRefresh = YES;
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidDisappear:animated];
    [self.asyncLoaderManager clear];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat value = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.bottomViewBottomConstraint.constant = value;
    [self updateBottomHeight];
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    UIWindow *window = [self currentWindow];
    CGFloat safeAreaInset;
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.view.safeAreaInsets.bottom;
    }
    
    self.bottomViewBottomConstraint.constant  = safeAreaInset;
    [self updateBottomHeight];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGFloat bottomViewHeight = self.uiSelectedContact.count > 0 ? self.bottomViewHeightConstraint.constant + self.bottomViewBottomConstraint.constant : 0;
    self.tableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y - bottomViewHeight;
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    if (self.imageLoader) {
        self.previewView.image = self.imageLoader.image;
    }
    
    if (self.videoLoader) {
        self.previewView.image = self.videoLoader.image;
    }
    
    [items removeAllObjects];
}

#pragma mark - ShareServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    [self updateWithSpace:space];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self updateWithSpace:space];
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
            copyAllowed = self.space.settings.messageCopyAllowed;
        } else {
            copyAllowed = self.space.settings.fileCopyAllowed;
        }
        [self.shareService forwardDescriptor:self.descriptorId copyAllowed:copyAllowed];

    } else if (self.fileURL) {

        if ([self isImageFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeImageDescriptor toBeDeleted:YES copyAllowed:self.space.settings.fileCopyAllowed timeout:0];
        } else if ([self isVideoFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeVideoDescriptor toBeDeleted:YES copyAllowed:self.space.settings.fileCopyAllowed timeout:0];
        } else if ([self isAudioFile:self.fileURL.path]) {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:YES copyAllowed:self.space.settings.fileCopyAllowed timeout:0];
        } else {
            [self.shareService pushFileWithPath:self.fileURL.path type:TLDescriptorTypeNamedFileDescriptor toBeDeleted:YES copyAllowed:self.space.settings.fileCopyAllowed timeout:0];
        }
    } else if (self.content) {
        [self.shareService pushMessage:self.content copyAllowed:self.space.settings.messageCopyAllowed timeout:0];
    }
    
    if (self.comment && ![self.comment isEqualToString:@""]) {
        [self.shareService pushMessage:self.comment copyAllowed:self.space.settings.messageCopyAllowed timeout:0];
    }

    if (self.uiSelectedContact.count == 0) {
        [self finish];
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

- (void)updateWithSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ updateWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    [self updateBarButtonItem:space];
    self.uiSpace = [self createUISpaceWithSpace:self.space service:self.shareService withRefresh:^(void) {
        [self refreshTable];
    }];
}

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
        [self.tableView reloadData];
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.tableView reloadData];
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiContacts removeAllObjects];
    [self.uiGroups removeAllObjects];
    
    if (![searchText isEqualToString:@""]) {
        [self.shareService findContactsAndGroupsByName:searchText space:self.space];
    } else {
        [self.shareService getContactsAndGroups:self.space];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.shareService getContactsAndGroups:self.space];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"conversation_view_message", nil)]) {
        textView.text = @"";
        textView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    [self centerTextViewContent];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"conversation_view_message", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

- (void)centerTextViewContent {
    DDLogVerbose(@"%@ centerTextViewContent", LOG_TAG);
        
    CGFloat textViewWidth = Design.DISPLAY_WIDTH - self.textContainerLeadingConstraint.constant - self.messageTextViewLeadingConstraint.constant - self.messageTextViewTrailingConstraint.constant - self.sendViewLeadingConstraint.constant - self.sendViewHeightConstraint.constant - self.sendViewTrailingConstraint.constant;
    
    CGRect textRect = [self.messageTextView.text boundingRectWithSize:CGSizeMake(textViewWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR32
    } context:nil];
    
    int countLines = textRect.size.height / Design.FONT_REGULAR32.lineHeight;
    
    float containerHeight = Design.FONT_REGULAR32.lineHeight * countLines + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    float minHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    float maxHeight = Design.FONT_REGULAR32.lineHeight * MAX_VISIBLE_LINES + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    if (containerHeight < minHeight) {
        containerHeight = minHeight;
    } else if (containerHeight > maxHeight) {
        containerHeight = maxHeight;
    }
    
    self.textContainerViewHeightConstraint.constant = containerHeight;
    [self updateBottomHeight];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        CGFloat emptySize = ([self.messageTextView bounds].size.height - [self.messageTextView contentSize].height);
        CGFloat inset = MAX(0, emptySize / 2.0);
        self.messageTextView.contentInset = UIEdgeInsetsMake(inset, self.messageTextView.contentInset.left, inset, self.messageTextView.contentInset.right);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SHARE_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONTACTS_VIEW_SECTION) {
        return self.uiContacts.count;
    } else {
        return self.uiGroups.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
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
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
        
    ShareSectionHeaderCell *shareSectionHeaderCell = (ShareSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    if (!shareSectionHeaderCell) {
        shareSectionHeaderCell = [[ShareSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    switch (section) {
        case CONTACTS_VIEW_SECTION: {
            if (self.uiContacts.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_contact_list", nil);
            }
            break;
        }
        case GROUPS_VIEW_SECTION: {
            if (self.uiGroups.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_group_list", nil);
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    UIContact *contact;
    
    if (indexPath.section == CONTACTS_VIEW_SECTION) {
        contact = [self.uiContacts objectAtIndex:indexPath.row];
    } else if (indexPath.section == GROUPS_VIEW_SECTION) {
        contact = [self.uiGroups objectAtIndex:indexPath.row];
    }
    
    if (!contact) {
        return;
    }
    
    AddGroupMemberCell *addGroupMemberCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSInteger indexContact = [self indexForContact:contact];
    if (indexContact != -1) {
        NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForItem:indexContact inSection:0];
        [self.uiSelectedContact removeObjectAtIndex:indexContact];
        [self.selectedCollectionView deleteItemsAtIndexPaths:@[deletedIndexPath]];
        [addGroupMemberCell setChecked:NO];
    } else {
        [self.uiSelectedContact addObject:contact];
        NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForItem:self.uiSelectedContact.count - 1 inSection:0];
        [self.selectedCollectionView insertItemsAtIndexPaths:@[insertedIndexPath]];
        [self.selectedCollectionView scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [addGroupMemberCell setChecked:YES];
    }
    
    [self updateBottomHeight];
    
    [self.tableView reloadData];
}

#pragma mark - SpacesPickerDelegate

- (void)didSelectSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ didSelectSpace: %@", LOG_TAG, space);
    
    [self updateWithSpace:space];
    [self.shareService getContactsAndGroups:self.space];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.uiSelectedContact.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
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
    
    SelectedGroupMemberCell *groupMemberCell = [collectionView dequeueReusableCellWithReuseIdentifier:SELECTED_GROUP_MEMBER_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIContact *uiMember = self.uiSelectedContact[indexPath.row];
    UIImage *avatar = uiMember.avatar;
    [groupMemberCell bindWithAvatar:avatar];

    return groupMemberCell;
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
        
    if (self.descriptorId) {
        [self setNavigationTitle:TwinmeLocalizedString(@"conversation_view_menu_item_view_forward_title", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedString(@"share_view_title", nil)];
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
    
    self.searchController.searchBar.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchController.searchBar.searchTextField.tintColor = Design.POPUP_BACKGROUND_COLOR;
    self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
    self.searchController.searchBar.translucent = NO;
    self.navigationItem.searchController = self.searchController;
            
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddGroupMemberCell" bundle:nil] forCellReuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShareSectionHeaderCell" bundle:nil] forCellReuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    
    self.selectedCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.selectedCollectionViewHeightConstraint.constant = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.selectedCollectionView setCollectionViewLayout:viewFlowLayout];
    self.selectedCollectionView.dataSource = self;
    self.selectedCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.selectedCollectionView registerNib:[UINib nibWithNibName:@"SelectedGroupMemberCell" bundle:nil] forCellWithReuseIdentifier:SELECTED_GROUP_MEMBER_CELL_IDENTIFIER];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    UIWindow *window = [self currentWindow];
    CGFloat safeAreaInset;
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.view.safeAreaInsets.bottom;
    }
    
    self.bottomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.bottomViewBottomConstraint.constant = safeAreaInset;

    self.bottomView.backgroundColor = Design.WHITE_COLOR;
    self.bottomView.hidden = YES;
    
    self.previewViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.previewViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.previewView.clipsToBounds = YES;
    self.previewView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    CGFloat sendViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    
    self.textContainerViewHeightConstraint.constant = sendViewHeight;
    self.textContainerLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.textContainerTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.textContainerTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.textContainerView.backgroundColor = Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
    self.textContainerView.clipsToBounds = YES;
    self.textContainerView.layer.cornerRadius = self.textContainerViewHeightConstraint.constant * 0.5;
    
    if ([self isMediaItem]) {
        self.previewView.hidden = NO;
        [self updatePreview];
    } else {
        self.previewViewHeightConstraint.constant = 0;
        self.textContainerLeadingConstraint.constant = 0;
        self.previewView.hidden = YES;
    }
    
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTopConstraint.constant = 0;
    self.messageTextViewBottomConstraint.constant = 0;
    
    self.messageTextView.textContainerInset = UIEdgeInsetsMake(DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0, DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0);
    self.messageTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageTextView.font = Design.FONT_REGULAR32;
    self.messageTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.messageTextView.returnKeyType = UIReturnKeyDefault;
    self.messageTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    self.messageTextView.delegate = self;
    self.messageTextView.text = TwinmeLocalizedString(@"conversation_view_message", nil);
    self.messageTextView.textColor = Design.PLACEHOLDER_COLOR;
    
    self.sendViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.clipsToBounds = YES;
    self.sendView.layer.cornerRadius =  self.sendViewHeightConstraint.constant * 0.5f;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_send", nil);
    self.sendView.isAccessibilityElement = YES;
    [self.sendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendTapGesture:)]];
    
    self.sendImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sendImageView.image =  [self.sendImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    [self updateBottomHeight];
    self.uiInitialized = YES;
    
    [self.view layoutIfNeeded];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    
    if ([mainViewController numberSpaces:NO] > 1) {
        CGFloat customRightViewWidth = DESIGN_RIGHT_BUTTON_WIDTH * Design.WIDTH_RATIO;
        UIView *customRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, customRightViewWidth, DESIGN_RIGHT_BUTTON_HEIGHT)];
        customRightView.userInteractionEnabled = YES;
        UITapGestureRecognizer *avatarGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpaceTapGesture:)];
        [customRightView addGestureRecognizer:avatarGestureRecognizer];
        customRightView.isAccessibilityElement = YES;
        
        self.spaceAvatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DESIGN_AVATAR_HEIGHT, DESIGN_AVATAR_HEIGHT)];
        self.spaceAvatarImageView.clipsToBounds = YES;
        self.spaceAvatarImageView.userInteractionEnabled = YES;
        self.spaceAvatarImageView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * DESIGN_AVATAR_HEIGHT;
        [customRightView addSubview:self.spaceAvatarImageView];
        self.spaceAvatarImageView.center = CGPointMake(customRightView.frame.size.width * 0.5, customRightView.frame.size.height * 0.5);
        
        self.spaceAvatarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DESIGN_AVATAR_HEIGHT, DESIGN_AVATAR_HEIGHT)];
        self.spaceAvatarLabel.textColor = [UIColor whiteColor];
        self.spaceAvatarLabel.font = Design.FONT_BOLD36;
        self.spaceAvatarLabel.textAlignment = NSTextAlignmentCenter;
        [customRightView addSubview:self.spaceAvatarLabel];
        self.spaceAvatarLabel.center = CGPointMake(customRightView.frame.size.width * 0.5, customRightView.frame.size.height * 0.5);
            
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:customRightView];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        [self updateWithSpace:self.currentSpace];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.shareService dispose];
    
    [self.asyncLoaderManager stop];
    self.asyncLoaderManager = nil;
    
    if (self.imageLoader) {
        [self.imageLoader cancel];
        self.imageLoader = nil;
    }
    
    if (self.videoLoader) {
        [self.videoLoader cancel];
        self.videoLoader = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (self.fileURL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.fileURL.path]) {
            [fileManager removeItemAtPath:self.fileURL.path error:nil];
        }
    }

    [self finish];
}

- (void)handleSendTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleSendTapGesture: %@", LOG_TAG, sender);
 
    if (self.uiSelectedContact.count > 0) {
        
        if (![self.messageTextView.text isEqual:TwinmeLocalizedString(@"conversation_view_message", nil)]) {
            self.comment = self.messageTextView.text;
        }
                    
        UIContact *selectedContact = [self.uiSelectedContact objectAtIndex:0];
        [self.uiSelectedContact removeObjectAtIndex:0];
        if (selectedContact.contact.isGroup) {
            [self.shareService getConversationWithGroup:(TLGroup *)selectedContact.contact];
        } else {
            [self.shareService getConversationWithContact:(TLContact *)selectedContact.contact];
        }
    }
}

- (void)updateBarButtonItem:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ updateBarButtonItem", LOG_TAG);
    
    if (space.avatarId) {
        self.spaceAvatarLabel.hidden = YES;
        self.spaceAvatarImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.spaceAvatarImageView.layer.borderWidth = 0.0;
        [self.shareService getImageWithSpace:space withBlock:^(UIImage *image) {
            self.spaceAvatarImageView.image = image;
        }];
    } else {
        self.spaceAvatarImageView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        self.spaceAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.spaceAvatarImageView.layer.borderWidth = 1.0;
        if (space.settings.style) {
            self.spaceAvatarImageView.backgroundColor = [UIColor colorWithHexString:space.settings.style alpha:1.0];
        } else {
            self.spaceAvatarImageView.backgroundColor = Design.MAIN_COLOR;
        }
        
        self.spaceAvatarLabel.text = [NSString firstCharacter:space.settings.name];
    }
}

- (BOOL)isImageFile:(NSString *)file {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeImage];
}

- (BOOL)isVideoFile:(NSString *)file {
    DDLogVerbose(@"%@ isVideoFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeMovie];
}

- (BOOL)isAudioFile:(NSString *)file {
    DDLogVerbose(@"%@ isAudioFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeAudio];
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

- (void)copyFile {
    DDLogVerbose(@"%@ copyFile", LOG_TAG);
    
    BOOL access = [self.fileURL startAccessingSecurityScopedResource];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = self.fileURL.lastPathComponent;
    NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:tmpUrl.path]) {
        [fileManager removeItemAtPath:tmpUrl.path error:nil];
    }

    BOOL success = [fileManager copyItemAtURL:self.fileURL toURL:tmpUrl error:&error];
    if (access) {
        [self.fileURL stopAccessingSecurityScopedResource];
    }
    
    if (success) {
        self.fileURL = tmpUrl;
    } else {
        [self finish];
    }
}

- (void)handleSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceTapGesture: %@", LOG_TAG, sender);
    
    SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
    spacesViewController.pickerMode = YES;
    spacesViewController.spacesPickerDelegate = self;
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)updateBottomHeight {
    DDLogVerbose(@"%@ updateBottomHeight", LOG_TAG);
    
    if (!self.previewView.hidden) {
        if (self.previewViewHeightConstraint.constant > self.textContainerViewHeightConstraint.constant) {
            self.textContainerTopConstraint.constant = (DESIGN_DEFAULT_TEXT_MARGIN * Design.HEIGHT_RATIO) + (self.previewViewHeightConstraint.constant - self.textContainerViewHeightConstraint.constant);
        } else {
            self.textContainerTopConstraint.constant = (DESIGN_DEFAULT_TEXT_MARGIN * Design.HEIGHT_RATIO);
        }
    }
    
    CGFloat textContentHeight = self.textContainerTopConstraint.constant + self.textContainerViewHeightConstraint.constant;
    CGFloat selectedContactsHeight = self.selectedCollectionViewTopConstraint.constant + self.selectedCollectionViewHeightConstraint.constant;
    CGFloat contentHeight = textContentHeight + selectedContactsHeight;
    CGFloat bottomViewHeight = MAX(contentHeight, self.sendViewHeightConstraint.constant);
    
    self.bottomViewHeightConstraint.constant = bottomViewHeight;
    self.bottomView.hidden = self.uiSelectedContact.count == 0;
    self.tableViewBottomConstraint.constant = self.bottomView.hidden ? 0 : bottomViewHeight + self.bottomViewBottomConstraint.constant;
}

- (void)updatePreview {
    DDLogVerbose(@"%@ updatePreview", LOG_TAG);
    
    UIImage *image;
    if (self.item.type == ItemTypeVideo || self.item.type == ItemTypePeerVideo) {
        TLVideoDescriptor *videoDescriptor;
        if (self.item.isPeerItem) {
            PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.item;
            videoDescriptor = peerVideoItem.videoDescriptor;
        } else {
            VideoItem *videoItem = (VideoItem *)self.item;
            videoDescriptor = videoItem.videoDescriptor;
        }
        
        // Use an async loader to get the video thumbnail.
        if (!self.videoLoader) {
            self.videoLoader = [[AsyncVideoLoader alloc] initWithItem:self.item videoDescriptor:videoDescriptor size:CGSizeMake(self.previewViewHeightConstraint.constant, self.previewViewHeightConstraint.constant)];
            if (!self.videoLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.videoLoader];
            }
        }

        image = self.videoLoader.image;
        if (image) {
            self.previewView.image = image;
        }
    } else {
        TLImageDescriptor *imageDescriptor;
        if (self.item.isPeerItem) {
            PeerImageItem *peerImageItem = (PeerImageItem *)self.item;
            imageDescriptor = peerImageItem.imageDescriptor;
        } else {
            ImageItem *imageItem = (ImageItem *)self.item;
            imageDescriptor = imageItem.imageDescriptor;
        }
                
        // Use an async loader to get the image thumbnail.
        if (!self.imageLoader) {
            self.imageLoader = [[AsyncImageLoader alloc] initWithItem:self.item imageDescriptor:imageDescriptor size:CGSizeMake(self.previewViewHeightConstraint.constant, self.previewViewHeightConstraint.constant)];
            
            if (!self.imageLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.imageLoader];
            }
        }
        image = self.imageLoader.image;
    }
    
    if (image) {
        self.previewView.image = image;
    } else {
        self.previewView.image = nil;
    }
}

- (BOOL)isMediaItem {
    DDLogVerbose(@"%@ isMediaItem", LOG_TAG);
    
    return self.item.type == ItemTypeImage || self.item.type == ItemTypePeerImage || self.item.type == ItemTypeVideo || self.item.type == ItemTypePeerVideo;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.searchController.searchBar.backgroundColor = [UIColor clearColor];
    self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.searchController.searchBar.searchTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.searchController.searchBar.searchTextField.textColor = Design.FONT_COLOR_DEFAULT;
    
    UIImageView *glassIconImageView = (UIImageView *)self.searchController.searchBar.searchTextField.leftView;
    glassIconImageView.image = [glassIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    glassIconImageView.tintColor = Design.PLACEHOLDER_COLOR;
    
    if ([self.twinmeApplication darkModeEnable:[self currentSpaceSettings]]) {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
