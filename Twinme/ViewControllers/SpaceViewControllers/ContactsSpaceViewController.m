/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "ContactsSpaceViewController.h"

#import <TwinmeCommon/SpaceService.h>

#import "MoveContactCell.h"
#import "SelectedGroupMemberCell.h"
#import "UIMoveContact.h"
#import "SpaceActionConfirmView.h"

#import "AlertView.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MOVE_CONTACT_CELL_IDENTIFIER = @"MoveContactCellIdentifier";
static NSString *SELECTED_GROUP_MEMBER_CELL_IDENTIFIER = @"SelectedGroupMemberCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 116;
static CGFloat DESIGN_TABLE_VIEW_BOTTOM = 116;

@interface ContactsSpaceViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, SpaceServiceDelegate, UISearchBarDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *selectedContactsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moveLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;
@property (weak, nonatomic) IBOutlet UIView *moveClickableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *contactsCollectionView;
@property (weak, nonatomic) IBOutlet UIView *safeAreaView;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) NSMutableArray *contactsMoveOnCreateSpace;
@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiSelecteContacts;

@property (nonatomic) SpaceService *spaceService;
@property (nonatomic) TLSpace *space;
@property (nonatomic) BOOL refreshTableScheduled;

@end

//
// Implementation: ContactsSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"ContactsSpaceViewController"

@implementation ContactsSpaceViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _spaceService = [[SpaceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self];
        
        _uiContacts = [[NSMutableArray alloc]init];
        _uiSelecteContacts = [[NSMutableArray alloc]init];
        _refreshTableScheduled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    [self.spaceService getAllContacts];
}

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
}

- (void)initWithContacts:(NSMutableArray *)contacts {
    DDLogVerbose(@"%@ initWithContacts: %@", LOG_TAG, contacts);
    
    self.contactsMoveOnCreateSpace = contacts;
}

#pragma mark - SpaceServiceDelegate

- (void)onCreateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    if ([self.space.uuid isEqual:space.uuid]) {
        [self finish];
    }
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
    
}

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onGetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onGetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    [self updateUIContact:contact avatar:avatar];
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
}

- (void)onUpdateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
}

- (void)onGetSpaces:(nonnull NSArray<TLSpace *> *)spaces {
    DDLogVerbose(@"%@ onGetSpaces: %@", LOG_TAG, spaces);
}

- (void)onGetGroups:(nonnull NSArray<TLGroup *> *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    [self.uiContacts removeAllObjects];
    
    self.refreshTableScheduled = YES;
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    
    self.refreshTableScheduled = NO;
    [self.contactsTableView reloadData];
}

