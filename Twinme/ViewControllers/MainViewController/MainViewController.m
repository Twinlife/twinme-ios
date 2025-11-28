/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <UserNotifications/UserNotifications.h>

#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLProxyDescriptor.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLTwinlife.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLInvocation.h>
#import <Twinme/TLPairInviteInvocation.h>

#import <Utils/NSString+Utils.h>

#import "ConversationViewController.h"
#import "AcceptInvitationViewController.h"
#import "AcceptInvitationSubscriptionViewController.h"
#import "ShareViewController.h"
#import "UIGroupConversation.h"
#import "WelcomeViewController.h"
#import "SplashScreenViewController.h"
#import "TabBarViewController.h"
#import "SideMenuViewController.h"
#import <TwinmeCommon/CallViewController.h>
#import "PremiumServicesViewController.h"
#import "FatalErrorViewController.h"
#import "SkredBoardViewController.h"
#import "AddProfileViewController.h"
#import "EditProfileViewController.h"
#import "LockScreenViewController.h"
#import "WhatsNewViewController.h"
#import "InAppSubscriptionViewController.h"
#import "PremiumServicesViewController.h"
#import "SecretSpaceViewController.h"
#import "AccountMigrationViewController.h"
#import "SuccessAuthentifiedRelationView.h"
#import "SettingsAdvancedViewController.h"

#import "MainService.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/CallService.h>
#import <TwinmeCommon/CallState.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "AlertView.h"
#import "SpaceSetting.h"
#import "UIView+Toast.h"
#import "UIColor+Hex.h"
#import "UIViewController+ProgressIndicator.h"
#import "UIProfile.h"
#import "UISpace.h"
#import "UIPremiumFeature.h"
#import "CallFloatingView.h"
#import "InAppPurchaseManager.h"
#import "InfoFloatingView.h"
#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DELAY_WHATS_NEW = .5f;
static CGFloat DELAY_NOTIFICATIONS = 1.f;
static CGFloat MENU_ANIMATION_DURATION = .25f;
static CGFloat OVERLAY_OPACITY = .4f;
static CGFloat DESIGN_SIDE_MENU_WIDTH = 660.0;
static CGFloat DESIGN_CALL_FLOATING_VIEW_SIZE = 180;
static CGFloat DESIGN_INFO_FLOATING_VIEW_SIZE = 120;

static UIColor *DESIGN_PLACEHOLDER_COLOR;
static UIColor *DESIGN_UNSELECTED_COLOR;
static CGFloat DESIGN_TAB_ICON_INSET;
static CGFloat CALL_FLOATING_VIEW_SIZE;
static CGFloat INFO_FLOATING_VIEW_SIZE;

#define DATE_CARD_PATH_COMPONENT @"date.card"

//
// Interface: MainViewController ()
//

@interface MainViewController () <MainServiceDelegate, SplashScreenDelegate, SkredBoardViewControllerDelegate, UIGestureRecognizerDelegate, LockScreenDelegate, InAppPurchaseManagerDelegate, AcceptInvitationSubscriptionDelegate, AlertMessageViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *sideMenuContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *tabBarContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarContainerViewLeadingConstraint;

@property (nonatomic) SideMenuViewController *sideMenuViewController;
@property (nonatomic) TabBarViewController *tabBarViewController;
@property (nonatomic) SplashScreenViewController *splashScreenViewController;
@property (strong, nonatomic) SkredBoardViewController *skredBoardViewController;
@property (nonatomic) LockScreenViewController *lockScreenViewController;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) CallFloatingView *callFloatingView;
@property (nonatomic) InfoFloatingView *infoFloatingView;

@property (nonatomic) BOOL mainServiceInitialized;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL sideMenuOpen;
@property (nonatomic) BOOL showSplashScreen;
@property (nonatomic) BOOL showUpgradeScreen;
@property (nonatomic) BOOL hasPendingNotifications;
@property (nonatomic) BOOL onGetConversationsDone;
@property (nonatomic) BOOL hasConversations;
@property (nonatomic) int nbContacts;
@property (nonatomic) BOOL isProfileNotFound;
@property (nonatomic) BOOL createLevel;
@property (nonatomic) BOOL videoCall;
@property (nonatomic) BOOL doCreateProfileOnWillAppear;
@property (nonatomic) BOOL doSuggestFriendsAfterCreateProfileOnWillAppear;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL isStatusBarDark;
@property (nonatomic) TLConnectionStatus connectionStatus;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;
@property (nonatomic) MainService *mainService;

@property (nonatomic) NSURL *url;
@property (nonatomic, nullable) NSString *proxyToAdd;


@property (nonatomic) NSMutableArray *uiSpaces;

- (void)onMessageTerminateCall:(nonnull CallEventMessage *)message;

- (void)onMessageVideoUpdate:(nonnull NSNotification *)notification;

@end

//
// Implementation: MainViewController
//

#undef LOG_TAG
#define LOG_TAG @"MainViewController"

