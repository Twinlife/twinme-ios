/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "ShareContactViewController.h"
#import "SpacesViewController.h"

#import <TwinmeCommon/AbstractBottomSheetView.h>
#import <TwinmeCommon/OnboardingConfirmView.h>
#import "UIContact.h"
#import "ContactCell.h"
#import "ShareContactCell.h"
#import "ShareSectionHeaderCell.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ContactsService.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_RIGHT_BUTTON_WIDTH = 70.0;
static CGFloat DESIGN_RIGHT_BUTTON_HEIGHT = 44.0;
static CGFloat DESIGN_AVATAR_HEIGHT = 32.0;

static NSString *SHARE_CONTACT_CELL_IDENTIFIER = @"ShareContactCellIdentifier";
static NSString *CONTACT_CELL_IDENTIFIER = @"ContactCellIdentifier";
static NSString *SHARE_SECTION_HEADER_CELL_IDENTIFIER = @"ShareSectionHeaderCellIdentifier";

//
// Interface: ShareContactViewController
//

@interface ShareContactViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate, UISearchBarDelegate, ContactsServiceDelegate, BottomSheetViewDelegate, SpacesPickerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactAvatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *selectedContactAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *selectedContactLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;

@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UIBarButtonItem *addBarButtonItem;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UIImageView *spaceAvatarImageView;
@property (nonatomic) UILabel *spaceAvatarLabel;

@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) TLContact *contact;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) UIContact *selectedContact;

@property (nonatomic) ContactsService *contactsService;

@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL showOnboardingView;

@end

//
// Implementation: ShareContactViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShareContactViewController"

@implementation ShareContactViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _needRefresh = NO;
        _keyboardHidden = YES;
        _showOnboardingView = NO;
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
    
    if (!self.showOnboardingView && [self.twinmeApplication startOnboarding:OnboardingTypeShareContact]) {
        self.showOnboardingView = YES;
        [self showOnboarding];
    }
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
    
    self.bottomViewHeightConstraint.constant = self.infoViewHeightConstraint.constant;
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat bottomViewHeight = self.selectedContact ? self.bottomViewHeightConstraint.constant : 0;
    CGFloat value = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.tableViewBottomConstraint.constant = value + bottomViewHeight;
    self.bottomViewBottomConstraint.constant = value;
    
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
    
    self.bottomViewHeightConstraint.constant = self.infoViewHeightConstraint.constant + safeAreaInset;
    self.bottomViewBottomConstraint.constant  = 0;
    
    if (self.selectedContact) {
        self.tableViewBottomConstraint.constant = self.bottomViewHeightConstraint.constant;
    } else {
        self.tableViewBottomConstraint.constant = 0;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    
    CGFloat bottomViewHeight = self.selectedContact ? self.bottomViewHeightConstraint.constant + self.bottomViewBottomConstraint.constant : 0;
    self.tableViewBottomConstraint.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y - bottomViewHeight;
}

#pragma mark - Public methods

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    [self.contactsService getImageWithContact:contact withBlock:^(UIImage *image) {
        self.contactAvatar = image;
    }];
}

#pragma mark - SpacesPickerDelegate

- (void)didSelectSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ didSelectSpace: %@", LOG_TAG, space);
    
    [self updateSpace:space];
    [self.contactsService updateSpace:space];
}

#pragma mark - ContactsServiceDelegate

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self.tableView reloadData];
}

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    for (TLContact *contact in contacts) {
        if ([contact hasPeer] && [contact hasPrivatePeer] && ![contact.uuid isEqual:self.contact.uuid]) {
            [self updateUIContact:contact avatar:nil];
        }
    }
    
    [self.tableView reloadData];
}

