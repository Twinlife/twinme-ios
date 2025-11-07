/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>
#import <Twinlife/TLNotificationService.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/SpaceService.h>

#import "SpacesViewController.h"
#import "OnboardingSpaceViewController.h"
#import "TemplateSpaceViewController.h"
#import "NotificationViewController.h"
#import "EditSpaceViewController.h"
#import "ShowSpaceViewController.h"
#import "AddProfileViewController.h"
#import "EditProfileViewController.h"
#import "AddContactViewController.h"

#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>


#import "SpaceCell.h"

#import "AlertMessageView.h"
#import <TwinmeCommon/Design.h>
#import "UISpace.h"
#import "UIPremiumFeature.h"
#import "SpaceSetting.h"
#import "SpaceActionConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SPACE_CELL_IDENTIFIER = @"SpaceCellIdentifier";

static const int SPACES_VIEW_SECTION_COUNT = 1;

//
// Interface: SpacesViewController ()
//

@interface SpacesViewController () <UITableViewDataSource, UITableViewDelegate, SpaceServiceDelegate, UISearchBarDelegate, SpaceActionDelegate, ConfirmViewDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacesTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *spacesTableView;
@property (weak, nonatomic) IBOutlet UIView *noSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceBusinessView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceBusinessImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceBusinessLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceFamilyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceFamilyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceFamilyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceFriendsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceFriendsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceFriendsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSpaceMessageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSpaceMessageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noSpaceMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *createSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *createSpaceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreInfoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreInfoViewBottomtConstraint;
@property (weak, nonatomic) IBOutlet UIView *moreInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noResultFoundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultFoundTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundTitleLabel;

@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic) NSMutableArray *uiSpaces;

@property (nonatomic) TLSpace *currentSpace;
@property (nonatomic) UISpace *spaceToDelete;
@property (nonatomic) BOOL isEmptySpaceToDelete;
@property (nonatomic) NSIndexPath *indexPathToDelete;

@property (nonatomic) SpaceService *spaceService;

@property (nonatomic) TLSpace *selectedSpace;
@property (nonatomic) TLContact *contactToMove;
@property (nonatomic) TLGroup *groupToMove;

@property (nonatomic) BOOL showCurrentSpace;
@property (nonatomic) BOOL refreshTableScheduled;

@end

//
// Implementation: SpacesViewController
//

#undef LOG_TAG
#define LOG_TAG @"SpacesViewController"

@implementation SpacesViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiSpaces = [[NSMutableArray alloc] init];
        _spaceService = [[SpaceService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _pickerMode = NO;
        _showCurrentSpace = NO;
        _isEmptySpaceToDelete = NO;
        _refreshTableScheduled = NO;
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
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateCurrentSpace];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    if (!self.pickerMode) {
        return NO;
    }
    
    return YES;
}

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contactToMove = contact;
}

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.groupToMove = group;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    if (![searchText isEqualToString:@""]) {
        [self.spaceService findSpaceByName:searchText];
    } else {
        [self.spaceService getSpaces];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.spaceService getSpaces];
}

#pragma mark - SpaceServiceDelegate

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
}

- (void)onGetGroups:(nonnull NSArray<TLGroup *> *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
    self.refreshTableScheduled = YES;
    [self updateUISpace:space];
    
    [self reloadData];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    self.refreshTableScheduled = YES;
    [self updateUISpace:space];
    
    TLSpaceSettings *spaceSettings = space.settings;
    if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }
    
    if ([self.currentSpace.uuid isEqual:space.uuid] && ![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
        [Design setMainColor:spaceSettings.style];
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        [mainViewController updateColor];
        [mainViewController refreshTab];
        [self setNavigationBarStyle];
    }
    
    [self reloadData];
}