@implementation MainViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_UNSELECTED_COLOR = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:162./255. green:162./255 blue:162./255 alpha:255./255];
    DESIGN_TAB_ICON_INSET = 6.f;
    CALL_FLOATING_VIEW_SIZE = DESIGN_CALL_FLOATING_VIEW_SIZE * Design.HEIGHT_RATIO;
    INFO_FLOATING_VIEW_SIZE = DESIGN_INFO_FLOATING_VIEW_SIZE * Design.HEIGHT_RATIO;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.mainViewController = self;
        _twinmeApplication = [delegate twinmeApplication];
        _twinmeContext = [delegate twinmeContext];
        _mainService = [[MainService alloc] initWithTwinmeContext:_twinmeContext delegate:self];
        _mainServiceInitialized = NO;
        _visible = NO;
        _isStatusBarDark = NO;
        _needRefresh = NO;
        _showSplashScreen = NO;
        _showUpgradeScreen = NO;
        _hasPendingNotifications = NO;
        _hasConversations = NO;
        _nbContacts = 0;
        _sideMenuOpen = NO;
        _isProfileNotFound = NO;
        _onGetConversationsDone = NO;
        _doCreateProfileOnWillAppear = NO;
        _createLevel = NO;
        _uiSpaces = [[NSMutableArray alloc] init];
        _doSuggestFriendsAfterCreateProfileOnWillAppear = NO;
        _connectionStatus = TLConnectionStatusConnected; // Necessary for onConnectionStatusChange
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UISceneDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UISceneDidActivateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillDeactivateNotification:)
                                                     name:UISceneWillDeactivateNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        
    }
    
    [self initViewsController];
    
    if (!self.showSplashScreen) {
        self.showSplashScreen = YES;
        self.splashScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"];
        self.splashScreenViewController.splashScreenDelegate = self;
        [self.view addSubview:self.splashScreenViewController.view];
    }
    
    if ([InAppPurchaseManager sharedInstance:self]) {
        [[InAppPurchaseManager sharedInstance:self] getProducts];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    if (self.needRefresh) {
        self.needRefresh = NO;
    }
    self.visible = YES;
    
    if (self.splashScreenViewController == nil && ![self.twinmeApplication showWelcomeScreen]) {
        [self askNotification];
    }
    
    if ([self.twinmeApplication showLockScreen] && self.lockScreenViewController) {
        [self.lockScreenViewController.view setHidden:NO];
        [self.lockScreenViewController requestUnlockScreen];
    } else if (self.splashScreenViewController == nil && ![self.twinmeApplication showWelcomeScreen] && [self.twinmeApplication showUpgradeScreen]) {
        self.showUpgradeScreen = YES;
        PremiumServicesViewController *premiumServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
        TwinmeNavigationController *upgradeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:premiumServicesViewController];
        [self presentViewController:upgradeNavigationController animated:NO completion:nil];
    } else if (self.splashScreenViewController == nil && self.space && [self.twinmeApplication showWhatsNew] && !self.showUpgradeScreen) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_WHATS_NEW * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            WhatsNewViewController *whatsNewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewViewController"];
            [whatsNewViewController showInView:self];
        });
    } else if (self.showUpgradeScreen) {
        self.showUpgradeScreen = NO;
    } else if (self.splashScreenViewController == nil && [self.twinmeApplication showEnableNotificationScreen] && self.space.profile) {
        [self showEnableNotificationScreen];
    }
    
    self.visible = YES;

    if (![self.twinmeApplication canShowUpgradeScreenAtStart] && self.space) {
        [self.mainService getConversations];
        [self.mainService getContacts];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    if (self.isStatusBarDark) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        }
    }
    return UIStatusBarStyleLightContent;
}

- (void)updateStatusBarDark {
    DDLogVerbose(@"%@ updateStatusBarDark", LOG_TAG);
    
    if (!self.sideMenuOpen && !self.splashScreenViewController) {
        self.isStatusBarDark = NO;
    } else {
        TLSpaceSettings *spaceSettings;
        if (self.space) {
            spaceSettings = self.space.settings;
            if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
        } else {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        BOOL darkMode = [self.twinmeApplication darkModeEnable:spaceSettings];
        self.isStatusBarDark = !darkMode;
    }
    
    [UIView animateWithDuration:0.3 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {}];
}

- (BOOL)canBecomeFirstResponder {
    DDLogVerbose(@"%@ canBecomeFirstResponder", LOG_TAG);
    
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    self.needRefresh = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    [self.skredBoardViewController setSkredBoardDisplayState:self.skredBoardViewController.skredBoardDisplayState initialVelocity:0 animated:NO];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    DDLogVerbose(@"%@ traitCollectionDidChange: %@", LOG_TAG, previousTraitCollection);
    
    if (self.space) {
        TLSpaceSettings *spaceSettings = self.space.settings;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if ([[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue] == DisplayModeSystem) {
            [Design setupColors:DisplayModeSystem];
        }
    }
    
    [self updateColor];
}

- (BOOL)isInitialized {
    DDLogVerbose(@"%@ isInitialized", LOG_TAG);
    
    return self.mainServiceInitialized;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationDidBecomeActive: %@", LOG_TAG, notification);
    
    if (![self.twinmeApplication showLockScreen] && self.lockScreenViewController) {
        [self.lockScreenViewController.view removeFromSuperview];
        self.lockScreenViewController = nil;
    } else if ([self.twinmeApplication showLockScreen] && self.lockScreenViewController) {
        [self.lockScreenViewController.view setHidden:NO];
        [self.lockScreenViewController requestUnlockScreen];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        TwinmeNavigationController *selectedNavigationController = self.selectedViewController;
        if (selectedNavigationController.viewControllers.count == 1 && self.tabBarViewController.tabBar.hidden) {
            self.tabBarViewController.tabBar.hidden = NO;
        }
    });
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationWillResignActive: %@", LOG_TAG, notification);
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showLockScreen];
    });
}

- (void)applicationWillDeactivateNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationWillDeactivateNotification: %@", LOG_TAG, notification);
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showLockScreen];
    });
}

- (TwinmeNavigationController *)selectedViewController {
    
    return self.tabBarViewController.selectedViewController;
}

- (BOOL)hasCurrentSpaceNotification {
    DDLogVerbose(@"%@ hasCurrentSpaceNotification", LOG_TAG);
    
    return self.hasPendingNotifications;
}

- (void)initCallFloatingViewWithCall:(nonnull CallState *)call {
    DDLogVerbose(@"%@ initCallFloatingViewWithCall: %@", LOG_TAG, call);
    
    if (!self.callFloatingView) {
        self.callFloatingView = [[CallFloatingView alloc]initWithFrame:CGRectMake(0, 0, CALL_FLOATING_VIEW_SIZE, CALL_FLOATING_VIEW_SIZE)];
        self.callFloatingView.backgroundColor = [UIColor clearColor];
        [self.callFloatingView initWithCallParticipant:[call mainParticipant]];
        self.callFloatingView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *callGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCallTapGesture:)];
        [self.callFloatingView addGestureRecognizer:callGestureRecognizer];
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.callFloatingView];
        [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:self.callFloatingView];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onMessageVideoUpdate:) name:CallEventMessageVideoUpdate object:nil];
        [notificationCenter addObserver:self selector:@selector(onMessageTerminateCall:) name:CallEventMessageTerminateCall object:nil];
    }
}

- (void)removeCallFloatingView {
    DDLogVerbose(@"%@ removeCallFloatingView", LOG_TAG);
    
    if (self.callFloatingView) {
        [self.callFloatingView dispose];
        [self.callFloatingView removeFromSuperview];
        self.callFloatingView = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageTerminateCall object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageVideoUpdate object:nil];
    }
}

