/*
 *  Copyright (c) 2022-2024 twinlife SA.
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
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "AddCallParticipantViewController.h"

#import "AddGroupMemberCell.h"
#import "SelectedMembersCell.h"
#import "ChangeSpaceCell.h"
#import "UIContact.h"
#import "UISpace.h"
#import "AlertMessageView.h"
#import <TwinmeCommon/CallParticipantService.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/MainViewController.h>
#import "SpacesViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ADD_GROUP_MEMBER_CELL_IDENTIFIER = @"AddGroupMemberCellIdentifier";
static NSString *SELECTED_CONTACTS_CELL_IDENTIFIER = @"SelectedMembersCellIdentifier";
static NSString *CHANGE_SPACE_CELL_IDENTIFIER = @"ChangeSpaceCellIdentifier";

static CGFloat DESIGN_TABLE_VIEW_TOP = 40;
static CGFloat DESIGN_SELECTED_CONTACTS_HEIGHT = 116;
static CGFloat DESIGN_SPACE_CELL_HEIGHT = 144;

static const int SECTION_COUNT = 3;

static const int SPACE_SECTION = 0;
static const int SELECTED_CONTACTS_VIEW_SECTION = 1;
static const int CONTACTS_VIEW_SECTION = 2;

@interface AddCallParticipantViewController() <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CallParticipantServiceDelegate, SpacesPickerDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedMembersViewHeightConstraint;

@property (nonatomic) UIBarButtonItem *addBarButtonItem;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) TLSpace *space;
@property (nonatomic) UISpace *uiSpace;
@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiSelectedContacts;
@property (nonatomic) BOOL hasSpaceSection;
@property (nonatomic) BOOL refreshTableScheduled;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic) CallParticipantService *callParticipantService;

@end

//
// Implementation: AddCallParticipantViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddCallParticipantViewController"

@implementation AddCallParticipantViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiSelectedContacts = [[NSMutableArray alloc] init];
        _refreshTableScheduled = NO;
        _keyboardHidden = YES;
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        _hasSpaceSection = [mainViewController numberSpaces:NO] > 1;
        
        _callParticipantService = [[CallParticipantService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self updateWithSpace:self.currentSpace];
    [self.callParticipantService getContacts:self.space];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
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
    self.contactsTableViewBottomConstraint.constant = keyboardSize.height;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.contactsTableViewBottomConstraint.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.contactsTableViewBottomConstraint.constant = keyboardSize.height;
}

#pragma mark - AcceptInvitationServiceDelegate

- (void)onGetContacts:(nonnull NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    self.refreshTableScheduled = YES;
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    
    self.refreshTableScheduled = NO;
    [self.contactsTableView reloadData];
}

- (void)updateWithSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ updateWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.uiSpace = [self createUISpaceWithSpace:self.space service:self.callParticipantService withRefresh:^(void) {
        [self refreshTable];
    }];
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
    if (!avatar && [contact hasPeer]) {
        [self.callParticipantService getImageWithContact:contact withBlock:^(UIImage *image) {
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
    
    if ([self.participantsUUID containsObject:contact.peerTwincodeOutboundId] && ![self isSelectedContact:uiContact]) {
        [self.uiSelectedContacts addObject:uiContact];
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
    
    if (![searchText isEqualToString:@""]) {
        [self.callParticipantService findContactsByName:searchText space:self.space];
    } else {
        [self.callParticipantService getContacts:self.space];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.callParticipantService getContacts:self.space];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SPACE_SECTION) {
        if (self.hasSpaceSection) {
            return 1;
        } else {
            return 0;
        }
    } else if (section == SELECTED_CONTACTS_VIEW_SECTION) {
        return 1;
    }
    
    return self.uiContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SPACE_SECTION) {
        return DESIGN_SPACE_CELL_HEIGHT * Design.HEIGHT_RATIO;
    } else if (indexPath.section == SELECTED_CONTACTS_VIEW_SECTION && self.uiSelectedContacts.count > 0) {
        return DESIGN_SELECTED_CONTACTS_HEIGHT * Design.HEIGHT_RATIO;
    } else if (indexPath.section == CONTACTS_VIEW_SECTION) {
        return Design.CELL_HEIGHT;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == SPACE_SECTION) {
        return CGFLOAT_MIN;
    } else if (section == SELECTED_CONTACTS_VIEW_SECTION) {
        if (self.hasSpaceSection && self.uiSelectedContacts.count > 0) {
            return DESIGN_TABLE_VIEW_TOP * Design.HEIGHT_RATIO;
        } else {
            return CGFLOAT_MIN;
        }
    } else if (section == CONTACTS_VIEW_SECTION && (self.uiSelectedContacts.count > 0 || self.hasSpaceSection)) {
        return DESIGN_TABLE_VIEW_TOP * Design.HEIGHT_RATIO;
    }
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SPACE_SECTION) {
        ChangeSpaceCell *changeSpaceCell = (ChangeSpaceCell *)[tableView dequeueReusableCellWithIdentifier:CHANGE_SPACE_CELL_IDENTIFIER];
        if (!changeSpaceCell) {
            changeSpaceCell = [[ChangeSpaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CHANGE_SPACE_CELL_IDENTIFIER];
        }

        [changeSpaceCell bindWithSpace:self.uiSpace];
        
        return changeSpaceCell;
    } else if (indexPath.section == CONTACTS_VIEW_SECTION) {
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
        
        TLContact *contact = (TLContact *)uiContact.contact;
        if ([self.participantsUUID containsObject:contact.peerTwincodeOutboundId]) {
            [addGroupMemberCell setSelectable:NO];
        } else {
            [addGroupMemberCell setSelectable:YES];
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
    
    if (indexPath.section == SPACE_SECTION) {
        SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
        spacesViewController.pickerMode = YES;
        spacesViewController.spacesPickerDelegate = self;
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else  if (indexPath.section == CONTACTS_VIEW_SECTION) {
        [self.contactsTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIContact *selectContact = [self.uiContacts objectAtIndex:indexPath.row];
        TLContact *contact = (TLContact *)selectContact.contact;
        if ([self.participantsUUID containsObject:contact.peerTwincodeOutboundId]) {
            return;
        }

        AddGroupMemberCell *addGroupMemberCell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
        SelectedMembersCell *selectedMemberCell = [self.contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SELECTED_CONTACTS_VIEW_SECTION]];
        
        NSInteger indexContact = [self indexForSelectedContact:selectContact];
        if (indexContact != -1) {
            NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForItem:indexContact inSection:0];
            [self.uiSelectedContacts removeObjectAtIndex:indexContact];
            [selectedMemberCell.membersCollectionView deleteItemsAtIndexPaths:@[deletedIndexPath]];
            [addGroupMemberCell setChecked:NO];
        } else {
            NSMutableArray *selectedContacts = [self getNewSelectedContacts];
            NSUInteger countParticipants = self.participantsUUID.count + selectedContacts.count + 1;
            if (countParticipants >= self.maxMemberCount && self.maxMemberCount != 0) {
                AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
                alertMessageView.alertMessageViewDelegate = self;
                [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_max_participant_message", nil), self.maxMemberCount]];
                [self.navigationController.view addSubview:alertMessageView];
                [alertMessageView showAlertView];
            } else {
                [self.uiSelectedContacts addObject:selectContact];
                NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForItem:self.uiSelectedContacts.count - 1 inSection:0];
                [selectedMemberCell.membersCollectionView insertItemsAtIndexPaths:@[insertedIndexPath]];
                [selectedMemberCell.membersCollectionView scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
                [addGroupMemberCell setChecked:YES];
            }
        }
        
        [self updateSelectedContactView];
    }
    
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    
    [self finish];
}

#pragma mark - SpacesPickerDelegate

- (void)didSelectSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ didSelectSpace: %@", LOG_TAG, space);
    
    [self.uiContacts removeAllObjects];
    [self.uiSelectedContacts removeAllObjects];
    [self updateWithSpace:space];
    [self.callParticipantService getContacts:self.space];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"add_call_participant_view_controller_title", nil)];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    self.addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_ok", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveTapGesture:)];
    [self.addBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.addBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.addBarButtonItem.enabled = NO;
    
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
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ChangeSpaceCell" bundle:nil] forCellReuseIdentifier:CHANGE_SPACE_CELL_IDENTIFIER];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callParticipantService) {
        [self.callParticipantService dispose];
        self.callParticipantService = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    NSMutableArray *selectedContacts = [self getNewSelectedContacts];
    if (selectedContacts.count > 0) {
        [self.addCallParticipantDelegate addParticipantsToCall:selectedContacts];
        [self finish];
    }
}

- (void)updateSelectedContactView {
    DDLogVerbose(@"%@ updateSelectedContactView", LOG_TAG);
    
    NSMutableArray *selectedContacts = [self getNewSelectedContacts];
    if (selectedContacts.count > 0) {
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

- (NSMutableArray *)getNewSelectedContacts {
    DDLogVerbose(@"%@ getNewSelectedContacts", LOG_TAG);
    
    NSMutableArray *uiSelectedContacts = [[NSMutableArray alloc]init];
    
    for (UIContact *uiContact in self.uiSelectedContacts) {
        TLContact *contact = (TLContact *)uiContact.contact;
        
        if (![self.participantsUUID containsObject:contact.peerTwincodeOutboundId]) {
            [uiSelectedContacts addObject:uiContact.contact];
        }
    }
    
    return uiSelectedContacts;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
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