- (void)onDeleteSpace:(NSUUID *)spaceId {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, spaceId);
    
    for (UISpace *lUISpace in self.uiSpaces) {
        if ([lUISpace.space.uuid isEqual:spaceId]) {
            [self.uiSpaces removeObject:lUISpace];
            break;
        }
    }
    
    self.spaceToDelete = nil;
    self.isEmptySpaceToDelete = NO;
    
    for (UISpace *lUISpace in self.uiSpaces) {
        if ([self.twinmeContext isDefaultSpace:lUISpace.space]) {
            [self.spaceService setCurrentSpace:lUISpace.space];
            break;
        }
    }
    
    [self reloadData];
}

- (void)onGetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onGetCurrentSpace: %@", LOG_TAG, space);
    
    self.currentSpace = space;
    if (!space) {
        return;
    }
    
    for (UISpace *uiSpace in self.uiSpaces) {
        if ([uiSpace.space.uuid isEqual:space.uuid]) {
            uiSpace.isCurrentSpace = YES;
        } else {
            uiSpace.isCurrentSpace = NO;
        }
    }
    
    [self reloadData];
}

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    if (self.pickerMode) {
        [self finish];
    } else {
        [self setLeftBarButtonItem:self.spaceService profile:space.profile];
        
        BOOL found = NO;
        self.currentSpace = space;
        for (UISpace *uiSpace in self.uiSpaces) {
            if ([uiSpace.space.uuid isEqual:space.uuid]) {
                uiSpace.isCurrentSpace = YES;
                found = YES;
            } else {
                uiSpace.isCurrentSpace = NO;
            }
        }
        
        // When the first space is created, onSetCurrentSpace() is called before onCreateSpace().
        self.refreshTableScheduled = YES;
        if (!found) {
            [self updateUISpace:space];
        }
        
        for (UISpace *uiSpace in self.uiSpaces) {
            if (!uiSpace.isCurrentSpace && uiSpace.space.settings.isSecret) {
                [self.uiSpaces removeObject:uiSpace];
                break;
            }
        }
        
        [self reloadData];
        
        TLSpaceSettings *spaceSettings = space.settings;
        if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
            [Design setMainColor:spaceSettings.style];
        }
        
        [Design setupColors:[[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue]];
        
        TwinmeNavigationController *navigationController = (TwinmeNavigationController *)self.navigationController;
        [navigationController setNavigationBarStyle];
        
        if (self.showCurrentSpace) {
            self.showCurrentSpace = NO;
            if (self.searchController.active) {
                [self.searchController dismissViewControllerAnimated:YES completion:^{
                    self.searchController.searchBar.text = @"";
                    [self.spaceService getSpaces];
                    
                    ShowSpaceViewController *showSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowSpaceViewController"];
                    [showSpaceViewController initWithSpace:space];
                    [self.navigationController pushViewController:showSpaceViewController animated:YES];
                }];
            } else {
                ShowSpaceViewController *showSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowSpaceViewController"];
                [showSpaceViewController initWithSpace:space];
                [self.navigationController pushViewController:showSpaceViewController animated:YES];
            }
        }
    }
}

- (void)onUpdateContact:(TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    if (self.pickerMode) {
        [self finish];
    }
}

- (void)onUpdateGroup:(TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
    if (self.pickerMode) {
        [self finish];
    }
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    self.refreshTableScheduled = YES;
    [self updateUISpace:self.currentSpace];
    
    [self reloadData];
}

- (void)onGetSpaces:(NSArray *)spaces {
    DDLogVerbose(@"%@ onGetSpaces: %@", LOG_TAG, spaces);
    
    [self.uiSpaces removeAllObjects];
    
    self.refreshTableScheduled = YES;
    for (TLSpace *space in spaces) {
        [self updateUISpace:space];
    }
    
    [self reloadData];
}

