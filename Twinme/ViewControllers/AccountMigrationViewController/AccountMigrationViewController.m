/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AccountMigrationViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/AccountMigrationService.h>
#import <Twinme/TLAccountMigration.h>
#import <Twinlife/TLAccountMigrationService.h>
#import <Twinlife/TLFileInfo.h>

#import "AlertMessageView.h"
#import "InfoFloatingView.h"
#import "DefaultConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_INFO_FLOATING_VIEW_SIZE = 120;
static CGFloat INFO_FLOATING_VIEW_SIZE;

//
// Interface: AccountMigrationViewController ()
//

@interface AccountMigrationViewController () <AccountMigrationServiceDelegate, AlertMessageViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *migrationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *migrationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *startView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *declineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *declineLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (nonatomic, nonnull) AccountMigrationService *accountMigrationService;
@property (nonatomic, nullable) NSUUID *accountMigrationId;
@property (nonatomic) TLAccountMigrationState state;
@property (nonatomic) int64_t startTime;
@property (nonatomic) int64_t remain;
@property (nonatomic) int64_t sent;
@property (nonatomic) int64_t received;
@property (nonatomic) BOOL needRestart;
@property (nonatomic) BOOL canceled;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) TLConnectionStatus connectionStatus;
@property (nonatomic) BOOL isAlertMessage;

@property (nonatomic) InfoFloatingView *infoFloatingView;

@end

//
// Implementation: AccountMigrationViewController
//

#undef LOG_TAG
#define LOG_TAG @"AccountMigrationViewController"

@implementation AccountMigrationViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    INFO_FLOATING_VIEW_SIZE = DESIGN_INFO_FLOATING_VIEW_SIZE * Design.HEIGHT_RATIO;
}


- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _accountMigrationService = delegate.accountMigrationService;
        self.needRestart = NO;
        self.canceled = NO;
        self.isConnected = NO;
        self.startFromSplashScreen = NO;
        self.isAlertMessage = NO;
        self.state = TLAccountMigrationStateStarting;
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initViews];
    
    self.accountMigrationService.migrationObserver = self;
    
    if (self.accountMigrationId) {
        [self.accountMigrationService outgoingMigrationWithAccountMigrationId:self.accountMigrationId];
    } else {
        [self.accountMigrationService getMigrationState];
    }
    
    [self.navigationItem setHidesBackButton:YES];
}

- (void)initWithAccountMigration:(nonnull TLAccountMigration *)accountMigration {
    DDLogVerbose(@"%@ initWithAccountMigration: %@", LOG_TAG, accountMigration);
    
    self.accountMigrationId = accountMigration.uuid;
}

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    
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

- (void)onUpdateMigrationStateWithMigrationId:(nullable NSUUID *)migrationId startTime:(int64_t)startTime state:(TLAccountMigrationState)state status:(nullable TLAccountMigrationStatus *)status peerInfo:(nullable TLQueryInfo *)peerInfo localInfo:(nullable TLQueryInfo *)localInfo peerVersion:(nullable TLAccountMigrationVersion *)peerVersion {
    DDLogVerbose(@"%@ onUpdateMigrationStateWithMigrationId:%@ startTime: %lld state: %ld status: %@ peerInfo: %@ localInfo: %@ peerVersion: %@", LOG_TAG,migrationId.UUIDString, startTime, state, status, peerInfo, localInfo, peerVersion);
        
    if (self.needRestart) {
        return;
    }
    
    if (!self.accountMigrationId) {
        self.accountMigrationId = migrationId;
    }
    
    if (self.twinmeContext.isConnected != self.isConnected) {
        self.isConnected = self.twinmeContext.isConnected;
        if (self.isConnected) {
            [self onConnectionStatusChange:TLConnectionStatusConnected];
        } else {
            [self onConnectionStatusChange:TLConnectionStatusNoService];
        }
    }
        
    if (state != self.state) {
        // Ignore the stopped state: we cannot proceed and must remain in the terminated/canceled state.
        if (state == TLAccountMigrationStateStopped && self.state != TLAccountMigrationStateTerminated) {
            [self finish];
            return;
        }
        
        self.state = state;
        
        // If the AccountMigrationService does not have a state, it means there is no migration in progress because it was finished.
        // It happens if the current activity is called with an intent that refers to a past incoming/outgoing migration.
        if (self.state == TLAccountMigrationStateNone) {
            [self updateViews:status];
            return;
        }
        
        if (self.state == TLAccountMigrationStateStopped || self.state == TLAccountMigrationStateTerminated || self.state == TLAccountMigrationStateCanceled || self.state == TLAccountMigrationStateError) {
            self.needRestart = self.state == TLAccountMigrationStateStopped;
            [self updateViews:status];
            return;
        }
                
        self.stateLabel.text = [self stateToLabelWithState:self.state];
    }
    
    if (self.startTime == 0 && startTime != 0) {
        self.startTime = startTime;
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = NO;
    }
    
    if (!status) {
        return;
    }
    
    if (!status.isConnected) {
        self.informationLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_state_wait_connect", nil);
    } else if (self.state == TLAccountMigrationStateStarting) {
        self.informationLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_network_message", nil);
    } else if (self.state != TLAccountMigrationStateStopped && self.state != TLAccountMigrationStateTerminated && self.state != TLAccountMigrationStateCanceled && self.state != TLAccountMigrationStateError) {
        self.informationLabel.text = @"";
    }
    
    if (peerInfo && localInfo) {
        NSString *message;
        if (peerInfo.databaseFileSize >= localInfo.localDatabaseAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_controller_not_enough_space_to_receive", nil);
        } else if (localInfo.databaseFileSize >= peerInfo.localDatabaseAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_controller_not_enough_space_to_upload", nil);
        } else if (peerInfo.totalFileSize >= localInfo.localFileAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_controller_not_enough_space_for_files", nil);
        } else if (localInfo.totalFileSize >= peerInfo.localFileAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_controller_not_enough_space_for_files", nil);
        }
        
        if (message && !self.isAlertMessage) {
            self.isAlertMessage = YES;
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        }
    }
    
    long sent = status.bytesSent;
    long sentRemain = status.estimatedBytesRemainSend;
    long received = status.bytesReceived;
    double progressPercent = status.progress;
    
    if (progressPercent >= 0 && progressPercent <= 100) {
        self.progressView.progress = progressPercent / 100;
        self.progressLabel.text = [NSString stringWithFormat:@"%d %%", (int)progressPercent];
    } else if (progressPercent <= 0) {
        self.progressLabel.text = TwinmeLocalizedString(@"0%", nil);
    } else {
        self.progressLabel.text = TwinmeLocalizedString(@"100%", nil);
    }
    
    if (sentRemain != self.remain) {
        self.remain = sentRemain;
    }
    
    if (sent != self.sent) {
        self.sent = sent;
    }
    
    if (received != self.received) {
        self.received = received;
    }
}

