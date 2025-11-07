/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>
#import <Twinme/UIImage+Resize.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "ShowSpaceViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "EditProfileViewController.h"
#import "EditSpaceViewController.h"
#import "EditManagedSpaceViewController.h"
#import "ContactsSpaceViewController.h"
#import "AddProfileViewController.h"
#import "AddContactViewController.h"
#import "SettingsSpaceViewController.h"
#import "SpacesViewController.h"
#import "ShowProfileViewController.h"
#import <TwinmeCommon/MainViewController.h>
#import "ExportViewController.h"
#import "TypeCleanUpViewController.h"

#import <TwinmeCommon/ShowSpaceService.h>

#import "UIContact.h"

#import "AlertView.h"
#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "MenuSelectValueView.h"
#import "UIColor+Hex.h"

#import "UIViewController+ProgressIndicator.h"
#import "SlideContactView.h"
#import "SwitchView.h"
#import "SpaceSetting.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_SPACE_NAME_COLOR;
static CGFloat DESIGN_ACTION_VIEW_TOP_MARGIN = 160;
static CGFloat DESIGN_HEADER_VIEW_TOP_MARGIN = 36;
static CGFloat DESIGN_HEADER_VIEW_NO_PROFILE_TOP_MARGIN = 92;
static CGFloat DESIGN_SPACE_LABEL_TOP_MARGIN = 20;
static CGFloat DESIGN_PROFILE_AVATAR_HEIGHT = 216;

static NSInteger CREATE_PROFILE_ALERT_VIEW_TAG = 1;
static NSInteger SECRET_ALERT_VIEW_TAG = 2;

//
// Interface: ShowSpaceViewController ()
//

@interface ShowSpaceViewController () <ShowSpaceServiceDelegate, AlertViewDelegate, SwitchViewDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityAvatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityNameViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *configurationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *configurationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *configurationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationAccessoryImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationAccessoryImageTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *configurationAccessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *contactsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contactsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contactsListImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsListImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsListImageTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *secretView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *secretImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *secretLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *secretSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *conversationsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *exportView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *exportLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *cleanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cleanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanAccessoryView;

@property (nonatomic) CALayer *avatarContainerViewLayer;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) NSString *nameSpace;
@property (nonatomic) BOOL toRootView;
@property (nonatomic) BOOL canUpdate;

@property (nonatomic) MenuSelectValueView *menuSelectValueView;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) TLSpace *space;

@property (nonatomic) ShowSpaceService *showSpaceService;

@end

#undef LOG_TAG
#define LOG_TAG @"ShowSpaceViewController"

@implementation ShowSpaceViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_SPACE_NAME_COLOR = [UIColor colorWithRed:140./255. green:159./255. blue:175./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _toRootView = NO;
        _canUpdate = YES;
        
        _showSpaceService = [[ShowSpaceService alloc] initWithTwinmeContext:self.twinmeContext delegate:self createSpace:NO];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    self.canUpdate = YES;
    
    if (!self.space) {
        self.space = self.currentSpace;
    }
    
    if (!self.avatar && self.space.avatarId) {
        [self.showSpaceService getSpace:self.space.uuid];
    }
    
    [self updateSpace];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    self.canUpdate = NO;
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    if (self.space.profile) {
        ShowProfileViewController *showProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowProfileViewController"];
        [showProfileViewController initWithProfile:self.space.profile];
        [self.navigationController pushViewController:showProfileViewController animated:YES];
    } else {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = NO;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    }
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    if (self.space.isManagedSpace) {
        EditManagedSpaceViewController *editManagedSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditManagedSpaceViewController"];
        [editManagedSpaceViewController initWithSpace:self.space];
        [self.navigationController pushViewController:editManagedSpaceViewController animated:YES];
    } else {
    EditSpaceViewController *editSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"EditSpaceViewController"];
    [editSpaceViewController initWithSpace:self.space];
    [self.navigationController pushViewController:editSpaceViewController animated:YES];
    }
}

- (BOOL)hasPeer {
    DDLogVerbose(@"%@ hasPeer", LOG_TAG);
    
    if (self.space) {
        return YES;
    }
    
    return NO;
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    return self.cleanView.frame.origin.y + self.cleanViewHeightConstraint.constant + safeAreaInset - self.identityAvatarViewTopConstraint.constant;
}

#pragma mark - ShowSpaceServiceDelegate