- (void)initInfoFloatingView {
    DDLogVerbose(@"%@ initInfoFloatingView", LOG_TAG);
    
    if (!self.infoFloatingView) {
        self.infoFloatingView = [[InfoFloatingView alloc]initWithFrame:CGRectMake(0, 0, INFO_FLOATING_VIEW_SIZE, INFO_FLOATING_VIEW_SIZE)];
        self.infoFloatingView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *infoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInfoTapGesture:)];
        [self.infoFloatingView addGestureRecognizer:infoGestureRecognizer];
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.infoFloatingView];
        [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:self.infoFloatingView];
    }
}

- (void)removeInfoFloatingView {
    DDLogVerbose(@"%@ removeInfoFloatingView", LOG_TAG);
    
    if (self.infoFloatingView) {
        [self.infoFloatingView removeFromSuperview];
        self.infoFloatingView = nil;
    }
}

- (void)selectTab:(int)index {
    DDLogVerbose(@"%@ selectTab: %d", LOG_TAG, index);
    
    self.tabBarViewController.selectedIndex = index;
}

- (NSUInteger)getSelectedTab {
    DDLogVerbose(@"%@ getSelectedTab", LOG_TAG);
    
    return self.tabBarViewController.selectedIndex;
}

- (void)refreshTab {
    DDLogVerbose(@"%@ refreshTab", LOG_TAG);
    
    [self.tabBarViewController setSelectedIndex:self.tabBarViewController.selectedIndex];
}

- (void)setCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ setCurrentSpace: %@", LOG_TAG, space);
    
    [self.mainService setCurrentSpace:space];
}

- (void)searchSecretSpace {
    DDLogVerbose(@"%@ searchSecretSpace", LOG_TAG);
    
    SecretSpaceViewController *secretSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SecretSpaceViewController"];
    [secretSpaceViewController showInViewController:self];
}

- (NSUInteger)numberSpaces:(BOOL)countSecretSpace {
    DDLogVerbose(@"%@ countSecretSpace: %@", LOG_TAG, countSecretSpace ? @"YES":@"NO");
    
    if (countSecretSpace) {
        return self.uiSpaces.count;
    }
    
    NSUInteger count = 0;
    for (UISpace *uiSpace in self.uiSpaces) {
        if (!uiSpace.space.settings.isSecret) {
            count++;
        }
    }
    
    return count;
}

- (TLSpace *)getNextDefaultSpace:(TLSpace *)oldDefaultSpace {
    DDLogVerbose(@"%@ getNextDefaultSpace: %@", LOG_TAG, oldDefaultSpace);
    
    for (UISpace *uiSpace in self.uiSpaces) {
        if (!uiSpace.space.settings.isSecret && ![uiSpace.space.uuid isEqual:oldDefaultSpace.uuid]) {
            return uiSpace.space;
        }
    }
    
    return nil;
}

#pragma mark - SplashScreenDelegate

- (void)animationDidFinish:(BOOL)isMigration {
    DDLogVerbose(@"%@ animationDidFinish", LOG_TAG);
    
    self.showSplashScreen = YES;
        
    if ([self.twinmeApplication isRunning]) {
        if (isMigration) {
            AccountMigrationViewController *accountMigrationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationViewController"];
            accountMigrationViewController.startFromSplashScreen = YES;
            TwinmeNavigationController *migrationNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:accountMigrationViewController];
            [self presentViewController:migrationNavigationController animated:NO completion:^{
                [self.splashScreenViewController.view removeFromSuperview];
                self.splashScreenViewController = nil;
            }];
            return;
        } else if ([self.twinmeApplication showLockScreen] && !self.lockScreenViewController) {
            self.lockScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LockScreenViewController"];
            self.lockScreenViewController.lockScreenDelegate = self;
            if (self.presentedViewController) {
                [self.presentedViewController.view addSubview:self.lockScreenViewController.view];
            } else {
                [self.view addSubview:self.lockScreenViewController.view];
            }
            [self.lockScreenViewController requestUnlockScreen];
        } else if ([self.twinmeApplication showWelcomeScreen]) {
            WelcomeViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
            TwinmeNavigationController *welcomeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:welcomeViewController];
            [self presentViewController:welcomeNavigationController animated:NO completion:^{
                [self.splashScreenViewController.view removeFromSuperview];
                self.splashScreenViewController = nil;
            }];
            return;
        } else {
            [self askNotification];
        }
        
        if ([self.twinmeApplication showUpgradeScreen]) {
            self.showUpgradeScreen = YES;
            PremiumServicesViewController *premiumServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
            TwinmeNavigationController *upgradeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:premiumServicesViewController];
            [self presentViewController:upgradeNavigationController animated:NO completion:^{
                [self.splashScreenViewController.view removeFromSuperview];
                self.splashScreenViewController = nil;
            }];
            return;
        } else if (self.space && [self.twinmeApplication showWhatsNew]) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_WHATS_NEW * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                WhatsNewViewController *whatsNewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewViewController"];
                [whatsNewViewController showInView:self];
            });
        } else if ([self.twinmeApplication showEnableNotificationScreen] && self.space.profile) {
            [self showEnableNotificationScreen];
        }
        
        [self.splashScreenViewController.view removeFromSuperview];
        self.splashScreenViewController = nil;
    }
}

#pragma mark - LockScreenDelegate

