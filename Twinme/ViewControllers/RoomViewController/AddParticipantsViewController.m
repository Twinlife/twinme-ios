/*
 *  Copyright (c) 2021 twinlife SA.
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
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "AddParticipantsViewController.h"

#import "AddGroupMemberCell.h"
#import "SelectedMembersCell.h"
#import "UIContact.h"
#import <TwinmeCommon/InvitationRoomService.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ADD_GROUP_MEMBER_CELL_IDENTIFIER = @"AddGroupMemberCellIdentifier";
static NSString *SELECTED_CONTACTS_CELL_IDENTIFIER = @"SelectedMembersCellIdentifier";

static CGFloat DESIGN_TABLE_VIEW_TOP = 40;
static CGFloat DESIGN_SELECTED_CONTACTS_HEIGHT = 116;

static const int SECTION_COUNT = 2;

static const int SELECTED_CONTACTS_VIEW_SECTION = 0;
static const int CONTACTS_VIEW_SECTION = 1;

@interface AddParticipantsViewController() <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, InvitationRoomServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedMembersViewHeightConstraint;

@property (nonatomic) UIBarButtonItem *addBarButtonItem;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiSelectedContacts;
@property(nonatomic) TLContact *room;

@property (nonatomic) InvitationRoomService *invitationRoomService;

@end

//
// Implementation: AddParticipantsViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddParticipantsViewController"

@implementation AddParticipantsViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiSelectedContacts = [[NSMutableArray alloc] init];
        
        _invitationRoomService = [[InvitationRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self.invitationRoomService getContacts];
    
    [self updateSelectedContactView];
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
}

#pragma mark - InvitationRoomServiceDelegate

- (void)onGetContacts:(nonnull NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact];
    }
    [self.contactsTableView reloadData];
}

- (void)onSendTwincodeToContacts {
    DDLogVerbose(@"%@ onSendTwincodeToContacts", LOG_TAG);
    
    [self finish];
}

- (void)updateUIContact:(TLContact *)contact {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, contact);

    [self.invitationRoomService getImageWithContact:contact withBlock:^(UIImage *image) {
        [self updateUIContact:contact avatar:image];
    }];
}

- (void)updateUIContact:(nonnull TLContact *)contact avatar:(nonnull UIImage *)avatar {
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
        [uiContact setContact:contact avatar:avatar];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact avatar:avatar];
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiContacts removeAllObjects];
    
    if (![searchText isEqualToString:@""]) {
        [self.invitationRoomService findContactsByName:searchText];
    } else {
        [self.invitationRoomService getContacts];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.invitationRoomService getContacts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SELECTED_CONTACTS_VIEW_SECTION) {
        return 1;
    }
    
    return self.uiContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SELECTED_CONTACTS_VIEW_SECTION && self.uiSelectedContacts.count > 0) {
        return DESIGN_SELECTED_CONTACTS_HEIGHT * Design.HEIGHT_RATIO;
    } else if (indexPath.section == CONTACTS_VIEW_SECTION) {
        return Design.CELL_HEIGHT;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == CONTACTS_VIEW_SECTION && self.uiSelectedContacts.count > 0) {
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
        
        return addGroupMemberCell;
    } else {
        SelectedMembersCell *selectedMemberCell = (SelectedMembersCell *)[tableView dequeueReusableCellWithIdentifier:SELECTED_CONTACTS_CELL_IDENTIFIER];
        if (!selectedMemberCell) {
            selectedMemberCell = [[SelectedMembersCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SELECTED_CONTACTS_CELL_IDENTIFIER];
        }
        
        [selectedMemberCell bindWithMembers:self.uiSelectedContacts fromCreateGroup:NO adminAvatar:nil];
        
        return selectedMemberCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [self.contactsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIContact *selectContact = [self.uiContacts objectAtIndex:indexPath.row];
    
    AddGroupMemberCell *addGroupMemberCell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
    SelectedMembersCell *selectedMemberCell = [self.contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SELECTED_CONTACTS_VIEW_SECTION]];
    
    NSInteger indexContact = [self indexForSelectedContact:selectContact];
    if (indexContact != -1) {
        NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForItem:indexContact inSection:0];
        [self.uiSelectedContacts removeObjectAtIndex:indexContact];
        [selectedMemberCell.membersCollectionView deleteItemsAtIndexPaths:@[deletedIndexPath]];
        [addGroupMemberCell setChecked:NO];
    } else {
        [self.uiSelectedContacts addObject:selectContact];
        NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForItem:self.uiSelectedContacts.count - 1 inSection:0];
        [selectedMemberCell.membersCollectionView insertItemsAtIndexPaths:@[insertedIndexPath]];
        [selectedMemberCell.membersCollectionView scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [addGroupMemberCell setChecked:YES];
    }
    
    [self updateSelectedContactView];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"contacts_view_controller_invite_contact_title", nil)];
    
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
        self.contactsTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.contactsTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.sectionHeaderHeight = 0;
    self.contactsTableView.sectionFooterHeight = 0;
    
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"AddGroupMemberCell" bundle:nil] forCellReuseIdentifier:ADD_GROUP_MEMBER_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"SelectedMembersCell" bundle:nil] forCellReuseIdentifier:SELECTED_CONTACTS_CELL_IDENTIFIER];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.invitationRoomService) {
        [self.invitationRoomService dispose];
        self.invitationRoomService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.uiSelectedContacts.count > 0) {
        
        NSMutableArray *contactsToInvite = [[NSMutableArray alloc]init];
        for (UIContact *lUIContact in self.uiSelectedContacts) {
            [contactsToInvite addObject:lUIContact.contact];
        }
        
        [self.invitationRoomService inviteContactToRoom:contactsToInvite room:self.room];
    }
}

- (void)updateSelectedContactView {
    DDLogVerbose(@"%@ updateSelectedContactView", LOG_TAG);
    
    if (self.uiSelectedContacts.count > 0) {
        self.addBarButtonItem.enabled = YES;
    } else {
        self.addBarButtonItem.enabled = NO;
    }
    
    [self.contactsTableView reloadSections:[NSIndexSet indexSetWithIndex:SELECTED_CONTACTS_VIEW_SECTION] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)isSelectedContact:(UIContact *)contact {
    DDLogVerbose(@"%@ isSelectedContact: %@", LOG_TAG, contact);
    
    for (UIContact *uiContact in self.uiSelectedContacts) {
        if ([contact.contact.uuid isEqual:uiContact.contact.uuid]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)indexForSelectedContact:(UIContact *)contact {
    DDLogVerbose(@"%@ indexForSelectedContact: %@", LOG_TAG, contact);
    
    int index = -1;
    for (UIContact *uiContact in self.uiSelectedContacts) {
        index++;
        if ([contact.contact.uuid isEqual:uiContact.contact.uuid]) {
            return index;
        }
    }
    return -1;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.addBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.addBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.contactsTableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.contactsTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
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