- (void)onGetSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.avatar = nil;
    
    [self updateSpace];
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateSpace: %@ avatar: %@", LOG_TAG, space, avatar);
    
    if ([self.space.uuid isEqual:space.uuid]) {
        self.space = space;
        self.avatar = avatar;
        
        [self updateSpace];
    }
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
    
    if ([spaceId isEqual:self.space.uuid]) {
        self.toRootView = YES;
        [self finish];
    }
}

- (void)onErrorSpaceNotFound {
    DDLogVerbose(@"%@ onErrorSpaceNotFound", LOG_TAG);
    
    [self finish];
}

#pragma mark - Public methods

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    [self.showSpaceService initWithSpace:space];
}

#pragma mark - Setters/Getters

- (void)setSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ setSpace: %@", LOG_TAG, space);
    
    _space = space;
}

#pragma mark - AlertViewDelegate

- (void)handleAcceptButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleAcceptButtonClick: %@", LOG_TAG, alertView);
    
    if (alertView.view.tag == CREATE_PROFILE_ALERT_VIEW_TAG) {
        [self identityTap];
    }
}

- (void)handleCancelButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCancelButtonClick: %@", LOG_TAG, alertView);
    
    if (alertView.view.tag == SECRET_ALERT_VIEW_TAG) {
        [self.secretSwitch setOn:YES];
        [self switchViewDidTap:self.secretSwitch];
        [self.secretSwitch setConfirm:NO];
    }
}

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);
    
    [self closeMenu];
    
    if (value == 0) {
        [self editTap];
    } else {
        EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
        [editProfileViewController initWithProfile:self.space.profile];
        [self.navigationController pushViewController:editProfileViewController animated:YES];
    }
}

- (void)cancelMenu {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    self.menuSelectValueView.hidden = YES;
    self.overlayView.hidden = YES;

    [self closeMenu];
}


#pragma mark - SwitchViewDelegate

- (void)switchViewDidTap:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchViewDidTap: %@", LOG_TAG, switchView);
    
    if (switchView.isOn && [self.twinmeContext isDefaultSpace:self.space]) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        
        TLSpace *nextDefaultSpace = [mainViewController getNextDefaultSpace:self.space];
        
        if (!nextDefaultSpace) {
            return;
        }
        
        [self.showSpaceService setDefaultSpace:nextDefaultSpace];
    }
    
    TLSpaceSettings *spaceSettings = [[TLSpaceSettings alloc] initWithSettings:self.space.settings];
    spaceSettings.isSecret = switchView.isOn;
    [spaceSettings setBooleanWithName:PROPERTY_DISPLAY_NOTIFICATIONS value:!switchView.isOn];
    [self.showSpaceService updateSpace:spaceSettings];
}