- (void)unlockScreenSuccess {
    DDLogVerbose(@"%@ unlockScreenSuccess", LOG_TAG);
    
    if (self.lockScreenViewController) {
        if ([self.twinmeApplication showWelcomeScreen]) {
            WelcomeViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
            TwinmeNavigationController *welcomeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:welcomeViewController];
            [self presentViewController:welcomeNavigationController animated:NO completion:^{
                [self.lockScreenViewController.view removeFromSuperview];
                self.lockScreenViewController = nil;
            }];
            return;
        }
        [self.lockScreenViewController.view removeFromSuperview];
        self.lockScreenViewController = nil;
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.proxyToAdd) {
            [self addProxy];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
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
    
    if (self.proxyToAdd) {
        self.proxyToAdd = nil;
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
}

#pragma mark - MainServiceDelegate

- (void)showProgressIndicator {
    DDLogVerbose(@"%@ showProgressIndicator", LOG_TAG);
}

- (void)hideProgressIndicator {
    DDLogVerbose(@"%@ hideProgressIndicator", LOG_TAG);
    
    self.mainServiceInitialized = YES;
    
    if (self.shareContentURL) {
        [self handleShareContentURL];
    }
}

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ onConnectionStatusChange: %d", LOG_TAG, connectionStatus);
    
    if (connectionStatus == TLConnectionStatusConnected) {
        self.connectionStatus = connectionStatus;
        if ([self.twinmeApplication showConnectedMessage]) {
            [self.twinmeApplication setShowConnectedMessage:NO];
            [self initInfoFloatingView];
            [self.infoFloatingView setConnectionStatus:self.twinmeContext.connectionStatus];
        }
    } else {
        
        // The onConnectionStatusChange() can be called several times and we don't want to accumulate
        // many disconnection toasts.  If it was reported in the past, don't post it again until
        // we are connected again.
        if (self.connectionStatus == connectionStatus) {
            return;
        }
        self.connectionStatus = connectionStatus;
        
        [self.twinmeApplication setShowConnectedMessage:YES];
        [self initInfoFloatingView];
        [self.infoFloatingView setConnectionStatus:connectionStatus];
    }
}

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    BOOL isDefaultSpace = [self.twinmeContext isDefaultSpace:space];

    NSString *lastLevelName = @"";
    if (self.space) {
        lastLevelName = self.space.settings.name;
    }
    
    self.space = space;
    self.profile = space.profile;
    self.isProfileNotFound = NO;
    
    for (UISpace *uiSpace in self.uiSpaces) {
        if ([uiSpace.space.uuid isEqual:space.uuid]) {
            [uiSpace setIsCurrentSpace:YES];
        } else {
            [uiSpace setIsCurrentSpace:NO];
        }
    }
    
    TwinmeNavigationController *twinmeNavigationController = [self selectedViewController];
    [twinmeNavigationController setNavigationBarStyle];
    
    if ([twinmeNavigationController.topViewController isKindOfClass:[AbstractTwinmeViewController class]] ) {
        AbstractTwinmeViewController *viewController = (AbstractTwinmeViewController *) twinmeNavigationController.topViewController;
        [viewController updateFont];
        [viewController updateColor];
    }
    
    if (self.space) {
        TLSpaceSettings *spaceSettings = self.space.settings;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        [Design setupColors:[[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue]];
        
        [self.sideMenuViewController setSpace:[self createUISpaceWithSpace:self.space]];
    }
    
    if (!self.space.profile && !isDefaultSpace && self.createLevel) {
        self.createLevel = NO;
       AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
       addProfileViewController.lastLevelName = lastLevelName;
       [twinmeNavigationController pushViewController:addProfileViewController animated:YES];
    }
    
    [self.sideMenuViewController setUISpaces:self.uiSpaces];
    [self.sideMenuViewController reloadMenu];
    [self.tabBarViewController setCurrentSpace];
    
    if (self.url) {
        NSURL *url = self.url;
        self.url = nil;
        [self handleOpenURL:url];
    }
    
    [self.tabBarViewController updateColor];
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
    [self updateUISpace:space];
    [self.sideMenuViewController setUISpaces:self.uiSpaces];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    if ([space.uuid isEqual:self.space.uuid]) {
        self.space = space;
        
        if (self.space) {
            TLSpaceSettings *spaceSettings = self.space.settings;
            if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
            
            [Design setupColors:[[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue]];

            [self.sideMenuViewController setSpace:[self createUISpaceWithSpace:self.space]];
        }
        
        [self.tabBarViewController updateColor];
    }
    
    [self updateUISpace:space];
    [self.sideMenuViewController setUISpaces:self.uiSpaces];
}

- (void)onDeleteSpace:(NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
    
    for (UISpace *lUISpace in self.uiSpaces) {
        if ([lUISpace.space.uuid isEqual:spaceId]) {
            [self.uiSpaces removeObject:lUISpace];
            break;
        }
    }
    
    [self.sideMenuViewController setUISpaces:self.uiSpaces];
}

- (void)onGetSpaces:(NSArray *)spaces {
    DDLogVerbose(@"%@ onGetSpaces: %@", LOG_TAG, spaces);
    
    [self.uiSpaces removeAllObjects];
    
    for (TLSpace *space in spaces) {
        [self updateUISpace:space];
    }
    
    [self.sideMenuViewController setUISpaces:self.uiSpaces];
    [self.tabBarViewController updateSpace];
}

- (void)onUpdateDefaultProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateDefaultProfile: %@", LOG_TAG, profile);
    
    TLSpace *space = profile.space;
    if ([space.uuid isEqual:self.space.uuid]) {
        self.space = space;
        self.profile = profile;
        [self.sideMenuViewController setSpace:[self createUISpaceWithSpace:self.space]];
        [self.sideMenuViewController reloadMenu];
    }
    
    [self updateUISpace:space];
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
    
    self.isProfileNotFound = YES;
    [self.twinmeApplication setFirstInstallation];
    
    if (self.url) {
        NSURL *url = self.url;
        self.url = nil;
        [self handleOpenURL:url];
    }
}

- (void)onGetTransfertCall:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetTransfertCall: %@", LOG_TAG, callReceiver);
    
    [self.sideMenuViewController setTransferCall:callReceiver];
}

- (void)onCreateTransfertCall:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateTransfertCall: %@", LOG_TAG, callReceiver);
    
    [self.sideMenuViewController setTransferCall:callReceiver];
}

- (void)onUpdateTransfertCall:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateTransfertCall: %@", LOG_TAG, callReceiver);
    
    [self.sideMenuViewController setTransferCall:callReceiver];
}

- (void)onDeleteTransfertCall:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteTransfertCall: %@", LOG_TAG, callReceiverId);
    
    [self.sideMenuViewController deleteTransferCall:callReceiverId];
}

- (void)onGetSpacesNotifications:(NSDictionary<NSUUID *, TLNotificationServiceNotificationStat *> *)spacesNotifications {
    DDLogVerbose(@"%@ onGetSpacesNotifications: %@", LOG_TAG, spacesNotifications);
    
    for (UISpace *uiSpace in self.uiSpaces) {
        TLNotificationServiceNotificationStat *stat = spacesNotifications[uiSpace.space.uuid];
        uiSpace.hasNotification = stat != nil && stat.pendingCount > 0;
    }
    
    [self.sideMenuViewController reloadMenu];
}

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@  onUpdatePendingNotifications: %@", LOG_TAG, hasPendingNotifications ? @"YES" : @"NO");
    
    self.hasPendingNotifications = hasPendingNotifications;
    [self.tabBarViewController updateNotifications:self.hasPendingNotifications];
}