- (void)onGetSpacesNotifications:(NSDictionary<NSUUID *, TLNotificationServiceNotificationStat *> *)spacesNotifications {
    DDLogVerbose(@"%@ onGetSpacesNotifications: %@", LOG_TAG, spacesNotifications);
    
    for (UISpace *uiSpace in self.uiSpaces) {
        TLNotificationServiceNotificationStat *stat = spacesNotifications[uiSpace.space.uuid];
        uiSpace.hasNotification = stat != nil && stat.pendingCount > 0;
        
        if (self.contactToMove && [self.contactToMove.space.uuid isEqual:uiSpace.space.uuid]) {
            uiSpace.isCurrentSpace = YES;
        } else if (self.groupToMove && [self.groupToMove.space.uuid isEqual:uiSpace.space.uuid]) {
            uiSpace.isCurrentSpace = YES;
        } else if (!self.contactToMove && !self.groupToMove && self.currentSpace && [uiSpace.space.uuid isEqual:self.currentSpace.uuid]) {
            uiSpace.isCurrentSpace = YES;
        } else {
            uiSpace.isCurrentSpace = NO;
        }
    }
    [self reloadData];
}

- (void)onEmptySpace:(TLSpace *)space empty:(BOOL)empty {
    DDLogVerbose(@"%@ onEmptySpace: %@ empty: %d", LOG_TAG, space, empty);
    
}

- (void)updateUISpace:(TLSpace *)space {
    DDLogVerbose(@"%@ updateUISpace: %@", LOG_TAG, space);
    
    UISpace *uiSpace = nil;
    for (UISpace *lUISpace in self.uiSpaces) {
        if ([lUISpace.space.uuid isEqual:space.uuid]) {
            uiSpace = lUISpace;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiSpace)  {
        [self.uiSpaces removeObject:uiSpace];
        [uiSpace setSpace:space defaultSpaceSettings:self.twinmeContext.defaultSpaceSettings];
    } else {
        uiSpace = [[UISpace alloc] initWithSpace:space defaultSpaceSettings:self.twinmeContext.defaultSpaceSettings];
    }
    if (space.profile) {
        [self.spaceService getImageWithProfile:space.profile withBlock:^(UIImage *image) {
            uiSpace.avatar = image;
            [self refreshTable];
        }];
    }
    if (space.avatarId) {
        [self.spaceService getImageWithSpace:space withBlock:^(UIImage *image) {
            uiSpace.avatarSpace = image;
            [self refreshTable];
        }];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiSpaces.count;
    for (NSInteger i = 0; i < count; i++) {
        UISpace *lUISpace = self.uiSpaces[i];
        if ([lUISpace.nameSpace caseInsensitiveCompare:uiSpace.nameSpace] == NSOrderedDescending) {
            [self.uiSpaces insertObject:uiSpace atIndex:i];
            added = YES;
            break;
        }
    }
    
    if (self.currentSpace && [self.currentSpace.uuid isEqual:space.uuid]) {
        uiSpace.isCurrentSpace = YES;
    } else {
        uiSpace.isCurrentSpace = NO;
    }
    
    if (!added) {
        [self.uiSpaces addObject:uiSpace];
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);
    
    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.spacesTableView reloadData];
        });
    }
}

#pragma mark - SpaceActionDelegate

- (void)showSpace:(UISpace *)uiSpace {
    DDLogVerbose(@"%@ editSpace: %@", LOG_TAG, uiSpace);
    
    [self.spaceService setCurrentSpace:uiSpace.space];
    
    self.showCurrentSpace = YES;
}