- (void)switchViewNeedsConfirm:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchViewDidTap: %@", LOG_TAG, switchView);
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"show_space_view_controller_secret_message", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"show_space_view_controller_secret_message_confirm", nil)];
        
    AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"settings_space_view_controller_secret_title", nil) message:message cancelButtonTitle:TwinmeLocalizedString(@"application_yes", nil) otherButtonTitles:TwinmeLocalizedString(@"application_no", nil) alertViewDelegate:self];
    alertView.view.tag = SECRET_ALERT_VIEW_TAG;
    [alertView showInView:self.tabBarController];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil).capitalizedString];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.headerViewTopConstraint.constant = DESIGN_HEADER_VIEW_TOP_MARGIN * Design.HEIGHT_RATIO;
    
    self.spaceLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.descriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.identityAvatarView.userInteractionEnabled = YES;
    self.identityAvatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.identityAvatarView.layer.borderWidth = 2;
    self.identityAvatarView.layer.borderColor = Design.WHITE_COLOR.CGColor;
    
    [self.identityAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeTapGesture:)]];
    
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.twincodeView.userInteractionEnabled = YES;
    self.twincodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodeView.clipsToBounds = YES;
    [self.twincodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeTapGesture:)]];
    
    self.twincodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.twincodeLabel.font = Design.FONT_REGULAR30;
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
    
    [self.twincodeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.contactsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contactsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.contactsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth  height:self.contactsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.contactsView.userInteractionEnabled = true;
    self.contactsView.isAccessibilityElement = YES;
    self.contactsView.accessibilityLabel = TwinmeLocalizedString(@"create_space_view_controller_contact_list", nil);
    self.contactsView.backgroundColor = Design.WHITE_COLOR;
    
    UITapGestureRecognizer *contactsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleContactsTapGesture:)];
    [self.contactsView addGestureRecognizer:contactsViewGestureRecognizer];
    
    self.contactsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contactsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.contactsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsLabel.font = Design.FONT_REGULAR34;
    self.contactsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.contactsLabel.text = TwinmeLocalizedString(@"create_space_view_controller_contact_list", nil);
    
    self.contactsListImageHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.contactsListImageTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsListImageView.tintColor = Design.ACCESSORY_COLOR;
    self.contactsListImageView.image = [self.contactsListImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.settingsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.text = TwinmeLocalizedString(@"show_space_view_controller_management", nil).uppercaseString;
    
    self.configurationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.configurationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.configurationView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth  height:self.configurationViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.configurationView.userInteractionEnabled = true;
    self.configurationView.backgroundColor = Design.WHITE_COLOR;
    self.configurationView.isAccessibilityElement = YES;
    self.configurationView.accessibilityLabel = TwinmeLocalizedString(@"settings_view_controller_title", nil);
    
    UITapGestureRecognizer *configurationViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfigurationTapGesture:)];
    [self.configurationView addGestureRecognizer:configurationViewGestureRecognizer];
    
    self.configurationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationLabel.font = Design.FONT_REGULAR34;
    self.configurationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.configurationLabel.text = TwinmeLocalizedString(@"settings_view_controller_title", nil);
    
    self.configurationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.configurationImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.configurationAccessoryImageHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.configurationAccessoryImageTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.configurationAccessoryImageView.image = [self.configurationAccessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.configurationAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    
    self.secretViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.secretView.backgroundColor = Design.WHITE_COLOR;
    self.secretView.isAccessibilityElement = YES;
    self.secretView.accessibilityLabel = TwinmeLocalizedString(@"settings_space_view_controller_secret_title", nil);
    
    [self.secretView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth  height:self.secretViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressSecretGesture:)];
    [self.secretView addGestureRecognizer:longPressGesture];
    
    self.secretImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.secretImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.secretImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.secretLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.secretLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.secretLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.secretLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.secretLabel.text = TwinmeLocalizedString(@"settings_space_view_controller_secret_title", nil);
    self.secretLabel.font = Design.FONT_REGULAR34;
    self.secretLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    CGSize switchSize = [Design switchSize];
    self.secretSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.secretSwitchHeightConstraint.constant = switchSize.height;
    self.secretSwitchWidthConstraint.constant = switchSize.width;
    
    self.secretSwitch.switchViewDelegate = self;
    
    self.conversationsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.conversationsTitleLabel.font = Design.FONT_BOLD28;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.text = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
    
    self.exportViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.exportViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportView.isAccessibilityElement = YES;
    self.exportView.accessibilityLabel = TwinmeLocalizedString(@"show_contact_view_controller_export_contents", nil);
    
    UITapGestureRecognizer *exportViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExportTapGesture:)];
    [self.exportView addGestureRecognizer:exportViewGestureRecognizer];
    
    [self.exportView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.exportViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.exportImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.exportLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.exportLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_export_contents", nil);
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.exportAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    
    self.exportAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.exportAccessoryView.image = [self.exportAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.cleanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cleanViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCleanTapGesture:)];
    [self.cleanView addGestureRecognizer:cleanViewGestureRecognizer];
    
    self.cleanView.isAccessibilityElement = YES;
    self.cleanView.accessibilityLabel = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
    
    [self.cleanView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.cleanViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.cleanImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.cleanLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cleanLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.cleanAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    
    self.cleanAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.cleanAccessoryView.image = [self.cleanAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.menuSelectValueView = [[MenuSelectValueView alloc] init];
    self.menuSelectValueView.hidden = YES;
    self.menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:self.menuSelectValueView];
    
    self.overlayView = [UIView new];
    self.overlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    self.overlayView.userInteractionEnabled = YES;
    [self.tabBarController.view addSubview:self.overlayView];
    
    UITapGestureRecognizer *tapOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOverlayTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGesture];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.showSpaceService) {
        [self.showSpaceService dispose];
        self.showSpaceService = nil;
    }
    
    if (self.toRootView) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{}];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [CATransaction commit];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleOverlayTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleOverlayTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.menuSelectValueView.hidden = YES;
        self.overlayView.hidden = YES;
    }
}

- (void)handleLongPressSecretGesture:(UILongPressGestureRecognizer *)longPressGesture {
    DDLogVerbose(@"%@ handleLongPressSecretGesture: %@", LOG_TAG, longPressGesture);
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"settings_space_view_controller_secret_title", nil) message:TwinmeLocalizedString(@"settings_space_view_controller_secret_message", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_ok", nil) otherButtonTitles:nil alertViewDelegate:nil];
        [alertView showInView:self.tabBarController];
    }
}