- (void)onGetConversations:(BOOL)hasConversations {
    DDLogVerbose(@"%@  onGetConversations: %@", LOG_TAG, hasConversations ? @"YES" : @"NO");
    
    self.hasConversations = hasConversations;
    
    if (!self.onGetConversationsDone && hasConversations) {
        self.tabBarViewController.selectedIndex = self.twinmeApplication.defaultTab;
        self.onGetConversationsDone = YES;
    }
        
    [self canShowUpgradeScreen];
}

- (void)onGetContacts:(int)nbContacts {
    DDLogVerbose(@"%@  onGetContacts: %d", LOG_TAG, nbContacts);
    
    self.nbContacts = nbContacts;
    
    [self canShowUpgradeScreen];
}

- (void)canShowUpgradeScreen {
    DDLogVerbose(@"%@  canShowUpgradeScreen", LOG_TAG);
    
    if (self.hasConversations && self.nbContacts > 1) {
        [self.twinmeApplication setCanShowUpgradeScreenWithState:YES];
    }
}

- (void)onOpenURL:(NSURL *)url {
    DDLogVerbose(@"%@ onOpenURL: %@", LOG_TAG, url);
    
    if (self.profile || self.isProfileNotFound) {
        [self handleOpenURL:url];
    } else {
        self.url = url;
    }
}

- (void)onFatalError:(TLBaseServiceErrorCode)errorCode databaseError:(nullable NSError *)databaseError {
    DDLogVerbose(@"%@ onFatalError: %d databaseError: %@", LOG_TAG, errorCode, databaseError);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    FatalErrorViewController *fatalErrorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FatalErrorViewController"];
    [fatalErrorViewController initWithErrorCode:errorCode databaseError:databaseError];
    delegate.window.rootViewController = fatalErrorViewController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DDLogVerbose(@"%@ prepareForSegue segue: %@", LOG_TAG, segue);
    
    if ([segue.identifier isEqualToString:@"TabBarViewControllerSegue"]) {
        self.tabBarViewController = [segue destinationViewController];
    } else if ([segue.identifier isEqualToString:@"SideMenuViewControllerSegue"]) {
        self.sideMenuViewController = [segue destinationViewController];
    }
}

- (void)openSideMenu:(BOOL)animated {
    DDLogVerbose(@"%@ openSideMenu", LOG_TAG);
    
    if (self.sideMenuOpen) {
        self.sideMenuOpen = NO;
        if (animated) {
            [UIView animateWithDuration:MENU_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.sideMenuContainerViewLeadingConstraint.constant = -self.sideMenuContainerViewWidthConstraint.constant;
                self.tabBarContainerViewLeadingConstraint.constant = 0;
                self.overlayView.alpha = 0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.overlayView.hidden = YES;
                [self.sideMenuViewController resetContentOffset];
                [self updateStatusBarDark];
            }];
        } else {
            self.sideMenuContainerViewLeadingConstraint.constant = -self.sideMenuContainerViewWidthConstraint.constant;
            self.tabBarContainerViewLeadingConstraint.constant = 0;
            self.overlayView.alpha = 0;
            self.overlayView.hidden = YES;
            [self.sideMenuViewController resetContentOffset];
            [self updateStatusBarDark];
        }
    } else {
        self.sideMenuOpen = YES;
        self.overlayView.hidden = NO;
        [self.tabBarContainerView bringSubviewToFront:self.overlayView];
        if (animated) {
            [UIView animateWithDuration:MENU_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.sideMenuContainerViewLeadingConstraint.constant = 0;
                self.tabBarContainerViewLeadingConstraint.constant = self.sideMenuContainerViewWidthConstraint.constant;
                self.overlayView.alpha = OVERLAY_OPACITY;
                [self.view layoutIfNeeded];
                [self.sideMenuViewController reloadMenu];
                [self.sideMenuViewController openSideMenu];
                [self updateStatusBarDark];
            } completion:nil];
        } else {
            self.sideMenuContainerViewLeadingConstraint.constant = 0;
            self.tabBarContainerViewLeadingConstraint.constant = self.sideMenuContainerViewWidthConstraint.constant;
            self.overlayView.alpha = OVERLAY_OPACITY;
            [self.view layoutIfNeeded];
            [self.sideMenuViewController reloadMenu];
            [self.sideMenuViewController openSideMenu];
            [self updateStatusBarDark];
        }
    }
}

- (void)closeSideMenu:(BOOL)animated {
    DDLogVerbose(@"%@ closeSideMenu", LOG_TAG);
    
    if (self.sideMenuOpen) {
        self.sideMenuOpen = NO;
        if (animated) {
            [UIView animateWithDuration:MENU_ANIMATION_DURATION delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
                self.sideMenuContainerViewLeadingConstraint.constant = -self.sideMenuContainerViewWidthConstraint.constant;
                self.tabBarContainerViewLeadingConstraint.constant = 0;
                self.overlayView.alpha = 0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.overlayView.hidden = YES;
                [self.sideMenuViewController resetContentOffset];
                [self updateStatusBarDark];
            }];
        } else {
            self.sideMenuContainerViewLeadingConstraint.constant = -self.sideMenuContainerViewWidthConstraint.constant;
            self.tabBarContainerViewLeadingConstraint.constant = 0;
            self.overlayView.alpha = 0;
            self.overlayView.hidden = YES;
            [self.sideMenuViewController resetContentOffset];
            [self updateStatusBarDark];
        }
    }
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
        if (space.avatarId) {
            [self.mainService getImageWithSpace:space withBlock:^(UIImage *image) {
                uiSpace.avatarSpace = image;
                [self.sideMenuViewController refreshTable];
            }];
        }
        if (self.space.profile) {
            [self.mainService getImageWithProfile:space.profile withBlock:^(UIImage *image) {
                uiSpace.avatar = image;
                [self.sideMenuViewController refreshTable];
            }];
        }
    } else {
        uiSpace = [self createUISpaceWithSpace:space];
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
    
    if (self.space && [self.space.uuid isEqual:space.uuid]) {
        uiSpace.isCurrentSpace = YES;
    } else {
        uiSpace.isCurrentSpace = NO;
    }
    
    if (!added) {
        [self.uiSpaces addObject:uiSpace];
    }
}

