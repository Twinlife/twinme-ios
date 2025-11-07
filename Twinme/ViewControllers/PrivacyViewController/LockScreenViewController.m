/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "LockScreenViewController.h"

#import <TwinmeCommon/Design.h>
#import "AlertMessageView.h"
#import "UIView+Toast.h"
#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: LockScreenViewController ()
//

@interface LockScreenViewController () <AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *splashScreenLogoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenLogoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenTwinmeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlockScreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlockScreenViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlockScreenViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *unlockScreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlockScreenLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *unlockScreenLabel;

@property (nonatomic) BOOL firstRequestUnlockScreenDone;
@property (nonatomic) BOOL canRequestUnlock;

@end

//
// Implementation: LockScreenViewController
//

#undef LOG_TAG
#define LOG_TAG @"LockScreenViewController"

@implementation LockScreenViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    self.firstRequestUnlockScreenDone = NO;
    self.canRequestUnlock = NO;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.canRequestUnlock = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);

    [super viewWillDisappear:animated];

    self.canRequestUnlock = NO;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DDLogVerbose(@"%@ applicationDidEnterBackground: %@", LOG_TAG, notification);
    
    self.firstRequestUnlockScreenDone = NO;
}

- (void)requestUnlockScreen {
    DDLogVerbose(@"%@ requestUnlockScreen", LOG_TAG);
    
    if (!self.firstRequestUnlockScreenDone && [self.twinmeApplication showLockScreen] && self.canRequestUnlock) {
        self.firstRequestUnlockScreenDone = YES;
        [self unlockScreen];
    } else if (!self.canRequestUnlock) {
        self.unlockScreenView.hidden = NO;
    }
}

- (void)unlockScreen {
    DDLogVerbose(@"%@ unlockScreen", LOG_TAG);
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:TwinmeLocalizedString(@"lock_screen_view_controller_local_authentication", nil) reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success && [self.lockScreenDelegate respondsToSelector:@selector(unlockScreenSuccess)]) {
                    [self.lockScreenDelegate unlockScreenSuccess];
                } else {
                    switch ([error code]) {
                        case kLAErrorAuthenticationFailed:
                            break;
                            
                        case kLAErrorUserCancel:
                            break;
                            
                        case kLAErrorUserFallback:
                            break;
                            
                        case kLAErrorTouchIDNotEnrolled:
                            break;
                            
                        case kLAErrorPasscodeNotSet:
                            break;
                            
                        default:
                            break;
                    }
                    self.unlockScreenView.hidden = NO;
                }
            });
        }];
    } else {
        self.unlockScreenView.hidden = NO;
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"lock_screen_view_controller_passcode_not_set", nil)];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.splashScreenLogoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.splashScreenLogoImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.splashScreenTwinmeImage.backgroundColor = [UIColor clearColor];
    self.splashScreenTwinmeImage.tintColor = Design.SPLASHSCREEN_LOGO_COLOR;
    
    self.splashScreenTwinmeImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenTwinmeImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.unlockScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.unlockScreenViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.unlockScreenViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.unlockScreenView.backgroundColor = [UIColor whiteColor];
    self.unlockScreenView.userInteractionEnabled = YES;
    self.unlockScreenView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.unlockScreenView.clipsToBounds = YES;
    self.unlockScreenView.hidden = YES;
    [self.unlockScreenView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUnlockTapGesture:)]];
    
    self.unlockScreenLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.unlockScreenLabel.font = Design.FONT_BOLD34;
    self.unlockScreenLabel.textColor = [UIColor blackColor];
    self.unlockScreenLabel.text = TwinmeLocalizedString(@"lock_screen_view_controller_unlock", nil);
}

- (void)handleUnlockTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleUnlockTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self unlockScreen];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.unlockScreenLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
}

@end