- (void)activeSpace:(UISpace *)uiSpace {
    DDLogVerbose(@"%@ activeSpace: %@", LOG_TAG, uiSpace);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    [self.spaceService setCurrentSpace:uiSpace.space];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[SpaceActionConfirmView class]]) {
        SpaceActionConfirmView *spaceActionConfirmView = (SpaceActionConfirmView *)abstractConfirmView;
        
        if (spaceActionConfirmView.spaceActionConfirmType == SpaceActionConfirmTypeProfile) {
            EditProfileViewController *editProfileViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [editProfileViewController initWithSpace:self.selectedSpace];
            [self.navigationController pushViewController:editProfileViewController animated:YES];
        } else if (spaceActionConfirmView.spaceActionConfirmType == SpaceActionConfirmTypeMoveContact) {
            if (self.contactToMove) {
                [self.spaceService moveContactToSpace:self.selectedSpace contact:self.contactToMove];
            } else if (self.groupToMove) {
                [self.spaceService moveGroupToSpace:self.selectedSpace group:self.groupToMove];
            }
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

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SPACES_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.uiSpaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SpaceCell *spaceCell = (SpaceCell *)[tableView dequeueReusableCellWithIdentifier:SPACE_CELL_IDENTIFIER];
    if (!spaceCell) {
        spaceCell = [[SpaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SPACE_CELL_IDENTIFIER];
    }
    
    UISpace *uiSpace = [self.uiSpaces objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.uiSpaces.count ? YES : NO;
    [spaceCell bindWithSpace:uiSpace hideSeparator:hideSeparator];
    
    if (!self.pickerMode) {
        spaceCell.spaceActionDelegate = self;
    }
    
    return spaceCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UISpace *uiSpace = [self.uiSpaces objectAtIndex:indexPath.row];
    
    if (self.contactToMove) {
        if (!uiSpace.space.profile) {
            self.selectedSpace = uiSpace.space;
            
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeProfile;
            [spaceActionConfirmView initWithTitle:TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil) message:TwinmeLocalizedString(@"create_space_view_controller_contacts_no_profile", nil) spaceName:self.selectedSpace.settings.name spaceStyle:self.selectedSpace.settings.style avatar:uiSpace.avatarSpace icon:[UIImage imageNamed:@"ActionBarAddContact"] confirmTitle:TwinmeLocalizedString(@"application_now", nil) cancelTitle:TwinmeLocalizedString(@"application_later", nil)];
           
            if (self.pickerMode) {
                [self.navigationController.view addSubview:spaceActionConfirmView];
            } else {
                [self.tabBarController.view addSubview:spaceActionConfirmView];
            }
            [spaceActionConfirmView showConfirmView];
        } else if (![uiSpace.space hasPermission:TLSpacePermissionTypeCreateContact]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
            
            if (self.pickerMode) {
                [self.navigationController.view addSubview:alertMessageView];
            } else {
                [self.tabBarController.view addSubview:alertMessageView];
            }
            
            [alertMessageView showAlertView];
        } else if ([self.contactToMove.space.uuid isEqual:uiSpace.space.uuid]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_move_contact_already_in_space", nil)];
            
            if (self.pickerMode) {
                [self.navigationController.view addSubview:alertMessageView];
            } else {
                [self.tabBarController.view addSubview:alertMessageView];
            }
            
            [alertMessageView showAlertView];
        } else {
            self.selectedSpace = uiSpace.space;
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeMoveContact;
            [spaceActionConfirmView initWithTitle:uiSpace.nameSpace message:TwinmeLocalizedString(@"contacts_space_view_controller_move_message", nil) spaceName:uiSpace.nameSpace spaceStyle:uiSpace.space.settings.style avatar:uiSpace.avatarSpace icon:[UIImage imageNamed:@"TabBarContactsGrey"] confirmTitle:TwinmeLocalizedString(@"contacts_space_view_controller_move_title", nil) cancelTitle:TwinmeLocalizedString(@"application_cancel", nil)];
            if (self.pickerMode) {
                [self.navigationController.view addSubview:spaceActionConfirmView];
            } else {
                [self.tabBarController.view addSubview:spaceActionConfirmView];
            }
            
            [spaceActionConfirmView showConfirmView];
        }
    } else if (self.groupToMove) {
        if (!uiSpace.space.profile) {
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeProfile;
            [spaceActionConfirmView initWithTitle:TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil) message:TwinmeLocalizedString(@"spaces_view_controller_move_group_no_profile", nil) spaceName:self.selectedSpace.settings.name spaceStyle:self.selectedSpace.settings.style avatar:uiSpace.avatarSpace icon:[UIImage imageNamed:@"ActionBarAddContact"] confirmTitle:TwinmeLocalizedString(@"application_now", nil) cancelTitle:TwinmeLocalizedString(@"application_later", nil)];
           
            if (self.pickerMode) {
                [self.navigationController.view addSubview:spaceActionConfirmView];
            } else {
                [self.tabBarController.view addSubview:spaceActionConfirmView];
            }
            [spaceActionConfirmView showConfirmView];
        } else if (![uiSpace.space hasPermission:TLSpacePermissionTypeCreateGroup]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
            
            if (self.pickerMode) {
                [self.navigationController.view addSubview:alertMessageView];
            } else {
                [self.tabBarController.view addSubview:alertMessageView];
            }
            
            [alertMessageView showAlertView];
        } else if ([self.groupToMove.space.uuid isEqual:uiSpace.space.uuid]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_move_group_already_in_space", nil)];
            
            if (self.pickerMode) {
                [self.navigationController.view addSubview:alertMessageView];
            } else {
                [self.tabBarController.view addSubview:alertMessageView];
            }
            
            [alertMessageView showAlertView];
        } else {
            self.selectedSpace = uiSpace.space;
            
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeMoveContact;
            [spaceActionConfirmView initWithTitle:uiSpace.nameSpace message:TwinmeLocalizedString(@"spaces_view_controller_move_message", nil) spaceName:uiSpace.nameSpace spaceStyle:uiSpace.space.settings.style avatar:uiSpace.avatarSpace icon:[UIImage imageNamed:@"TabBarContactsGrey"] confirmTitle:TwinmeLocalizedString(@"contacts_space_view_controller_move_title", nil) cancelTitle:TwinmeLocalizedString(@"application_cancel", nil)];
            if (self.pickerMode) {
                [self.navigationController.view addSubview:spaceActionConfirmView];
            } else {
                [self.tabBarController.view addSubview:spaceActionConfirmView];
            }
            
            [spaceActionConfirmView showConfirmView];
        }
    } else if (self.spacesPickerDelegate) {
        if (!uiSpace.space.profile) {
            SpaceActionConfirmView *spaceActionConfirmView = [[SpaceActionConfirmView alloc] init];
            spaceActionConfirmView.confirmViewDelegate = self;
            spaceActionConfirmView.spaceActionConfirmType = SpaceActionConfirmTypeProfile;
            [spaceActionConfirmView initWithTitle:TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil) message:TwinmeLocalizedString(@"create_space_view_controller_contacts_no_profile", nil) spaceName:uiSpace.space.settings.name spaceStyle:uiSpace.space.settings.style avatar:uiSpace.avatarSpace icon:[UIImage imageNamed:@"ActionBarAddContact"] confirmTitle:TwinmeLocalizedString(@"application_now", nil) cancelTitle:TwinmeLocalizedString(@"application_later", nil)];
           
            if (self.pickerMode) {
                [self.navigationController.view addSubview:spaceActionConfirmView];
            } else {
                [self.tabBarController.view addSubview:spaceActionConfirmView];
            }
            [spaceActionConfirmView showConfirmView];
        } else {
            [self.spacesPickerDelegate didSelectSpace:uiSpace.space];
            [self finish];
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"spaces_view_controller_title", nil).capitalizedString];
    
    if (!self.pickerMode) {
        UIBarButtonItem *addSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ActionBarAddSpace"] style:UIBarButtonItemStylePlain target:self action:@selector(handleCreateSpaceGesture:)];
        self.navigationItem.rightBarButtonItem = addSpaceBarButtonItem;
    }
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    
    UISearchBar *spaceSearchBar = self.searchController.searchBar;
    spaceSearchBar.barStyle = UIBarStyleDefault;
    spaceSearchBar.searchBarStyle = UISearchBarStyleProminent;
    spaceSearchBar.translucent = NO;
    spaceSearchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    spaceSearchBar.tintColor = [UIColor whiteColor];
    spaceSearchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    spaceSearchBar.backgroundImage = [UIImage new];
    spaceSearchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    spaceSearchBar.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.barTintColor = Design.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.spacesTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.spacesTableView.delegate = self;
    self.spacesTableView.dataSource = self;
    self.spacesTableView.backgroundColor = Design.WHITE_COLOR;
    self.spacesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.spacesTableView registerNib:[UINib nibWithNibName:@"SpaceCell" bundle:nil] forCellReuseIdentifier:SPACE_CELL_IDENTIFIER];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    if (self.pickerMode) {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    }
    
    self.noSpaceView.hidden = YES;
    self.noSpaceView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self initNoSpaceViews];
    
    self.noSpaceMessageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noSpaceMessageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noSpaceMessageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noSpaceMessageLabel.font = Design.FONT_MEDIUM34;
    self.noSpaceMessageLabel.text = TwinmeLocalizedString(@"spaces_view_controller_message", nil);
    
    self.createSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.createSpaceViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createSpaceViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.createSpaceView.backgroundColor = Design.MAIN_COLOR;
    self.createSpaceView.userInteractionEnabled = YES;
    self.createSpaceView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.createSpaceView.clipsToBounds = YES;
    [self.createSpaceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCreateSpaceGesture:)]];
    
    self.createSpaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createSpaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.createSpaceLabel.font = Design.FONT_MEDIUM34;
    self.createSpaceLabel.textColor = [UIColor whiteColor];
    self.createSpaceLabel.text = TwinmeLocalizedString(@"spaces_view_controller_create_new_space", nil);
    
    self.moreInfoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.moreInfoViewBottomtConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.moreInfoView.userInteractionEnabled = YES;
    [self.moreInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDiscoverSpaceGesture:)]];
    
    self.moreInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.moreInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.moreInfoLabel.font = Design.FONT_BOLD28;
    self.moreInfoLabel.text = TwinmeLocalizedString(@"application_more_info", nil);
    
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