- (void)onCreateContact:(TLContact *)contact avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    [self updateUIContact:contact avatar:avatar];
    [self.tableView reloadData];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    [self updateUIContact:contact avatar:avatar];
    [self.tableView reloadData];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    for (UIContact *uiContact in self.uiContacts) {
        if ([uiContact.contact.uuid isEqual:contactId]) {
            [self.uiContacts removeObject:uiContact];
            break;
        }
    }
    [self.tableView reloadData];
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
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0) {
        return 1;
    }
    
    return self.uiContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0 || self.uiContacts.count == 0) {
        return CGFLOAT_MIN;
    }
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0 || self.uiContacts.count == 0) {
        return [UIView new];
    }
    
    ShareSectionHeaderCell *shareSectionHeaderCell = (ShareSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    if (!shareSectionHeaderCell) {
        shareSectionHeaderCell = [[ShareSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];
    }
    
    [shareSectionHeaderCell bindWithTitle:TwinmeLocalizedString(@"share_view_contact_list", nil)];
    
    return shareSectionHeaderCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ titleForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 1) {
        return TwinmeLocalizedString(@"share_view_contact_list", nil);
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        ShareContactCell *shareContactCell = (ShareContactCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_CONTACT_CELL_IDENTIFIER];
        if (!shareContactCell) {
            shareContactCell = [[ShareContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_CONTACT_CELL_IDENTIFIER];
        }
        
        [shareContactCell bindWithName:self.contact.name avatar:self.contactAvatar];
        
        return shareContactCell;
    } else {
        ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
        if (!contactCell) {
            contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
        }
        
        UIContact * uiContact = self.uiContacts[indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
        
        [contactCell bindWithContact:uiContact hideSeparator:hideSeparator];
        
        return contactCell;
    }
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIContact *uiContact = self.uiContacts[indexPath.row];
    self.selectedContact = uiContact;
    [self updateSelectedContact];
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
    
    if ([abstractBottomSheetView isKindOfClass:[OnboardingConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeShareContact state:NO];
    }
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
}


#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"show_contact_view_share_contact", nil)];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
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
        
        [self updateSpace:self.currentSpace];
    }
        
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
    
    self.searchController.searchBar.backgroundColor = [UIColor clearColor];
    self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
    self.searchController.searchBar.translucent = NO;
    self.navigationItem.searchController = self.searchController;
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:CONTACT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShareContactCell" bundle:nil] forCellReuseIdentifier:SHARE_CONTACT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShareSectionHeaderCell" bundle:nil] forCellReuseIdentifier:SHARE_SECTION_HEADER_CELL_IDENTIFIER];

    UIWindow *window = [self currentWindow];
    CGFloat safeAreaInset;
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.view.safeAreaInsets.bottom;
    }
    
    self.infoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.infoView.backgroundColor = Design.WHITE_COLOR;
    
    self.bottomViewHeightConstraint.constant = self.infoViewHeightConstraint.constant + safeAreaInset;

    self.bottomView.backgroundColor = Design.WHITE_COLOR;
    self.bottomView.hidden = YES;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.selectedContactAvatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.selectedContactAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.selectedContactAvatarView.clipsToBounds = YES;
    self.selectedContactAvatarView.layer.cornerRadius = self.selectedContactAvatarViewHeightConstraint.constant * 0.5f;
    
    self.selectedContactLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.selectedContactLabel.font = Design.FONT_REGULAR32;
    self.selectedContactLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.contactsService dispose];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)handleCancelTapGesture:(id)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
    
    if ([self.shareContactViewDelegate respondsToSelector:@selector(didCancelShareContactView)]) {
        [self.shareContactViewDelegate didCancelShareContactView];
    }
}

- (void)handleSendTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSendTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];

        [self finish];
        
        if (self.selectedContact) {
            TLContact *contact = (TLContact *)self.selectedContact.contact;
            if ([self.shareContactViewDelegate respondsToSelector:@selector(didSelectContactToShare:)]) {
                [self.shareContactViewDelegate didSelectContactToShare:contact];
            }
        }
    }
}

- (void)handleSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
        spacesViewController.pickerMode = YES;
        spacesViewController.spacesPickerDelegate = self;
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}
    
- (void)updateSelectedContact {
    DDLogVerbose(@"%@ updateSelectedContact", LOG_TAG);
    
    if (self.selectedContact) {
        self.bottomView.hidden = NO;
        self.tableViewBottomConstraint.constant = self.bottomViewHeightConstraint.constant + self.bottomViewBottomConstraint.constant; 
        self.selectedContactAvatarView.image = self.selectedContact.avatar;
        self.selectedContactLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_local_message", nil), self.selectedContact.name, self.contact.name];
    }
}

- (void)showOnboarding {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeShareContact]) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.bottomSheetViewDelegate = self;
        
        NSMutableString *message = [[NSMutableString alloc] initWithString:@""];
        [message appendString:TwinmeLocalizedString(@"share_contact_view_onboarding_part_1", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"share_contact_view_onboarding_part_2", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"share_contact_view_onboarding_part_3", nil)];
        
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"privacy_view_share_invitation_title", nil) message:message image:[UIImage imageNamed:@"OnboardingShareContact"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
}

- (void)updateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ updateSpace", LOG_TAG);
    
    if (space.avatarId) {
        self.spaceAvatarLabel.hidden = YES;
        self.spaceAvatarImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.spaceAvatarImageView.layer.borderWidth = 0.0;
        [self.contactsService getImageWithSpace:space withBlock:^(UIImage *image) {
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

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.selectedContactLabel.font = Design.FONT_REGULAR32;

    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.bottomView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.selectedContactLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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