- (void)onSubscribeSuccess {
    DDLogVerbose(@"%@ onSubscribeSuccess", LOG_TAG);
    
}

- (void)onSubscribeFailed:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onSubscribeFailed errorCode: %d", LOG_TAG, errorCode);
    
}

#pragma mark - InAppPurchaseManagerDelegate

- (void)onGetProducts:(NSArray *)products {
    DDLogVerbose(@"%@ onGetProducts: %@", LOG_TAG, products);
    
}

- (void)onTransactionSuccess:(SKPaymentTransaction *)transaction receipt:(NSString *)receipt {
    DDLogVerbose(@"%@ onTransactionSuccess: %@ receipt: %@", LOG_TAG, transaction, receipt);
    
    UIViewController *topViewController = [UIViewController topViewController];
    
    if (![topViewController isKindOfClass:[InAppSubscriptionViewController class]]) {
        [self.mainService subscribeFeature:transaction.payment.productIdentifier purchaseToken:receipt purchaseOrderId:transaction.transactionIdentifier];
    }
    
}

- (void)onTransactionRestored {
    DDLogVerbose(@"%@ onTransactionRestored", LOG_TAG);
    
}

- (void)onTransactionFailed:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ onTransactionFailed: %@", LOG_TAG, transaction);
    
}

#pragma mark - CallServiceMessages

- (void)onMessageTerminateCall:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageTerminateCall: %@", LOG_TAG, notification);
    
    [self.callFloatingView dispose];
    [self.callFloatingView removeFromSuperview];
    self.callFloatingView = nil;
    
    UIViewController *topViewController = [UIViewController topViewController];
    if ([topViewController isKindOfClass:[AbstractTwinmeViewController class]]) {
        AbstractTwinmeViewController *viewController = (AbstractTwinmeViewController *)topViewController;
        [viewController updateInCall];
    } else if ([topViewController isKindOfClass:[ConversationViewController class]]) {
        ConversationViewController *viewController = (ConversationViewController *)topViewController;
        [viewController updateInCall];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageTerminateCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageVideoUpdate object:nil];
}

- (void)onMessageVideoUpdate:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageVideoUpdate: %@", LOG_TAG, notification);
    
}

#pragma mark - SkredBoardViewControllerDelegate

- (void)dismissSkredBoardViewController:(SkredBoardViewController *)skredBoardViewController {
    DDLogVerbose(@"%@ dismissSkredBoardViewController: %@", LOG_TAG, skredBoardViewController);
    
    [skredBoardViewController setSkredBoardDisplayState:SkredBoardDisplayStateClose initialVelocity:0 animated:YES];
}

- (void)skredBoardViewController:(SkredBoardViewController *)skredBoardViewController didValidateCode:(NSString *)code onMode:(SkredBoardMode)mode {
    DDLogVerbose(@"%@ SkredBoardViewController did validate code %@ on %@", LOG_TAG, code, mode == SkredBoardModeCreateAccount ? @"create mode" : @"access mode");
    
    switch (mode) {
        case SkredBoardModeAccessAccount:
            [self.mainService setLevelWithName:code];
            break;
            
        case SkredBoardModeCreateAccount:
            self.createLevel = YES;
            [self.mainService createLevelWithName:code];
            break;
            
        case SkredBoardModeDeleteAccount:
            [self.mainService deleteLevelWithName:code];
            break;
        default:
            break;
    }
    
    [skredBoardViewController setSkredBoardDisplayState:SkredBoardDisplayStateClose initialVelocity:0 animated:YES];
}

#pragma mark - AcceptInvitationSubscriptionDelegate Methods

- (void)invitationSubscriptionDidFinish:(TLBaseServiceErrorCode)errorCode  {
    DDLogVerbose(@"%@ invitationDidFinish: %u", LOG_TAG, errorCode);

    if (errorCode != TLBaseServiceErrorCodeSuccess) {
        NSString *errorMessage;
        if (errorCode == TLBaseServiceErrorCodeExpired) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_expired_code", nil);
        } else if (errorCode == TLBaseServiceErrorCodeLimitReached) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_used_code", nil);
        } else {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_invalid_code", nil);
        }
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:errorMessage];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)invitationSubscriptionDidCancel {
    DDLogVerbose(@"%@ invitationSubscriptionDidCancel", LOG_TAG);
    
}

#pragma mark - Private methods

- (void)initViewsController {
    DDLogVerbose(@"%@ initViewsController", LOG_TAG);
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: Design.FONT_BOLD20} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:Design.FONT_COLOR_DEFAULT];
    
    NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName: DESIGN_PLACEHOLDER_COLOR};
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_search_hint", nil) attributes:placeholderAttributes];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setAttributedPlaceholder:attributedPlaceholder];
    
    self.sideMenuContainerViewWidthConstraint.constant = DESIGN_SIDE_MENU_WIDTH * Design.WIDTH_RATIO;
    self.sideMenuContainerViewLeadingConstraint.constant = - DESIGN_SIDE_MENU_WIDTH * Design.WIDTH_RATIO;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    self.overlayView.hidden = YES;
    self.overlayView.userInteractionEnabled = YES;
    [self.tabBarContainerView addSubview:self.overlayView];
    
    UITapGestureRecognizer *overlayTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTapGesture:)];
    [self.overlayView addGestureRecognizer:overlayTapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipeGestureRecognizer.cancelsTouchesInView = NO;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    } else {
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    }
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    UISwipeGestureRecognizer *panGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGesture.delegate = self;
    panGesture.cancelsTouchesInView = NO;
    panGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:panGesture];
    
    self.skredBoardViewController = [[SkredBoardViewController alloc] initWithNibName:@"SkredBoardViewController" bundle:[NSBundle mainBundle]];
    self.skredBoardViewController.delegate = self;
    
    [self.skredBoardViewController addToViewControllerWithoutStickGesture:self];
    [self.view bringSubviewToFront:self.skredBoardViewController.view];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ swipeHandler: %@", LOG_TAG, recognizer);
    
    if (self.sideMenuOpen) {
        [self closeSideMenu:YES];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:    (UITouch *)touch {
    
    return YES;
}

- (void)handlePanGestureRecognizer:(UISwipeGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handlePanGestureRecognizer: %@", LOG_TAG, recognizer);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        TwinmeNavigationController *twinmeNavigationController = self.tabBarViewController.selectedViewController;
        if (twinmeNavigationController.viewControllers.count == 1) {
            [self.skredBoardViewController setSkredBoardDisplayState:SkredBoardDisplayStateOpen initialVelocity:1 animated:YES];
        }
    }
}