- (void)initNoSpaceViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.sampleSpaceFriendsViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceFriendsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFriendsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFriendsImageView.image = [UIImage imageNamed:@"SpaceSampleFriends"];
    
    self.sampleSpaceFriendsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sampleSpaceFamilyViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFamilyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceFamilyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFamilyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFamilyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFamilyImageView.image = [UIImage imageNamed:@"SpaceSampleFamily"];
    
    self.sampleSpaceFamilyLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFamilyLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sampleSpaceBusinessViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceBusinessViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceBusinessImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceBusinessImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceBusinessImageView.image = [UIImage imageNamed:@"SpaceSampleBusiness"];
    
    self.sampleSpaceBusinessLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceBusinessLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self updateNoSpaceViews];
}

- (void)updateNoSpaceViews {
    DDLogVerbose(@"%@ updateNoSpaceViews", LOG_TAG);
    
    self.sampleSpaceFriendsView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.sampleSpaceFriendsView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sampleSpaceFriendsView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sampleSpaceFriendsView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sampleSpaceFriendsView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.sampleSpaceFriendsView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_friends", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_friends_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceFriendsLabel.attributedText = attributedString;
    
    self.sampleSpaceFamilyView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.sampleSpaceFamilyView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sampleSpaceFamilyView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sampleSpaceFamilyView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sampleSpaceFamilyView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.sampleSpaceFamilyView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_family", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_family_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceFamilyLabel.attributedText = attributedString;
    
    self.sampleSpaceBusinessView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.sampleSpaceBusinessView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sampleSpaceBusinessView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sampleSpaceBusinessView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sampleSpaceBusinessView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.sampleSpaceBusinessView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_business", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_business_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceBusinessLabel.attributedText = attributedString;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.spaceService dispose];
    
    if (self.pickerMode) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
}