- (void)onErrorWithErrorCode:(TLAccountMigrationErrorCode)errorCode {
    DDLogVerbose(@"%@ onErrorWithErrorCode: %ld", LOG_TAG, errorCode);
    
    //TODO: handle error, for now the only possible value for errorCode is TLAccountMigrationErrorCodeInternalError
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    self.isAlertMessage = NO;
    [self confirmCancelMigration];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);

    [abstractConfirmView closeConfirmView];
    [self confirmCancelMigration];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.WHITE_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_controller_migration_title", nil)];
    
    self.informationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.informationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.informationLabel.font = Design.FONT_BOLD28;
    self.informationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.informationLabel.text = @"";
    
    self.migrationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.migrationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.migrationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.migrationView.backgroundColor = Design.GREY_ITEM;
    self.migrationView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.migrationView.clipsToBounds = YES;
    
    self.progressLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.progressLabel.font = Design.FONT_BOLD28;
    self.progressLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.progressLabel.text = TwinmeLocalizedString(@"0%", nil);
    
    self.progressViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.progressView.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.progressView.progressTintColor = Design.MAIN_COLOR;
    self.progressView.clipsToBounds = true;
    
    CALayer *layer = [self.progressView.layer.sublayers objectAtIndex:1];
    layer.cornerRadius = 2.5;
    self.progressView.progress = 0;
    
    if (self.progressView.subviews.count > 1) {
        self.progressView.subviews[1].clipsToBounds = true;
        self.progressView.transform = CGAffineTransformMakeScale(1.0, 2.5f);
    }
    
    self.progressView.layer.cornerRadius = self.progressView.frame.size.height * 0.5;
    
    self.stateLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.stateLabel.font = Design.FONT_BOLD28;
    self.stateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.stateLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_pending", nil);
    
    self.migrationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.migrationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.startViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.startView.backgroundColor = Design.MAIN_COLOR;
    self.startView.userInteractionEnabled = YES;
    self.startView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startView.clipsToBounds = YES;
    self.startView.hidden = NO;
    
    UITapGestureRecognizer *startMigrationViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartMigrationTapGesture:)];
    [self.startView addGestureRecognizer:startMigrationViewGestureRecognizer];
    
    self.startLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startLabel.font = Design.FONT_MEDIUM34;
    self.startLabel.textColor = [UIColor whiteColor];
    self.startLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_start", nil);
    
    self.declineViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *declineViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDeclineTapGesture:)];
    [self.declineView addGestureRecognizer:declineViewGestureRecognizer];
    
    self.declineView.backgroundColor = [UIColor clearColor];
    self.declineView.userInteractionEnabled = YES;
    
    self.declineLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.declineLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.declineLabel.font = Design.FONT_MEDIUM34;
    self.declineLabel.textColor = [UIColor redColor];
    self.declineLabel.text = TwinmeLocalizedString(@"application_decline", nil);
    
    self.cancelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cancelView.backgroundColor = Design.BUTTON_RED_COLOR;
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.isAccessibilityElement = YES;
    self.cancelView.accessibilityLabel = TwinmeLocalizedString(@"account_migration_view_controller_stop", nil);
    self.cancelView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.cancelView.clipsToBounds = YES;
    [self.cancelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)]];
    self.cancelView.hidden = YES;
    
    self.cancelLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    [self.cancelLabel setFont:Design.FONT_MEDIUM34];
    self.cancelLabel.textColor = [UIColor whiteColor];
    self.cancelLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_stop", nil);
    
    if (self.startFromSplashScreen) {
        self.declineView.hidden = YES;
        self.startView.hidden = YES;
        self.cancelView.hidden = NO;
    }
}

