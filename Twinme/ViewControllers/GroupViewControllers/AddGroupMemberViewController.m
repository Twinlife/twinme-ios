/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "AddGroupMemberViewController.h"
#import <TwinmeCommon/GroupService.h>

#import "AddGroupMemberCell.h"
#import "SelectedMembersCell.h"
#import "UIContact.h"
#import "AlertMessageView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ADD_GROUP_MEMBER_CELL_IDENTIFIER = @"AddGroupMemberCellIdentifier";
static NSString *SELECTED_MEMBERS_CELL_IDENTIFIER = @"SelectedMembersCellIdentifier";

static CGFloat DESIGN_TABLE_VIEW_TOP = 40;
static CGFloat DESIGN_SELECTED_MEMBERS_HEIGHT = 116;

static NSInteger LIMIT_ALERT_VIEW_TAG = 1;

static const int SECTION_COUNT = 2;

static const int SELECTED_MEMBERS_VIEW_SECTION = 0;
static const int CONTACTS_VIEW_SECTION = 1;

@interface AddGroupMemberViewController () <GroupServiceDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UISearchBarDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *membersTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedMembersViewHeightConstraint;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UIBarButtonItem *addBarButtonItem;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiMembers;
@property (nonatomic) NSMutableArray *uiInvitedMembers;
@property (nonatomic) NSMutableArray *contactInvitations;
@property (nonatomic) TLGroup *group;
@property (nonatomic) id<TLGroupConversation> groupConversation;
@property (nonatomic) NSMutableDictionary<NSUUID *, TLInvitationDescriptor *> *pendingInvitations;

@property (nonatomic) GroupService *groupService;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL fromCreateGroup;
@property (nonatomic) UIImage *adminAvatar;

@end

//
// Implementation: AddGroupMemberViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddGroupMemberViewController"

@implementation AddGroupMemberViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiMembers = [[NSMutableArray alloc] init];
        _uiInvitedMembers = [[NSMutableArray alloc] init];
        _contactInvitations = [[NSMutableArray alloc] init];
        _needRefresh = NO;
        _keyboardHidden = YES;
        _fromCreateGroup = NO;
        
        _groupService = [[GroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self.groupService getContacts];
    [self initViews];
    
    [self.membersTableView reloadData];
    
    [self updateSelectedMemberView];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    [super viewWillAppear:animated];
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.groupService getContacts];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = YES;
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.membersTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.membersTableViewBottomConstraint.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    self.membersTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
}

#pragma mark - Public methods

- (void)initWithMembers:(NSMutableArray *)members fromCreateGroup:(BOOL)fromCreateGroup {
    DDLogVerbose(@"%@ initWithMembers: %@ fromCreateGroup: %@", LOG_TAG, members, fromCreateGroup ? @"YES":@"NO");
    
    self.fromCreateGroup = fromCreateGroup;
    
    if (self.fromCreateGroup) {
        [self.groupService getImageWithProfile:self.defaultProfile withBlock:^(UIImage *image) {
            self.adminAvatar = image;
        }];
    }
    
    self.uiMembers = members;
}

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
    
    [self.uiInvitedMembers removeAllObjects];
    
    self.refreshTableScheduled = YES;
    for (TLGroupMember *member in groupMembers) {
        [self updateUIContactWithGroupMember:member avatar:nil];
    }
    
    self.refreshTableScheduled = NO;
    [self.membersTableView reloadData];
}

- (void)onListPendingInvitations:(nonnull NSMutableDictionary<NSUUID *, TLInvitationDescriptor *> *)list {
    DDLogVerbose(@"%@ onListPendingInvitations: %@", LOG_TAG, list);

    self.pendingInvitations = list;
    
    for (NSUUID *uuid in self.pendingInvitations.allKeys) {
        for (UIContact *uiContact in self.uiContacts) {
            if ([uiContact.contact.uuid isEqual:uuid]) {
                [self.uiMembers addObject:uiContact];
                break;
            }
        }
    }
}

- (void)onInviteGroup:(id<TLConversation>)conversation invitation:(TLInvitationDescriptor *)invitation {
    DDLogVerbose(@"%@ onInviteGroup: %@", LOG_TAG, invitation);
    
    for (TLContact *contact in self.contactInvitations) {
        if ([contact.uuid isEqual:invitation.memberTwincodeId]) {
            [self.contactInvitations removeObject:contact];
            break;
        }
    }
    
    if (self.contactInvitations.count == 0) {
        [self finish];
    }
}

