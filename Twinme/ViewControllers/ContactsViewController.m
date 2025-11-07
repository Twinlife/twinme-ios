/*
 *  Copyright (c) 2019-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "ContactsViewController.h"
#import "AddContactViewController.h"
#import "AddProfileViewController.h"
#import "AccountMigrationScannerViewController.h"
#import "ContactCell.h"
#import "AddContactCell.h"
#import "SectionCallCell.h"

#import <TwinmeCommon/ContactsService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "UIContact.h"
#import "MenuAddContactView.h"
#import "ApplicationAssertion.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SECTION_CELL_IDENTIFIER = @"SectionCallCellIdentifier";
static NSString *ADD_CONTACT_CELL_IDENTIFIER = @"AddContactCellIdentifier";
static NSString *CONTACT_CELL_IDENTIFIER = @"ContactCellIdentifier";

static const int CONTACTS_VIEW_SECTION_COUNT = 2;

//
// Interface: ContactsViewController
//

@interface ContactsViewController () <UITableViewDataSource, UITableViewDelegate, ContactsServiceDelegate, UISearchBarDelegate, MenuAddContactViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noContactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noContactLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noContactLabel;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noResultFoundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundTitleLabel;

@property (nonatomic) UISearchController *searchController;

@property (nonatomic) NSMutableArray *uiContacts;

@property (nonatomic) ContactsService *contactsService;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL isGetContactsDone;

@end

//
// Implementation: ContactsViewController
//

#undef LOG_TAG
#define LOG_TAG @"ContactsViewController"

@implementation ContactsViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _needRefresh = NO;
        _keyboardHidden = YES;
        _isGetContactsDone = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    self.contactsService = [[ContactsService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    [super viewWillAppear:animated];
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        self.isGetContactsDone = NO;
        [self.contactsService getContacts];
    }

    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = YES;
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    
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
    self.contactTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
        
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.contactTableViewBottomConstraint.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    self.contactTableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    return NO;
}

#pragma mark - ContactsServiceDelegate

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.contactsService profile:space.profile];
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
    [navigationController setNavigationBarStyle];
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);

    [self setLeftBarButtonItem:self.contactsService profile:space.profile];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.contactsService profile:space.profile];
    [self reloadData];
}

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact];
    }
    
    self.isGetContactsDone = YES;
    
    [self reloadData];
}

- (void)onCreateContact:(TLContact *)contact avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    [self updateUIContact:contact avatar:avatar];
    
    [self reloadData];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
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
    
    [self updateUIContact:contact avatar:avatar];
    [self reloadData];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    for (UIContact *uiContact in self.uiContacts) {
        if ([uiContact.contact.uuid isEqual:contactId]) {
            [self.uiContacts removeObject:uiContact];
            break;
        }
    }
    [self reloadData];
}

- (void)updateUIContact:(nonnull TLContact *)contact {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, contact);
    
    [self updateUIContact:contact avatar:nil];
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

    // Get the contact avatar asynchronously to avoid blocking the main UI thread.
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
    
    return CONTACTS_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0 && self.uiContacts.count > 0) {
        return self.searchController.isActive ? 0 : 1;
    }
    
    return self.uiContacts.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
            
    if (!self.searchController.isActive && section == 1 && self.uiContacts.count > 0) {
        return Design.SETTING_SECTION_HEIGHT;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SectionCallCell *sectionCallCell = (SectionCallCell *)[tableView dequeueReusableCellWithIdentifier:SECTION_CELL_IDENTIFIER];
    if (!sectionCallCell) {
        sectionCallCell = [[SectionCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SECTION_CELL_IDENTIFIER];
    }
        
    NSString *sectionName = @"";
    if (section == 1) {
        sectionName = TwinmeLocalizedString(@"contacts_view_controller_title", nil);
    }
    
    [sectionCallCell bindWithTitle:sectionName hideSeparator:NO uppercaseString:YES showRightAction:NO];
    
    return sectionCallCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (indexPath.section == 1) {
        return Design.CELL_HEIGHT;
    }
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        AddContactCell *addContactCell = (AddContactCell *)[tableView dequeueReusableCellWithIdentifier:ADD_CONTACT_CELL_IDENTIFIER];
        if (!addContactCell) {
            addContactCell = [[AddContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_CONTACT_CELL_IDENTIFIER];
        }
        
        [addContactCell bindWithTitle:TwinmeLocalizedString(@"main_view_controller_add_contact", nil) subTitle:TwinmeLocalizedString(@"contacts_view_controller_add_contact_subtitle", nil)];
        
        return addContactCell;
    } else {
        ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
        if (!contactCell) {
            contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
        }
        
        UIContact *uiContact = self.uiContacts[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
        [contactCell bindWithContact:uiContact hideSeparator:hideSeparator];
        
        return contactCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        [self addContact];
    } else {
        UIContact *uiContact = self.uiContacts[indexPath.row];
        
        if (self.searchController.active) {
            [self.searchController dismissViewControllerAnimated:NO completion:^{
                [self showContact:uiContact];
            }];
        } else {
            [self showContact:uiContact];
        }
    }
}

#pragma mark - MenuAddContactViewDelegate

- (void)menuAddContactDidSelectScan:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectScan: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:delegate.mainViewController.profile invitationMode:InvitationModeScan];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)menuAddContactDidSelectInvite:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectInvite: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:delegate.mainViewController.profile invitationMode:InvitationModeInvite];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)cancelMenuAddContactView:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ cancelMenuAddContactView: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
}

#pragma mark - Private Methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"contacts_view_controller_title", nil).capitalizedString];
    
    UIBarButtonItem *addContactBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarAddContact"] style:UIBarButtonItemStylePlain target:self action:@selector(handleAddContactTapGesture:)];
    addContactBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"add_contact_view_controller_title", nil);
    self.navigationItem.rightBarButtonItem = addContactBarButtonItem;
    
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
        self.searchController.searchBar.barTintColor = Design.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.contactTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.contactTableView.backgroundColor = Design.WHITE_COLOR;
    self.contactTableView.delegate = self;
    self.contactTableView.dataSource = self;
    self.contactTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.contactTableView.rowHeight = UITableViewAutomaticDimension;
    self.contactTableView.estimatedRowHeight = Design.CELL_HEIGHT;
    self.contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contactTableView registerNib:[UINib nibWithNibName:@"SectionCallCell" bundle:nil] forCellReuseIdentifier:SECTION_CELL_IDENTIFIER];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"AddContactCell" bundle:nil] forCellReuseIdentifier:ADD_CONTACT_CELL_IDENTIFIER];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:CONTACT_CELL_IDENTIFIER];
    self.contactTableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.contactTableView.sectionFooterHeight = CGFLOAT_MIN;
    
    self.noContactImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noContactImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noContactImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noContactImageView.hidden = YES;
    
    self.noContactImageView.image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingStep3Dark"] : [UIImage imageNamed:@"OnboardingStep3"];
    
    self.noContactLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noContactLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noContactLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noContactLabel.font = Design.FONT_MEDIUM34;
    self.noContactLabel.textColor = Design.FONT_COLOR_DEFAULT;
    [self.noContactLabel setAdjustsFontSizeToFitWidth:YES];
    self.noContactLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_onboarding_message", nil);
    self.noContactLabel.hidden = YES;
    
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
}

- (IBAction)handleAddContactTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    [self addContact];
}

- (void)handleTransferTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTransferTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
        accountMigrationScannerViewController.fromCurrentDevice = NO;
        [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
    }
}

- (void)showContact:(UIContact *)uiContact {
    DDLogVerbose(@"%@ showContact: %@", LOG_TAG, uiContact);
    
    TL_ASSERT_NOT_NULL(self.twinmeContext, uiContact.contact, [ApplicationAssertPoint INVALID_SUBJECT], nil);

    [super showContactWithContact:(TLContact *)uiContact.contact popToRoot:NO];
}

- (void)addContact {
    DDLogVerbose(@"%@ addContact", LOG_TAG);
    
    if (!self.defaultProfile) {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        addProfileViewController.fromContactsTab = YES;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    } else {
        MenuAddContactView *menuAddContactView = [[MenuAddContactView alloc]init];
        menuAddContactView.menuAddContactViewDelegate = self;
        [self.tabBarController.view addSubview:menuAddContactView];
        [menuAddContactView openMenu];
    }
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if (self.uiContacts.count == 0 && !self.searchController.active && self.isGetContactsDone) {
        self.noContactImageView.hidden = NO;
        self.noContactLabel.hidden = NO;
        self.inviteContactView.hidden = NO;
        self.transferView.hidden = NO;
        self.noResultFoundImageView.hidden = YES;
        self.noResultFoundTitleLabel.hidden = YES;
        self.contactTableView.hidden = YES;
        [self.contactTableView reloadData];

        [self.navigationController.navigationBar setPrefersLargeTitles:NO];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = nil;
        }
    } else {
        self.noContactImageView.hidden = YES;
        self.noContactLabel.hidden = YES;
        self.inviteContactView.hidden = YES;
        self.transferView.hidden = YES;
        self.contactTableView.hidden = NO;
        
        [self.navigationController.navigationBar setPrefersLargeTitles:YES];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = self.searchController;
        }
        [self.contactTableView reloadData];
        
        if (self.uiContacts.count == 0 && self.searchController.active) {
            self.noResultFoundImageView.hidden = NO;
            self.noResultFoundTitleLabel.hidden = NO;
            self.noResultFoundTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversations_view_controller_no_result_found", nil), self.searchController.searchBar.text];
        } else {
            self.noResultFoundImageView.hidden = YES;
            self.noResultFoundTitleLabel.hidden = YES;
        }
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.contactTableView reloadData];
        });
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.noContactLabel.font = Design.FONT_MEDIUM34;
    self.inviteContactLabel.font = Design.FONT_MEDIUM34;
    self.transferLabel.font = Design.FONT_REGULAR26;
    self.noResultFoundTitleLabel.font = Design.FONT_MEDIUM34;

    [self reloadData];
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
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.contactTableView.backgroundColor = Design.WHITE_COLOR;
    self.noContactLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteContactView.backgroundColor = Design.MAIN_COLOR;
    self.transferLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noResultFoundTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.noContactImageView.image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingStep3Dark"] : [UIImage imageNamed:@"OnboardingStep3"];
}

@end