- (void)closeMenu {
    DDLogVerbose(@"%@ closeMenu", LOG_TAG);
    
    self.overlayView.hidden = YES;
    self.menuSelectValueView.hidden = YES;
}

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    self.overlayView.hidden = NO;
    self.menuSelectValueView.hidden = NO;
    [self.tabBarController.view bringSubviewToFront:self.overlayView];
    [self.tabBarController.view bringSubviewToFront:self.menuSelectValueView];
    
    CGRect rectMenu = self.menuSelectValueView.frame;
    rectMenu.origin.y = Design.DISPLAY_HEIGHT;
    self.menuSelectValueView.frame = rectMenu;
    
    [self.menuSelectValueView openMenu];
}

- (void)handleTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.space.profile) {
            ShowProfileViewController *showProfileViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowProfileViewController"];
            [showProfileViewController initWithProfile:self.space.profile];
            [self.navigationController pushViewController:showProfileViewController animated:YES];
        } else {
            EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [editProfileViewController initWithSpace:self.space];
            [self.navigationController pushViewController:editProfileViewController animated:YES];
        }
    }
}

- (void)handleContactsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleContactsTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        
        if (self.space.profile && [mainViewController numberSpaces:YES] <= 1) {
            AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"create_space_view_controller_contact_list", nil) message:TwinmeLocalizedString(@"show_space_view_controller_move_message", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_ok", nil) otherButtonTitles:nil alertViewDelegate:nil];
            [alertView showInView:self.tabBarController];
        } else if (self.space.profile) {
            ContactsSpaceViewController *contactsSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactsSpaceViewController"];
            [contactsSpaceViewController initWithSpace:self.space];
            [self.navigationController pushViewController:contactsSpaceViewController animated:YES];
        } else {
            AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"application_profile", nil) message:TwinmeLocalizedString(@"create_space_view_controller_contacts_no_profile", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_later", nil) otherButtonTitles:TwinmeLocalizedString(@"application_now", nil) alertViewDelegate:self];
            alertView.view.tag = CREATE_PROFILE_ALERT_VIEW_TAG;
            [alertView showInView:self.tabBarController];
        }
    }
}

- (void)handleConfigurationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfigurationTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.space.profile) {
            SettingsSpaceViewController *settingsSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsSpaceViewController"];
            [settingsSpaceViewController initWithSpace:self.space];
            [self.navigationController pushViewController:settingsSpaceViewController animated:YES];
        } else {
            [self identityTap];
        }
    }
}

- (void)handleSpaceListTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceListTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        SpacesViewController *spacesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpacesViewController"];
        spacesViewController.pickerMode = YES;
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)handleEditTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEditTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.space.profile) {
            [self editTap];
        } else {
            [self.menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeEditSpace];
            [self openMenuSelectValue];
        }
    }
}

- (IBAction)handleAddContactTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    if (!self.currentSpace.profile) {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        [self.navigationController pushViewController:addProfileViewController animated:YES];
    } else if (![self.currentSpace hasPermission:TLSpacePermissionTypeCreateContact]) {
        AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_ok", nil) otherButtonTitles:nil alertViewDelegate:nil];
        [alertView showInView:self.tabBarController];
    } else {
        AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
        [addContactViewController initWithProfile:self.currentSpace.profile invitationMode:NO];
        [self.navigationController pushViewController:addContactViewController animated:YES];
    }
}

- (void)handleExportTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleExportTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ExportViewController *exportViewController = (ExportViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
        [exportViewController initExportWithSpace:self.space];
        [self.navigationController pushViewController:exportViewController animated:YES];
    }
}

- (void)handleCleanTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCleanTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        TypeCleanUpViewController *cleanUpViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
        [cleanUpViewController initCleanUpWithSpace:self.space];
        [self.navigationController pushViewController:cleanUpViewController animated:YES];
    }
}