- (IBAction)handleCreateSpaceGesture:(id)sender {
    DDLogVerbose(@"%@ handleCreateSpaceGesture: %@", LOG_TAG, sender);
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeSpace]) {
        OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        
        if (self.currentSpace) {
            [onboardingSpaceViewController showInView:mainViewController hideFirstPart:NO];
        } else {
            [onboardingSpaceViewController showInView:mainViewController hideFirstPart:YES];
        }
    } else {
        TemplateSpaceViewController *templateSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateSpaceViewController"];
        [self.navigationController pushViewController:templateSpaceViewController animated:YES];
    }
}

- (IBAction)handleDiscoverSpaceGesture:(id)sender {
    DDLogVerbose(@"%@ handleDiscoverSpaceGesture: %@", LOG_TAG, sender);
    
    OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [onboardingSpaceViewController showInView:mainViewController hideFirstPart:YES];
}

- (void)handleEditSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ handleEditSpace: %@", LOG_TAG, space);
    
    EditSpaceViewController *editSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditSpaceViewController"];
    [editSpaceViewController initWithSpace:space];
    [self.navigationController pushViewController:editSpaceViewController animated:YES];
}

- (IBAction)handleNotificationTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleNotificationTapGesture: %@", LOG_TAG, sender);
    
    NotificationViewController *notificationViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [self.navigationController pushViewController:notificationViewController animated:YES];
}