- (void)updateUIContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, contact);
    
    UIMoveContact *uiContact = nil;
    for (UIMoveContact *lUIContact in self.uiContacts) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiContacts removeObject:uiContact];
        uiContact.contact = contact;
    } else {
        uiContact = [[UIMoveContact alloc] initWithContact:contact];
    }
    if (!avatar && [contact hasPeer]) {
        [self.spaceService getImageWithContact:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    if (self.contactsMoveOnCreateSpace && [self.contactsMoveOnCreateSpace containsObject:contact]) {
        uiContact.isSelected = YES;
        [self.uiSelecteContacts addObject:uiContact];
    }
    
    if (self.space && [contact.space.uuid isEqual:self.space.uuid]) {
        uiContact.canMove = NO;
        uiContact.isSelected = YES;
    }
    
    BOOL added = NO;
    NSInteger count = self.uiContacts.count;
    for (NSInteger i = 0; i < count; i++) {
        UIMoveContact *lUIContact = self.uiContacts[i];
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

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[SpaceActionConfirmView class]]) {        
        NSMutableArray *moveContacts = [[NSMutableArray alloc]init];
        
        for (UIContact *uiContact in self.uiSelecteContacts) {
            [moveContacts addObject:uiContact.contact];
        }
        
        if (self.space) {
            [self.spaceService moveContactsInSpace:moveContacts space:self.space];
        } else {
            [self.contactsSpaceDelegate moveContacts:self contacts:moveContacts];
            [self finish];
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    if (![searchText isEqualToString:@""]) {
        [self.spaceService findContactsByName:searchText];
    } else {
        [self.spaceService getAllContacts];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.spaceService getAllContacts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.uiContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    MoveContactCell *moveContactCell = (MoveContactCell *)[tableView dequeueReusableCellWithIdentifier:MOVE_CONTACT_CELL_IDENTIFIER];
    if (!moveContactCell) {
        moveContactCell = [[MoveContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MOVE_CONTACT_CELL_IDENTIFIER];
    }
    
    UIMoveContact *contact = [self.uiContacts objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
    [moveContactCell bindWithContact:contact hideSeparator:hideSeparator];
    
    return moveContactCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [self.contactsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIMoveContact *contact = [self.uiContacts objectAtIndex:indexPath.row];
    
    if (!contact.canMove) {
        return;
    }
    
    if ([self.uiSelecteContacts containsObject:contact]) {
        [self.uiSelecteContacts removeObject:contact];
        contact.isSelected = false;
    } else {
        [self.uiSelecteContacts addObject:contact];
        contact.isSelected = true;
    }
    
    [self.contactsTableView reloadData];
    [self.contactsCollectionView reloadData];
    [self updateSelectedContactView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.uiSelecteContacts.count;
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
    
    UIMoveContact *moveContact = [self.uiSelecteContacts objectAtIndex:indexPath.row];
    [groupMemberCell bindWithAvatar:moveContact.avatar];
    
    return groupMemberCell;
}

- (void)updateSelectedContactView {
    DDLogVerbose(@"%@ updateSelectedContactView", LOG_TAG);
    
    if (self.uiSelecteContacts.count > 0) {
        self.selectedContactsView.hidden = NO;
        self.safeAreaView.hidden = NO;
        self.contactsTableViewBottomConstraint.constant = (DESIGN_TABLE_VIEW_BOTTOM * Design.HEIGHT_RATIO) + self.safeAreaView.frame.size.height;
    } else {
        self.selectedContactsView.hidden = YES;
        self.safeAreaView.hidden = YES;
        self.contactsTableViewBottomConstraint.constant = 0;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"contacts_view_controller_title", nil)];
    
    self.contactsTableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contactsTableViewBottomConstraint.constant = 0;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    
    UISearchBar *contactSearchBar = self.searchController.searchBar;
    contactSearchBar.barStyle = UIBarStyleDefault;
    contactSearchBar.searchBarStyle = UISearchBarStyleProminent;
    contactSearchBar.translucent = NO;
    contactSearchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    contactSearchBar.tintColor = [UIColor whiteColor];
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
    
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.sectionHeaderHeight = 0;
    self.contactsTableView.sectionFooterHeight = 0;
    
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"MoveContactCell" bundle:nil] forCellReuseIdentifier:MOVE_CONTACT_CELL_IDENTIFIER];
    
    self.selectedContactsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.selectedContactsView.hidden = YES;
    
    self.selectedContactsView.backgroundColor = Design.WHITE_COLOR;
    self.selectedContactsView.layer.masksToBounds = NO;
    self.selectedContactsView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.selectedContactsView.layer.shadowOffset = CGSizeMake(0, Design.HEIGHT_RATIO * -16);
    self.selectedContactsView.layer.shadowOpacity = 0.1;
    self.selectedContactsView.layer.shadowRadius = 6;
    
    self.safeAreaView.hidden = YES;
    self.safeAreaView.backgroundColor = Design.WHITE_COLOR;
    
    self.contactsCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.contactsCollectionView setCollectionViewLayout:viewFlowLayout];
    self.contactsCollectionView.dataSource = self;
    self.contactsCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.contactsCollectionView registerNib:[UINib nibWithNibName:@"SelectedGroupMemberCell" bundle:nil] forCellWithReuseIdentifier:SELECTED_GROUP_MEMBER_CELL_IDENTIFIER];
        
    UITapGestureRecognizer *addGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)];
    [self.moveClickableView addGestureRecognizer:addGestureRecognizer];
    
    self.moveLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.moveLabel.font = Design.FONT_REGULAR36;
    self.moveLabel.textColor = Design.FONT_COLOR_BLUE;
    self.moveLabel.text = TwinmeLocalizedString(@"add_group_member_view_controller_add", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.spaceService dispose];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.spaceService getImageWithSpace:self.space withBlock:^(UIImage *image) {
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeMoveContact;
            [spaceActionConfirmView initWithTitle:self.space.settings.name message:TwinmeLocalizedString(@"contacts_space_view_controller_move_message", nil) spaceName:self.space.settings.name spaceStyle:self.space.settings.style avatar:image icon:[UIImage imageNamed:@"TabBarContactsGrey"] confirmTitle:TwinmeLocalizedString(@"create_space_view_controller_contact_list", nil) cancelTitle:TwinmeLocalizedString(@"application_cancel", nil)];
            [self.tabBarController.view addSubview:spaceActionConfirmView];
            [spaceActionConfirmView showConfirmView];
        }];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.moveLabel.font = Design.FONT_REGULAR36;
    
    [self.contactsTableView reloadData];
    [self.contactsCollectionView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.safeAreaView.backgroundColor = Design.WHITE_COLOR;
    self.selectedContactsView.backgroundColor = Design.WHITE_COLOR;
    self.contactsTableView.backgroundColor = Design.WHITE_COLOR;
    self.contactsCollectionView.backgroundColor = Design.WHITE_COLOR;
    
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
    
    if ([self.twinmeApplication darkModeEnable:[self currentSpaceSettings]]) {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