- (void)updateSpace {
    DDLogVerbose(@"%@ updateSpace", LOG_TAG);
    
    if (!self.canUpdate) {
        return;
    }
    
    if (self.space) {
        self.navigationController.navigationBarHidden = YES;
        self.secretView.hidden = NO;
        self.avatarView.hidden = NO;
        self.actionView.hidden = NO;
        
        self.nameLabel.text = self.space.settings.name;
        self.descriptionLabel.text = self.space.settings.spaceDescription;
        
        self.identityAvatarView.image = [self.showSpaceService getImageWithProfile:self.space.profile];
        self.identityAvatarView.hidden = NO;
        self.avatarView.backgroundColor = [UIColor clearColor];
        
        if (self.avatar) {
            self.avatarView.image = self.avatar;
        } else if (!self.space.avatarId) {
            self.avatarView.image = [UIImage imageNamed:@"TwinmeLogo3D"];
            self.avatarView.backgroundColor = Design.BACKGROUND_SPACE_AVATAR_COLOR;
        } else {
            UIImage *image = [self.showSpaceService getImageWithSpace:self.space];
            self.avatarView.image = image;
        }
        
        if (self.space.profile) {
            self.configurationView.alpha = 1.0;
            self.identityAvatarView.hidden = NO;
            self.nameLabel.hidden = NO;
            self.identityLabel.text = self.space.profile.name;
            self.twincodeImageView.image = [UIImage imageNamed:@"QRCode"];
            self.twincodeLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
            self.identityAvatarViewTopConstraint.constant = -(DESIGN_PROFILE_AVATAR_HEIGHT * Design.HEIGHT_RATIO * 0.5);
            self.identityNameViewTopConstraint.constant = (DESIGN_PROFILE_AVATAR_HEIGHT * Design.HEIGHT_RATIO * 0.5) + (DESIGN_HEADER_VIEW_TOP_MARGIN * Design.HEIGHT_RATIO);
            self.spaceLabelHeightConstraint.constant = self.nameLabel.font.lineHeight;
            self.spaceLabelTopConstraint.constant = DESIGN_SPACE_LABEL_TOP_MARGIN * Design.HEIGHT_RATIO;
        } else {
            self.configurationView.alpha = 0.5;
            self.identityAvatarView.hidden = YES;
            self.identityLabel.text = self.space.settings.name;
            self.nameLabel.hidden = YES;
            self.twincodeImageView.image = [UIImage imageNamed:@"ActionBarAddContact"];
            self.twincodeLabel.text = TwinmeLocalizedString(@"edit_profile_view_controller_add", nil);

            self.identityAvatarViewTopConstraint.constant = -(DESIGN_PROFILE_AVATAR_HEIGHT * Design.HEIGHT_RATIO);
            self.identityNameViewTopConstraint.constant = DESIGN_HEADER_VIEW_NO_PROFILE_TOP_MARGIN * Design.HEIGHT_RATIO;
            self.spaceLabelHeightConstraint.constant = 0;
            self.spaceLabelTopConstraint.constant = 0;
        }
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        
        if (self.space.profile && [mainViewController numberSpaces:YES] > 1) {
            self.contactsView.alpha = 1.0;
        } else {
            self.contactsView.alpha = 0.5;
        }
        
        [self.secretSwitch setOn:self.space.settings.isSecret];
        [self.secretSwitch setConfirm:!self.space.settings.isSecret];
        
        
        if (([mainViewController numberSpaces:NO] > 1 && !self.space.settings.isSecret) || self.space.settings.isSecret) {
            [self.secretSwitch setEnabled:YES];
            self.secretView.alpha = 1.0;
        } else {
            [self.secretSwitch setEnabled:NO];
            self.secretView.alpha = 0.5;
        }
        
    } else {
        self.navigationController.navigationBarHidden = NO;
        self.avatarView.hidden = YES;
        self.actionView.hidden = YES;
        
        [self setLeftBarButtonItem:[self.showSpaceService getImageWithProfile:self.space.profile]];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.contactsLabel.font = Design.FONT_REGULAR34;
    self.configurationLabel.font = Design.FONT_REGULAR34;
    self.descriptionLabel.font = Design.FONT_REGULAR32;
    self.identityLabel.font = Design.FONT_REGULAR36;
    self.identityTitleLabel.font = Design.FONT_REGULAR32;
    self.secretLabel.font = Design.FONT_REGULAR34;
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.identityLabel.font = Design.FONT_BOLD44;
    self.nameLabel.font = Design.FONT_BOLD44;
    self.twincodeLabel.font = Design.FONT_REGULAR30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.identityAvatarView.layer.borderColor = Design.WHITE_COLOR.CGColor;
    self.contactsView.backgroundColor = Design.WHITE_COLOR;
    self.contactsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.configurationView.backgroundColor = Design.WHITE_COLOR;
    self.configurationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.contactsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.configurationImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.contactsListImageView.tintColor = Design.ACCESSORY_COLOR;
    self.configurationAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.secretLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.secretView.backgroundColor = Design.WHITE_COLOR;
    self.secretImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.textColor = DESIGN_SPACE_NAME_COLOR;
    self.identityLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateCurrentSpace {
    DDLogVerbose(@"%@ updateCurrentSpace", LOG_TAG);
    
    self.space = self.currentSpace;
    [self.showSpaceService getSpace:self.space.uuid];
    
    [self updateColor];
}

@end

