/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ContactsService.h>

#import "NewConversationViewController.h"
#import "ConversationViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/MainViewController.h>
#import "ShareSectionHeaderCell.h"
#import "CreateGroupViewController.h"

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"

#import "AddGroupCell.h"
#import "ContactCell.h"
#import "UIContact.h"
#import <TwinmeCommon/ApplicationDelegate.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ADD_GROUP_CELL_IDENTIFIER = @"AddGroupCellIdentifier";
static NSString *CONTACT_CELL_IDENTIFIER = @"ContactCellIdentifier";
static NSString *SHARE_SECTION_HEADER_CELL_IDENTIFIER = @"ShareSectionHeaderCellIdentifier";

static CGFloat DESIGN_SECTION_HEIGHT = 110;

static const int NEW_CONVERSATION_VIEW_SECTION_COUNT = 2;

static const int CREATE_GROUP_SECTION = 0;
static const int CONTACTS_VIEW_SECTION = 1;

//
// Interface: NewConversationViewController ()
//

@interface NewConversationViewController () <ContactsServiceDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTableViewBottomConstraint;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic) BOOL uiInitialized;
@property (nonatomic) NSMutableArray<UIContact *> *uiContacts;
@property (nonatomic) NSMutableArray<UIContact *> *uiGroups;
@property (nonatomic) UIContact *selectedContact;

@property (nonatomic) ContactsService *contactsService;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL keyboardHidden;

@end

//
// Implementation: NewConversationViewController
//

#undef LOG_TAG
#define LOG_TAG @"NewConversationViewController"

@implementation NewConversationViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiGroups = [[NSMutableArray alloc] init];
        _needRefresh = NO;
        _keyboardHidden = YES;
        
        _contactsService = [[ContactsService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
        [self.contactsService getContacts];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.contactsTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.contactsTableViewBottomConstraint.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    self.contactsTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
}

#pragma mark - ContactsServiceDelegate

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self.contactsTableView reloadData];
}

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    for (TLContact *contact in contacts) {
        if ([contact hasPeer]) {
            [self updateUIContact:contact avatar:nil];
        }
    }
    
    [self.contactsTableView reloadData];
}

- (void)onCreateContact:(TLContact *)contact avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    [self updateUIContact:contact avatar:avatar];
    [self.contactsTableView reloadData];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    [self updateUIContact:contact avatar:avatar];
    [self.contactsTableView reloadData];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    for (UIContact *uiContact in self.uiContacts) {
        if ([uiContact.contact.uuid isEqual:contactId]) {
            [self.uiContacts removeObject:uiContact];
            break;
        }
    }
    [self.contactsTableView reloadData];
}

- (void)updateUIContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
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
        [self.contactsService getImageWithContact:contact withBlock:^(UIImage *image) {
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    if (![searchText isEqualToString:@""]) {
        [self.contactsService findContactsByName:searchText];
    } else {
        [self.contactsService getContacts];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.contactsService getContacts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return NEW_CONVERSATION_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATE_GROUP_SECTION) {
        return 1;
    }
    else {
        return self.uiContacts.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATE_GROUP_SECTION) {
        return CGFLOAT_MIN;
    }
    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATE_GROUP_SECTION) {
        return [UIView new];
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
        default:
            break;
    }
    
    [shareSectionHeaderCell bindWithTitle:sectionName];
    
    return shareSectionHeaderCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ titleForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSString *sectionName = @"";
    switch (section) {
        case CONTACTS_VIEW_SECTION: {
            if (self.uiContacts.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_contact_list_title", nil);
            }
            break;
        }
        default:
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CREATE_GROUP_SECTION) {
        AddGroupCell *addGroupCell = (AddGroupCell *)[tableView dequeueReusableCellWithIdentifier:ADD_GROUP_CELL_IDENTIFIER];
        if (!addGroupCell) {
            addGroupCell = [[AddGroupCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_GROUP_CELL_IDENTIFIER];
        }
        [addGroupCell bind];
        
        return addGroupCell;
    } else {
        ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
        if (!contactCell) {
            contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
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
        
        [contactCell bindWithContact:uiContact hideSeparator:hideSeparator];
        
        return contactCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CREATE_GROUP_SECTION) {
        [self handleCreateGroup];
    } else if (indexPath.section == CONTACTS_VIEW_SECTION) {
        UIContact *uiContact = self.uiContacts[indexPath.row];
        if ([uiContact.contact hasPeer]) {
            [self finish];
            [self dismissViewControllerAnimated:NO completion:^{
                ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
                MainViewController *mainViewController = delegate.mainViewController;
                TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
                ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
                [conversationViewController initWithContact:uiContact.contact];
                [selectedNavigationController pushViewController:conversationViewController animated:YES];
            }];
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil).capitalizedString];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
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
    
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"AddGroupCell" bundle:nil] forCellReuseIdentifier:ADD_GROUP_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:CONTACT_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ShareSectionHeaderCell" bundle:nil] forCellReuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    
    self.uiInitialized = YES;
    
    [self.view layoutIfNeeded];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.contactsService dispose];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCreateGroup {
    DDLogVerbose(@"%@ handleCreateGroup", LOG_TAG);
    
    CreateGroupViewController *createGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateGroupViewController"];
    [self.navigationController pushViewController:createGroupViewController animated:YES];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
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
    
    if ([self.twinmeApplication darkModeEnable]) {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceLight;
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

@end