- (void)handleStartMigrationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartMigrationTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && self.startView.alpha == 1.0f) {
        [self acceptMigration];
    }
}

- (void)handleDeclineTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDeclineTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self cancelMigration];
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self cancelMigration];
    }
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.infoFloatingView tapAction];
    }
}

- (void)updateViews:(TLAccountMigrationStatus *)status {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    if (self.state == TLAccountMigrationStateNone || self.state == TLAccountMigrationStateCanceled) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        
        if (self.state == TLAccountMigrationStateCanceled) {
            self.cancelView.hidden = NO;
            self.informationLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_cancel_message", nil);
            self.stateLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_state_canceled", nil);
            
            [self finish];
        } else {
            self.cancelView.hidden = YES;
            self.informationLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_close_message", nil);
            self.stateLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_success_message", nil);
        }
    } else if (self.state == TLAccountMigrationStateError) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = NO;
                
        if (status.errorCode == TLAccountMigrationErrorCodeNoSpaceLeft) {
            self.stateLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_not_enough_space_for_files", nil);
            self.informationLabel.text = TwinmeLocalizedString(@"application_migration_no_storage_space_message", nil);
        } else {
            self.stateLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_state_canceled", nil);
            self.informationLabel.text = [NSString stringWithFormat:@"%@ \n %ld", TwinmeLocalizedString(@"cleanup_view_controller_error", nil), (long)status.errorCode];
        }
        
        self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
    } else if (self.state == TLAccountMigrationStateStopped) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = YES;
        
        self.stateLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_success_message", nil);
        self.informationLabel.text = TwinmeLocalizedString(@"account_migration_view_controller_close_message", nil);
    }
}

- (nonnull NSString *)stateToLabelWithState:(TLAccountMigrationState)state {
    DDLogVerbose(@"%@ stateToLabelWithState: %d", LOG_TAG, (int)state);
    
    switch (state) {
        case TLAccountMigrationStateNegociate:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_negotiate", nil);
        case TLAccountMigrationStateListFiles:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_list_files", nil);
        case TLAccountMigrationStateSendFiles:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_send_files", nil);
        case TLAccountMigrationStateSendSettings:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_send_settings", nil);
        case TLAccountMigrationStateSendDatabase:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_send_database", nil);
        case TLAccountMigrationStateWaitFiles:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_wait_files", nil);
        case TLAccountMigrationStateSendAccount:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_send_account", nil);
        case TLAccountMigrationStateWaitAccount:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_wait_account", nil);
        case TLAccountMigrationStateTerminate:
            return TwinmeLocalizedString(@"account_migration_view_controller_state_terminate", nil);
        default:
            break;
    }
    
    return @"";
}

- (void)acceptMigration {
    DDLogVerbose(@"%@ acceptMigration",LOG_TAG);
    
    self.startView.hidden = YES;
    self.declineView.hidden = YES;
    
    [self.accountMigrationService startMigration];
}

- (void)cancelMigration {
    DDLogVerbose(@"%@ cancelMigration",LOG_TAG);
    
    if (self.state == TLAccountMigrationStateTerminated || self.state == TLAccountMigrationStateCanceled || self.state == TLAccountMigrationStateStopped || self.state == TLAccountMigrationStateError) {
        [self finish];
        return;
    }
    
    DefaultConfirmView *migrationConfirmView = [[DefaultConfirmView alloc] init];
    migrationConfirmView.confirmViewDelegate = self;
    
    UIImage *image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
    [migrationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"account_migration_view_controller_confirm_cancel_message", nil) image:image avatar:nil action:TwinmeLocalizedString(@"account_migration_view_controller_stop", nil) actionColor:Design.DELETE_COLOR_RED cancel:nil];
    [self.navigationController.view addSubview:migrationConfirmView];
    [migrationConfirmView showConfirmView];
}

- (void)confirmCancelMigration {
    DDLogVerbose(@"%@ confirmCancelMigration",LOG_TAG);
    
    self.startView.hidden = YES;
    self.declineView.hidden = YES;
    
    [self.accountMigrationService cancelMigration];
}

- (void)finish {
    DDLogVerbose(@"%@ finish",LOG_TAG);
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.accountMigrationService) {
        [self.accountMigrationService dispose];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.cancelLabel.font = Design.FONT_MEDIUM34;
    self.declineLabel.font = Design.FONT_MEDIUM34;
    self.startLabel.font = Design.FONT_MEDIUM34;
    self.informationLabel.font = Design.FONT_BOLD28;
    self.stateLabel.font = Design.FONT_BOLD28;
    self.progressLabel.font = Design.FONT_BOLD28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.informationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.stateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.progressLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