- (void)onErrorLimitReached {
    DDLogVerbose(@"%@ onErrorLimitReached",LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.tag = LIMIT_ALERT_VIEW_TAG;
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"application_group_limit_reached %@", nil), [NSString convertWithLocale:[NSString stringWithFormat:@"%d",[TLConversationService MAX_GROUP_MEMBERS]]]]];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    self.refreshTableScheduled = YES;
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    
    for (NSUUID *uuid in self.pendingInvitations.allKeys) {
        for (UIContact *uiContact in self.uiContacts) {
            if ([uiContact.contact.uuid isEqual:uuid]) {
                [self.uiMembers addObject:uiContact];
                break;
            }
        }
    }
    
    self.refreshTableScheduled = NO;
    [self.membersTableView reloadData];
    [self updateSelectedMemberView];
}

- (void)updateUIContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, contact);
    
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
    if (!avatar) {
        [self.groupService getImageWithContact:contact withBlock:^(UIImage *image) {
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

- (void)updateUIContactWithGroupMember:(TLGroupMember *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContactWithGroupMember: %@", LOG_TAG, contact);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiInvitedMembers) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiInvitedMembers removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact];
    }
    if (!avatar) {
        [self.groupService getImageWithGroupMember:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiInvitedMembers.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiInvitedMembers[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiInvitedMembers insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiInvitedMembers addObject:uiContact];
    }
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidEndEditing: %@", LOG_TAG, textField);
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiContacts removeAllObjects];
    
    if (![searchText isEqualToString:@""]) {
        [self.groupService findContactsByName:searchText];
    } else {
        [self.groupService getContacts];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.groupService getContacts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SELECTED_MEMBERS_VIEW_SECTION) {
        return 1;
    }
    
    return self.uiContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SELECTED_MEMBERS_VIEW_SECTION && (self.uiMembers.count > 0 || self.fromCreateGroup)) {
        return DESIGN_SELECTED_MEMBERS_HEIGHT * Design.HEIGHT_RATIO;
    } else if (indexPath.section == CONTACTS_VIEW_SECTION) {
        return Design.CELL_HEIGHT;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == CONTACTS_VIEW_SECTION && (self.uiMembers.count > 0 || self.fromCreateGroup)) {
        return DESIGN_TABLE_VIEW_TOP * Design.HEIGHT_RATIO;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CONTACTS_VIEW_SECTION) {
        AddGroupMemberCell *addGroupMemberCell = (AddGroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
        if (!addGroupMemberCell) {
            addGroupMemberCell = [[AddGroupMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
        }
        
        UIContact *uiContact = self.uiContacts[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
        [addGroupMemberCell bindWithName:uiContact.name avatar:uiContact.avatar isCertified:uiContact.isCertified hideSeparator:hideSeparator];
        if ([self isSelectedContact:uiContact]) {
            [addGroupMemberCell setChecked:YES];
        } else {
            [addGroupMemberCell setChecked:NO];
        }
        
        if (self.group && [self isInvitedContact:uiContact]) {
            [addGroupMemberCell setChecked:YES];
            [addGroupMemberCell setSelectable:NO];
        }
        
        return addGroupMemberCell;
    } else {
        SelectedMembersCell *selectedMemberCell = (SelectedMembersCell *)[tableView dequeueReusableCellWithIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
        if (!selectedMemberCell) {
            selectedMemberCell = [[SelectedMembersCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
        }
        
        [selectedMemberCell bindWithMembers:self.uiMembers fromCreateGroup:self.fromCreateGroup adminAvatar:self.adminAvatar];
        
        return selectedMemberCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [self.membersTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIContact *member = [self.uiContacts objectAtIndex:indexPath.row];
    if (self.group && [self isInvitedContact:member]) {
        return;
    }
    
    AddGroupMemberCell *addGroupMemberCell = [self.membersTableView cellForRowAtIndexPath:indexPath];
    SelectedMembersCell *selectedMemberCell = [self.membersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SELECTED_MEMBERS_VIEW_SECTION]];
    NSInteger indexContact = [self indexForMember:member];
    if (indexContact != -1) {
        NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForItem:indexContact inSection:0];
        [self.uiMembers removeObjectAtIndex:indexContact];
        [selectedMemberCell.membersCollectionView deleteItemsAtIndexPaths:@[deletedIndexPath]];
        [addGroupMemberCell setChecked:NO];
    } else {
        BOOL isMaxGroupMembers = NO;
        if (self.group) {
            int selectedMembersCount = (int) (self.uiMembers.count - self.uiInvitedMembers.count);
            if (([self.groupConversation groupMembersWithFilter:TLGroupMemberFilterTypeJoinedMembers].count + selectedMembersCount) >= [TLConversationService MAX_GROUP_MEMBERS]) {
                isMaxGroupMembers  = YES;
            }
        } else if ((self.uiMembers.count + 1) >= [TLConversationService MAX_GROUP_MEMBERS]) {
            isMaxGroupMembers  = YES;
        }
        
        if (isMaxGroupMembers) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"application_group_limit_reached %@", nil), [NSString convertWithLocale:[NSString stringWithFormat:@"%d",[TLConversationService MAX_GROUP_MEMBERS]]]]];
            [self.navigationController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            
            return;
        }
        
        [self.uiMembers addObject:member];
        NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForItem:self.uiMembers.count - 1 inSection:0];
        [selectedMemberCell.membersCollectionView insertItemsAtIndexPaths:@[insertedIndexPath]];
        [selectedMemberCell.membersCollectionView scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [addGroupMemberCell setChecked:YES];
    }
    
    [self updateSelectedMemberView];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    if (alertMessageView.tag == LIMIT_ALERT_VIEW_TAG) {
        [alertMessageView removeFromSuperview];
        
        [self finish];
    } else {
        [alertMessageView removeFromSuperview];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = Design.FONT_BOLD34;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = TwinmeLocalizedString(@"add_group_member_view_controller_title", nil);
    self.titleLabel.numberOfLines = 2;
    
    self.navigationItem.titleView = self.titleLabel;
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    self.addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_ok", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveTapGesture:)];
    [self.addBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.addBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
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
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.membersTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.membersTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.membersTableView.delegate = self;
    self.membersTableView.dataSource = self;
    self.membersTableView.sectionHeaderHeight = 0;
    self.membersTableView.sectionFooterHeight = 0;
    
    [self.membersTableView registerNib:[UINib nibWithNibName:@"AddGroupMemberCell" bundle:nil] forCellReuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
    [self.membersTableView registerNib:[UINib nibWithNibName:@"SelectedMembersCell" bundle:nil] forCellReuseIdentifier:SELECTED_MEMBERS_CELL_IDENTIFIER];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.groupService) {
        [self.groupService dispose];
        self.groupService = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.group) {
        [self.contactInvitations removeAllObjects];
        for (UIContact *contact in self.uiMembers) {
            if (![self isInvitedContact:contact] && [(NSObject *)contact.contact isKindOfClass:[TLContact class]]) {
                [self.contactInvitations addObject:contact.contact];
            }
        }
        [self.groupService inviteGroupWithContacts:self.contactInvitations];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.groupService dispose];
            [self.addGroupMemberDelegate addGroupMemberViewController:self didFinishPickingMembers:self.uiMembers];
        }];
    }
}

- (void)updateSelectedMemberView {
    DDLogVerbose(@"%@ updateSelectedMemberView", LOG_TAG);
    
    self.addBarButtonItem.enabled = YES;
    
    int memberCount = (int) self.uiMembers.count;
    if (self.fromCreateGroup) {
        memberCount++;
    }
    
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"add_group_member_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObject:Design.FONT_BOLD34 forKey:NSFontAttributeName]];
    [titleAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [titleAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d / %d", memberCount, [TLConversationService MAX_GROUP_MEMBERS]] attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR30 forKey:NSFontAttributeName]]];
    self.titleLabel.attributedText = titleAttributedString;
    
    [self.membersTableView reloadSections:[NSIndexSet indexSetWithIndex:SELECTED_MEMBERS_VIEW_SECTION] withRowAnimation:UITableViewRowAnimationNone];
    [self.titleLabel sizeToFit];
    self.navigationItem.titleView = self.titleLabel;
}

- (BOOL)isSelectedContact:(UIContact *)contact {
    DDLogVerbose(@"%@ isSelectedContact: %@", LOG_TAG, contact);
    
    for (UIContact *member in self.uiMembers) {
        if ([contact.contact.uuid isEqual:member.contact.uuid]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isInvitedContact:(UIContact *)contact {
    DDLogVerbose(@"%@ isInvitedContact: %@", LOG_TAG, contact);
    
    for (UIContact *member in self.uiInvitedMembers) {
        if ([contact.contact.uuid isEqual:member.contact.uuid]) {
            return YES;
        }
    }
    
    for (NSUUID *uuid in self.pendingInvitations.allKeys) {
        if ([contact.contact.uuid isEqual:uuid]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)indexForMember:(UIContact *)contact {
    DDLogVerbose(@"%@ indexForMember: %@", LOG_TAG, contact);
    
    int index = -1;
    for (UIContact *member in self.uiMembers) {
        index++;
        if ([contact.contact.uuid isEqual:member.contact.uuid]) {
            return index;
        }
    }
    return -1;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.addBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.addBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.membersTableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.membersTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
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