- (void)handleOpenURL:(NSURL *)url {
    DDLogVerbose(@"%@ handleOpenURL: %@", LOG_TAG, url);
    
    // Special action triggered by the ShareExtension to redirect and display the conversation.
    if (url && [CONVERSATION_ACTION isEqualToString:url.host]) {
        // Defer opening the shared URL until the main view is fully initialized.
        if (!self.isInitialized) {
            self.shareContentURL = url;
            return;
        }
        [self handleExtensionShareContentURL:url];
    } else if (url) {
        [self.mainService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
            if (errorCode != TLBaseServiceErrorCodeSuccess) {
                [self incorrectQRCode:errorCode];
                return;
            }
            [self didCaptureUrl:url twincodeUri:uri];
        }];
    }
}

- (void)handleShareContentURL {
    DDLogVerbose(@"%@ handleShareContentURL", LOG_TAG);
    
    if (self.shareContentURL) {
        NSURL *shareContentURL = self.shareContentURL;
        self.shareContentURL = nil;
        
        if (shareContentURL && [CONVERSATION_ACTION isEqualToString:shareContentURL.host]) {
            [self handleExtensionShareContentURL:shareContentURL];
        } else {
            ShareViewController *shareViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
            shareViewController.fileURL = shareContentURL;
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:shareViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

- (BOOL)handleExtensionShareContentURL:(NSURL *)url {
    DDLogVerbose(@"%@ handleExtensionShareContentURL %@", LOG_TAG, url);
    
    NSArray *queryItems = [[[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:false] queryItems];
    NSString *value = nil;
    BOOL isGroup = NO;
    for (NSURLQueryItem *queryItem in queryItems) {
        if ([queryItem.name isEqualToString:@"contact"]) {
            value = queryItem.value;
            break;
        }
        if ([queryItem.name isEqualToString:@"group"]) {
            value = queryItem.value;
            isGroup = YES;
            break;
        }
    }
    if (!value) {
        return NO;
    }
    NSUUID *contactId = [[NSUUID alloc] initWithUUIDString:value];
    if (!contactId) {
        return NO;
    }
    
    UIViewController *topViewController = [UIViewController topViewController];
    if ([topViewController isKindOfClass:[ConversationViewController class]]) {
        ConversationViewController *viewController = (ConversationViewController *)topViewController;
        id<TLOriginator> originator = [viewController getOriginator];
        if ([originator.uuid isEqual:contactId]) {
            return NO;
        }
    }
    
    if (isGroup) {
        [self.twinmeContext getGroupWithGroupId:contactId withBlock:^(TLBaseServiceErrorCode errorCode, TLGroup *group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                TwinmeNavigationController *selectedNavigationController = self.selectedViewController;
                ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
                
                [conversationViewController initWithContact:group];
                [selectedNavigationController pushViewController:conversationViewController animated:YES];
            });
        }];
    } else {
        [self.twinmeContext getContactWithContactId:contactId withBlock:^(TLBaseServiceErrorCode errorCode, TLContact * contact) {
            dispatch_async(dispatch_get_main_queue(), ^{
                TwinmeNavigationController *selectedNavigationController = self.selectedViewController;
                ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
                
                [conversationViewController initWithContact:contact];
                [selectedNavigationController pushViewController:conversationViewController animated:YES];
            });
        }];
    }
    
    return YES;
}

- (void)incorrectQRCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
    
    NSString *message;
    
    switch (errorCode) {
        case TLBaseServiceErrorCodeBadRequest:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_incorect_link", nil);
            break;
            
        case TLBaseServiceErrorCodeFeatureNotImplemented:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_not_managed_link", nil);
            break;
            
        case TLBaseServiceErrorCodeItemNotFound:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_corrupt_link", nil);
            break;
            
        default:
            message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
            break;
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)didCaptureUrl:(nonnull NSURL *)url twincodeUri:(nonnull TLTwincodeURI *)twincodeUri {
    DDLogVerbose(@"%@ didCaptureUrl: %@ twincodeUri: %@", LOG_TAG, url, twincodeUri);
    
    [self dismissModalViewController];
    
    if (twincodeUri.kind == TLTwincodeURIKindInvitation) {
        
        if (twincodeUri.twincodeOptions) {
            AcceptInvitationSubscriptionViewController *acceptInvitationSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationSubscriptionViewController"];
            acceptInvitationSubscriptionViewController.acceptInvitationSubscriptionDelegate = self;
            [acceptInvitationSubscriptionViewController initWithPeerTwincodeOutboundId:twincodeUri.twincodeId activationCode:twincodeUri.twincodeOptions];
            [acceptInvitationSubscriptionViewController showInView:self.view];
        } else {
            AcceptInvitationViewController *acceptInvitationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
            [acceptInvitationViewController initWithProfile:self.profile url:url descriptorId:nil originatorId:nil isGroup:NO notification:nil popToRootViewController:NO];
            [acceptInvitationViewController showInView:self.view];
        }
    } else if (twincodeUri.kind == TLTwincodeURIKindAuthenticate) {
        [self.mainService verifyAuthenticateWithURI:url withBlock:^(TLBaseServiceErrorCode errorCode, TLContact *contact) {
            if (errorCode == TLBaseServiceErrorCodeSuccess) {
                [self.mainService getImageWithContact:contact withBlock:^(UIImage *image) {
                    SuccessAuthentifiedRelationView *successAuthentifiedRelationView = [[SuccessAuthentifiedRelationView alloc] init];
                    successAuthentifiedRelationView.confirmViewDelegate = self;
                    [successAuthentifiedRelationView initWithTitle:contact.name message:[NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_certified_message", nil), contact.name] avatar:image icon:nil];
                    [self.view addSubview:successAuthentifiedRelationView];
                    [successAuthentifiedRelationView showConfirmView];
                }];
            } else {
                [self incorrectQRCode:TLBaseServiceErrorCodeBadRequest];
            }
        }];
    } else if (twincodeUri.kind == TLTwincodeURIKindProxy) {
        [self showProxy:twincodeUri.twincodeOptions];
    } else {
        NSString *message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
        
        switch (twincodeUri.kind) {
            case TLTwincodeURIKindCall:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_call_link", nil);
                break;
                
            case TLTwincodeURIKindAccountMigration:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_migration_link", nil);
                break;
                
            case TLTwincodeURIKindTransfer:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_transfer_link", nil);
                break;
                
            default:
                break;
        }
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)handleOverlayTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleOverlayTapGesture", LOG_TAG);
    
    [self openSideMenu:YES];
}

- (void)handleCallTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCallTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.callFloatingView dispose];
        [self.callFloatingView removeFromSuperview];
        self.callFloatingView = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageTerminateCall object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageVideoUpdate object:nil];
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        CallState *call = [delegate.callService currentCall];
        if (!call) {
            return;
        }

        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController initCallWithOriginator:call.originator isVideoCall:[call isVideo]];
        [self.selectedViewController pushViewController:callViewController animated:YES];
    }
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.infoFloatingView tapAction];
    }
}