- (IBAction)handleAddContactTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    if (!self.currentSpace.profile) {
        AddProfileViewController *addProfileViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        addProfileViewController.fromContactsTab = YES;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    } else if (![self.currentSpace hasPermission:TLSpacePermissionTypeCreateContact]) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
        
        if (self.pickerMode) {
            [self.navigationController.view addSubview:alertMessageView];
        } else {
            [self.tabBarController.view addSubview:alertMessageView];
        }
        
        [alertMessageView showAlertView];
    } else {
        AddContactViewController *addContactViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AddContactViewController"];
        [addContactViewController initWithProfile:self.currentSpace.profile invitationMode:NO];
        [self.navigationController pushViewController:addContactViewController animated:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.spacesTableViewBottomConstraint.constant = keyboardSize.height;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardDidShow: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGPoint keyboardOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    self.spacesTableViewBottomConstraint.constant = self.view.frame.size.height - keyboardOrigin.y;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.spacesTableViewBottomConstraint.constant = 0;
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if (self.uiSpaces.count == 0 && !self.searchController.active) {
        self.noSpaceView.hidden = NO;
        self.spacesTableView.hidden = YES;
        self.noResultFoundImageView.hidden = YES;
        self.noResultFoundTitleLabel.hidden = YES;
        
        [self.navigationController.navigationBar setPrefersLargeTitles:NO];
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = nil;
        }
    } else {
        self.noSpaceView.hidden = YES;
        self.spacesTableView.hidden = NO;
        
        if (!self.pickerMode) {
            [self.navigationController.navigationBar setPrefersLargeTitles:YES];
            self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
        }
        
        if (@available(iOS 13.0, *)) {
            self.navigationItem.searchController = self.searchController;
        }
        
        if (self.uiSpaces.count == 0 && self.searchController.active) {
            self.noResultFoundImageView.hidden = NO;
            self.noResultFoundTitleLabel.hidden = NO;
            self.noResultFoundTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversations_view_controller_no_result_found", nil), self.searchController.searchBar.text];
        } else {
            self.noResultFoundImageView.hidden = YES;
            self.noResultFoundTitleLabel.hidden = YES;
        }
    }
    
    for (UISpace *uiSpace in self.uiSpaces) {
        [uiSpace updateSpaceSettings:uiSpace.space defaultSpaceSettings: self.twinmeContext.defaultSpaceSettings];
    }
    
    self.refreshTableScheduled = NO;
    [self.spacesTableView reloadData];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    self.noResultFoundTitleLabel.font = Design.FONT_MEDIUM34;
    
    [self reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.spacesTableView.backgroundColor = Design.WHITE_COLOR;
    self.noResultFoundTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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

- (void)setNavigationBarStyle {
    DDLogVerbose(@"%@ setNavigationBarStyle", LOG_TAG);
    
    if (!self.pickerMode) {
        TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
        [navigationController setNavigationBarStyle];
        
        self.view.backgroundColor = Design.WHITE_COLOR;
        self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
        self.searchController.searchBar.backgroundColor  = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    }
}

- (void)updateCurrentSpace {
    DDLogVerbose(@"%@ updateCurrentSpace", LOG_TAG);
    
    if (!self.pickerMode) {
        [self setLeftBarButtonItem:self.spaceService profile:self.currentSpace.profile];
    }
    
    [self updateColor];
}

@end