- (void)showEnableNotificationScreen {
    DDLogVerbose(@"%@ showEnableNotificationScreen", LOG_TAG);
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL notificatonEnable;
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                notificatonEnable = YES;
            } else {
                notificatonEnable = NO;
            }
            
            if (!notificatonEnable) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_NOTIFICATIONS * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
                    defaultConfirmView.confirmViewDelegate = self;
                    
                    TLSpaceSettings *spaceSettings;
                    if (self.space) {
                        spaceSettings = self.space.settings;
                        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                            spaceSettings = self.twinmeContext.defaultSpaceSettings;
                        }
                    } else {
                        spaceSettings = self.twinmeContext.defaultSpaceSettings;
                    }
                    
                    UIImage *image = [self.twinmeApplication darkModeEnable:spaceSettings] ? [UIImage imageNamed:@"EnableNotificationDark"] : [UIImage imageNamed:@"EnableNotification"];
                    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"quality_of_services_view_controller_settings", nil) message:TwinmeLocalizedString(@"quality_of_services_view_controller_enable_notifications_warning", nil) image:image avatar:nil action:TwinmeLocalizedString(@"quality_of_services_view_controller_enable_notifications", nil) actionColor:nil cancel:nil];

                    [self.view addSubview:defaultConfirmView];
                    
                    [defaultConfirmView showConfirmView];
                });
            }
        });
    }];
}

- (void)showLockScreen {
    DDLogVerbose(@"%@ showLockScreen", LOG_TAG);
        
    if (([self.twinmeApplication isScreenLock] || self.twinmeApplication.isLastScreenHidden) && !self.lockScreenViewController && [[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
        [self.twinmeApplication setResignActiveDateWithDate:[NSDate date]];
        
        self.lockScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LockScreenViewController"];
        self.lockScreenViewController.lockScreenDelegate = self;
        
        [self.lockScreenViewController.view setHidden:!self.twinmeApplication.isLastScreenHidden];
        
        
        
        if (self.presentedViewController) {
            UIViewController *topViewController = [UIViewController topViewController];
            if ([topViewController isKindOfClass:[AbstractTwinmeViewController class]]) {
                [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
                    [self.view addSubview:self.lockScreenViewController.view];
                }];
            } else {
                [self.view addSubview:self.lockScreenViewController.view];
            }
        } else {
            [self.view addSubview:self.lockScreenViewController.view];
        }
    }
}
    
- (void)dismissModalViewController {
    DDLogVerbose(@"%@ dismissModalViewController", LOG_TAG);
    
    if ([self.twinmeApplication showWelcomeScreen]) {
        return;
    }
    
    UIViewController *topViewController = [UIViewController topViewController];
    if (topViewController.presentingViewController) {
        [topViewController dismissViewControllerAnimated:NO completion:^{
        }];
    } else if (topViewController.presentedViewController) {
        [topViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
        }];
    }
}

- (void)showProxy:(NSString *)proxy {
    DDLogVerbose(@"%@ showProxy: %@", LOG_TAG, proxy);
    
    NSMutableArray *proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    
    if (proxies.count  >= [TLConnectivityService MAX_PROXIES]) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_limit", nil), [TLConnectivityService MAX_PROXIES]]];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    }
        
    for (TLProxyDescriptor *proxyDescriptor in proxies) {
        if ([proxyDescriptor.description caseInsensitiveCompare:proxy] == NSOrderedSame) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_already_use", nil), [TLConnectivityService MAX_PROXIES]]];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        }
    }
    
    self.proxyToAdd = proxy;
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;

    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"proxy_view_controller_title", nil) message:TwinmeLocalizedString(@"proxy_view_controller_url", nil) image:[UIImage imageNamed:@"OnboardingProxy"] avatar:nil action: TwinmeLocalizedString(@"proxy_view_controller_enable", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];

    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"proxy_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.proxyToAdd attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    [defaultConfirmView updateTitle:attributedTitle];
    
    [self.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)addProxy {
    DDLogVerbose(@"%@ addProxy", LOG_TAG);
    
    if (!self.proxyToAdd) {
        return;
    }
    
    NSMutableArray *proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    TLSNIProxyDescriptor *proxy = [TLSNIProxyDescriptor createWithProxyDescription:self.proxyToAdd];
    [proxies addObject:proxy];
    [[self.twinmeContext getConnectivityService] saveWithUserProxies:proxies];
    
    SettingsAdvancedViewController *settingsAdvancedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsAdvancedViewController"];
    [self.navigationController pushViewController:settingsAdvancedViewController animated:YES];
}

- (void)askNotification {
    DDLogVerbose(@"%@ askNotification", LOG_TAG);
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate registerNotification:[UIApplication sharedApplication]];
            });
        }
    }];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.tabBarViewController updateColor];
    [self.sideMenuViewController reloadMenu];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:Design.FONT_COLOR_DEFAULT];
}

- (nonnull UISpace *)createUISpaceWithSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ createUISpaceWithSpace: %@", LOG_TAG, space);

    UISpace *uiSpace = [[UISpace alloc] initWithSpace:space defaultSpaceSettings:self.twinmeContext.defaultSpaceSettings];
    if (space.avatarId) {
        [self.mainService getImageWithSpace:space withBlock:^(UIImage *image) {
            uiSpace.avatarSpace = image;
            [self.sideMenuViewController refreshTable];
        }];
    }
    if (space.profile) {
        [self.mainService getImageWithProfile:space.profile withBlock:^(UIImage *image) {
            uiSpace.avatar = image;
            [self.sideMenuViewController refreshTable];
        }];
    }
    return uiSpace;
}

@end
