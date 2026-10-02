/*
 *  Copyright (c) 2020-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Romain Kolb (romain.kolb@skyrock.com)
 */

#import <CocoaLumberjack.h>
#import <QuartzCore/QuartzCore.h>

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
#import "ApplicationAssertion.h"
#import "MigrationStateCell.h"
#import "MigrationHeaderCell.h"
#import "UIMigrationStateItem.h"
#import "MigrationDeviceView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_CELL_HEIGHT = 100;
static const CGFloat DESIGN_TABLE_VIEW_GRADIENT_HEIGHT = 40;
static CGFloat DESIGN_INFO_FLOATING_VIEW_SIZE = 120;
static CGFloat INFO_FLOATING_VIEW_SIZE;

static NSString *MIGRATION_HEADER_CELL_IDENTIFIER = @"MigrationHeaderCellIdentifier";
static NSString *MIGRATION_STATE_CELL_IDENTIFIER = @"MigrationStateCellIdentifier";

static UIColor *DEVICE_COLOR_PRIMARY;
static UIColor *DEVICE_COLOR_SECONDARY;

//
// Interface: AccountMigrationViewController ()
//

@interface AccountMigrationViewController () <UITableViewDataSource, UITableViewDelegate, AccountMigrationServiceDelegate, AlertMessageViewDelegate, BottomSheetViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationTitleLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationTitleLabelTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *migrationTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *migrationImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *migrationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIView *tableViewTopGradientView;
@property (nonatomic) UIView *tableViewBottomGradientView;
@property (nonatomic) CAGradientLayer *tableViewTopGradientLayer;
@property (nonatomic) CAGradientLayer *tableViewBottomGradientLayer;
@property (nonatomic) CGFloat tableViewBottomConstraintValue;

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
@property (nonatomic) DefaultConfirmView *cancelMigrationConfirmView;
@property (nonatomic) UIMigrationStateItem *headerMigrationStateItem;
@property (nonatomic) NSMutableArray<UIMigrationStateItem *> *migrationsItems;

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
    DEVICE_COLOR_PRIMARY = [UIColor colorWithRed:169./255. green:151./255. blue:245./255. alpha:1.0f];
    DEVICE_COLOR_SECONDARY = [UIColor colorWithRed:85./255. green:182./255. blue:248./255. alpha:1.0f];
}

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _accountMigrationService = delegate.accountMigrationService;
        self.needRestart = NO;
        self.canceled = NO;
        self.isConnected = NO;
        self.isAlertMessage = NO;
        self.state = TLAccountMigrationStateStarting;
        self.migrationsItems = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initViews];
    
    self.accountMigrationService.migrationObserver = self;
    
    // Check if we have an active migration to resume.
    if (!self.accountMigrationId) {
        self.accountMigrationId = [[self.twinmeContext getAccountMigrationService] getActiveDeviceMigrationId];
    }
    
    if (self.accountMigrationId) {
        [self.accountMigrationService outgoingMigrationWithAccountMigrationId:self.accountMigrationId];
    } else {
        [self.accountMigrationService getMigrationState];
    }
    
    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    self.tableViewTopGradientLayer.frame = self.tableViewTopGradientView.bounds;
    self.tableViewBottomGradientLayer.frame = self.tableViewBottomGradientView.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)initWithAccountMigration:(nonnull TLAccountMigration *)accountMigration {
    DDLogVerbose(@"%@ initWithAccountMigration: %@", LOG_TAG, accountMigration);
    
    self.accountMigrationId = accountMigration.uuid;
}

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ onConnectionStatusChange: %u", LOG_TAG, connectionStatus);

    if (connectionStatus == TLConnectionStatusConnected) {
        if (self.connectionStatus == connectionStatus) {
            return;
        }
        self.connectionStatus = connectionStatus;
        
        if ([self.twinmeApplication showConnectedMessage]) {
            [self.twinmeApplication setShowConnectedMessage:NO];
            [self initInfoFloatingView];
        }
        
        if (self.infoFloatingView) {
            [self.infoFloatingView setConnectionStatus:connectionStatus];
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
        
        [self updateTableViewBottom];
    }
    
    if (self.state == TLAccountMigrationStateTerminated) {
        [self.twinmeApplication hideWelcomeScreen];
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
        // alpha == 0.5 => button effectively disabled
        self.startView.alpha = 0.5f;
    } else if (self.state == TLAccountMigrationStateNegociate) {
        self.startView.alpha = 1.0f;
    }
    
    [self updateItems:state status:status];
    
    if (peerInfo && localInfo) {
        
        NSString *message;
        if (peerInfo.databaseFileSize >= localInfo.localDatabaseAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_not_enough_space_to_receive", nil);
        } else if (localInfo.databaseFileSize >= peerInfo.localDatabaseAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_not_enough_space_to_upload", nil);
        } else if (peerInfo.totalFileSize >= localInfo.localFileAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_not_enough_space_for_files", nil);
        } else if (localInfo.totalFileSize >= peerInfo.localFileAvailableSize) {
            message = TwinmeLocalizedString(@"account_migration_view_not_enough_space_for_files", nil);
        }
        
        if (message && !self.isAlertMessage) {
            self.isAlertMessage = YES;
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:message];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        }
    }
    
    long sent = status.bytesSent;
    long sentRemain = status.sendProgress;
    long received = status.bytesReceived;
    
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

    TL_ASSERTION(self.twinmeContext, [ApplicationAssertPoint MIGRATION_ERROR], [TLAssertValue initWithNumber:(int)errorCode], [TLAssertValue initWithResourceId:self.accountMigrationId], [TLAssertValue initWithNumber:(int)self.state]);

    //TODO: handle error, for now the only possible value for errorCode is TLAccountMigrationErrorCodeInternalError
    [self finish];
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

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);

    [abstractBottomSheetView closeConfirmView];
    [self confirmCancelMigration];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);

    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
    
    if ([self.cancelMigrationConfirmView isEqual:abstractBottomSheetView]) {
        self.cancelMigrationConfirmView = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ estimatedHeightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return roundf(DESIGN_TABLE_VIEW_GRADIENT_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return roundf(DESIGN_TABLE_VIEW_GRADIENT_HEIGHT * Design.HEIGHT_RATIO);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.migrationsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIMigrationStateItem *migrationStateItem = [self.migrationsItems objectAtIndex:indexPath.row];
    MigrationStateCell *cell = [tableView dequeueReusableCellWithIdentifier:MIGRATION_STATE_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[MigrationStateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MIGRATION_STATE_CELL_IDENTIFIER];
    }
    
    BOOL previousStateDone = NO;
    if (indexPath.row != 0) {
        UIMigrationStateItem *migrationStateItem = [self.migrationsItems objectAtIndex:indexPath.row - 1];
        previousStateDone = [migrationStateItem getState] == MigrationStateItemStateDone;
    }
    
    [cell setMinimumHeight:roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO)];

    [cell bindWithItem:migrationStateItem previousStateDone:previousStateDone];
    
    return cell;
}


#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.WHITE_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_migration_title", nil)];
    
    self.migrationTitleLabelLeading.constant *= Design.WIDTH_RATIO;
    self.migrationTitleLabelTrailing.constant *= Design.WIDTH_RATIO;
    self.migrationTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.migrationTitleLabel.text = TwinmeLocalizedString(@"account_view_migration_title", nil);
    self.migrationTitleLabel.textColor = Design.BLACK_COLOR;
    self.migrationTitleLabel.font = Design.FONT_BOLD34;
    
    self.migrationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.migrationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.infoLabelLeading.constant *= Design.WIDTH_RATIO;
    self.infoLabelTrailing.constant *= Design.WIDTH_RATIO;
    self.infoLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = Design.BLACK_COLOR;
    self.infoLabel.font = Design.FONT_REGULAR34;
    self.infoLabel.text = @"";
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraintValue = self.tableViewBottomConstraint.constant;
    self.tableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.tableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MigrationHeaderCell" bundle:nil] forCellReuseIdentifier:MIGRATION_HEADER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"MigrationStateCell" bundle:nil] forCellReuseIdentifier:MIGRATION_STATE_CELL_IDENTIFIER];

    self.tableView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.tableView.layer.masksToBounds = YES;
    [self initTableViewGradientViews];
    
    self.startViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.startView.backgroundColor = Design.MAIN_COLOR;
    self.startView.userInteractionEnabled = YES;
    self.startView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startView.clipsToBounds = YES;
    self.startView.hidden = NO;
    // Start button cannot be selected until we are connected.
    self.startView.alpha = 0.5f;
    
    UITapGestureRecognizer *startMigrationViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartMigrationTapGesture:)];
    [self.startView addGestureRecognizer:startMigrationViewGestureRecognizer];
    
    self.startLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startLabel.font = Design.FONT_MEDIUM34;
    self.startLabel.textColor = [UIColor whiteColor];
    self.startLabel.text = TwinmeLocalizedString(@"account_migration_view_start", nil);
    
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
    
    self.cancelView.backgroundColor = Design.BLACK_COLOR;
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.isAccessibilityElement = YES;
    self.cancelView.accessibilityLabel = TwinmeLocalizedString(@"account_migration_view_stop", nil);
    self.cancelView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.cancelView.clipsToBounds = YES;
    [self.cancelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)]];
    self.cancelView.hidden = YES;
    
    self.cancelLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    [self.cancelLabel setFont:Design.FONT_MEDIUM34];
    self.cancelLabel.textColor = Design.WHITE_COLOR;
    self.cancelLabel.text = TwinmeLocalizedString(@"account_migration_view_stop", nil);
    
    [self initItems];
    [self updateTableViewBottom];
}

- (void)initTableViewGradientViews {
    DDLogVerbose(@"%@ initTableViewGradientViews", LOG_TAG);
    
    CGFloat gradientHeight = roundf(DESIGN_TABLE_VIEW_GRADIENT_HEIGHT * Design.HEIGHT_RATIO);
    
    self.tableViewTopGradientView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableViewTopGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableViewTopGradientView.userInteractionEnabled = NO;
    self.tableViewTopGradientView.clipsToBounds = YES;
    
    self.tableViewBottomGradientView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableViewBottomGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableViewBottomGradientView.userInteractionEnabled = NO;
    self.tableViewBottomGradientView.clipsToBounds = YES;
    
    UIColor *whiteColor = Design.WHITE_COLOR;
    UIColor *transparentColor = [whiteColor colorWithAlphaComponent:0.0f];
    
    self.tableViewTopGradientLayer = [CAGradientLayer layer];
    self.tableViewTopGradientLayer.colors = @[(id)whiteColor.CGColor, (id)transparentColor.CGColor];
    self.tableViewTopGradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
    self.tableViewTopGradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
    
    self.tableViewBottomGradientLayer = [CAGradientLayer layer];
    self.tableViewBottomGradientLayer.colors = @[(id)transparentColor.CGColor, (id)whiteColor.CGColor];
    self.tableViewBottomGradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
    self.tableViewBottomGradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
    
    [self.tableViewTopGradientView.layer addSublayer:self.tableViewTopGradientLayer];
    [self.tableViewBottomGradientView.layer addSublayer:self.tableViewBottomGradientLayer];
    
    [self.view addSubview:self.tableViewTopGradientView];
    [self.view addSubview:self.tableViewBottomGradientView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableViewTopGradientView.leadingAnchor constraintEqualToAnchor:self.tableView.leadingAnchor],
        [self.tableViewTopGradientView.trailingAnchor constraintEqualToAnchor:self.tableView.trailingAnchor],
        [self.tableViewTopGradientView.topAnchor constraintEqualToAnchor:self.tableView.topAnchor],
        [self.tableViewTopGradientView.heightAnchor constraintEqualToConstant:gradientHeight],
        
        [self.tableViewBottomGradientView.leadingAnchor constraintEqualToAnchor:self.tableView.leadingAnchor],
        [self.tableViewBottomGradientView.trailingAnchor constraintEqualToAnchor:self.tableView.trailingAnchor],
        [self.tableViewBottomGradientView.bottomAnchor constraintEqualToAnchor:self.tableView.bottomAnchor],
        [self.tableViewBottomGradientView.heightAnchor constraintEqualToConstant:gradientHeight]
    ]];
    
    [self.view bringSubviewToFront:self.tableViewTopGradientView];
    [self.view bringSubviewToFront:self.tableViewBottomGradientView];
}

- (void)updateTableViewBottom {
    DDLogVerbose(@"%@ updateTableViewBottom", LOG_TAG);

    UIView *view;
    NSLayoutAttribute attribute;
    if (!self.startView.hidden) {
        view = self.startView;
        attribute = NSLayoutAttributeTop;
    } else if (self.cancelView.hidden) {
        view = self.cancelView;
        attribute = NSLayoutAttributeBottom;
    } else {
        view = self.cancelView;
        attribute = NSLayoutAttributeTop;
    }

    [NSLayoutConstraint deactivateConstraints:@[self.tableViewBottomConstraint]];
    self.tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:attribute multiplier:1.0f constant:-self.tableViewBottomConstraintValue];
    [NSLayoutConstraint activateConstraints:@[self.tableViewBottomConstraint]];
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
    
    if ((self.state == TLAccountMigrationStateCanceled || self.state == TLAccountMigrationStateError || self.state == TLAccountMigrationStateStopped || self.state == TLAccountMigrationStateTerminated) && self.cancelMigrationConfirmView) {
        [self.cancelMigrationConfirmView closeConfirmView];
    }
    
    if (self.state == TLAccountMigrationStateNone || self.state == TLAccountMigrationStateCanceled) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        
        if (self.state == TLAccountMigrationStateCanceled) {
            self.cancelView.hidden = NO;
            [self finish];
        } else {
            self.cancelView.hidden = YES;
        }
    } else if (self.state == TLAccountMigrationStateError) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = NO;
        self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
    } else if (self.state == TLAccountMigrationStateStopped || self.state == TLAccountMigrationStateTerminated) {
        self.startView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = YES;
    }
    
    [self updateTableViewBottom];
}

- (nonnull NSString *)stateToLabelWithState:(TLAccountMigrationState)state {
    DDLogVerbose(@"%@ stateToLabelWithState: %d", LOG_TAG, (int)state);
    
    switch (state) {
        case TLAccountMigrationStateNegociate:
            return TwinmeLocalizedString(@"account_migration_view_state_negotiate", nil);
        case TLAccountMigrationStateListFiles:
            return TwinmeLocalizedString(@"account_migration_view_state_list_files", nil);
        case TLAccountMigrationStateSendFiles:
            return TwinmeLocalizedString(@"account_migration_view_state_send_files", nil);
        case TLAccountMigrationStateSendSettings:
            return TwinmeLocalizedString(@"account_migration_view_state_send_settings", nil);
        case TLAccountMigrationStateSendDatabase:
            return TwinmeLocalizedString(@"account_migration_view_state_send_database", nil);
        case TLAccountMigrationStateWaitFiles:
            return TwinmeLocalizedString(@"account_migration_view_state_wait_files", nil);
        case TLAccountMigrationStateSendAccount:
            return TwinmeLocalizedString(@"account_migration_view_state_send_account", nil);
        case TLAccountMigrationStateWaitAccount:
            return TwinmeLocalizedString(@"account_migration_view_state_wait_account", nil);
        case TLAccountMigrationStateTerminate:
            return TwinmeLocalizedString(@"account_migration_view_state_terminate", nil);
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
    
    self.cancelMigrationConfirmView = [[DefaultConfirmView alloc] init];
    self.cancelMigrationConfirmView.bottomSheetViewDelegate = self;
    [self.cancelMigrationConfirmView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedString(@"account_migration_view_confirm_cancel_message", nil) image:nil avatar:nil action:TwinmeLocalizedString(@"account_migration_view_stop", nil) actionColor:Design.DELETE_COLOR_RED cancel:nil];
    [self.navigationController.view addSubview:self.cancelMigrationConfirmView];
    [self.cancelMigrationConfirmView showConfirmView];
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
        // Important note: we must not dispose the account migration service but instead inform the service to stop.
        [self.accountMigrationService stopService];
    }
    
    [self removeInfoFloatingView];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initItems {
    DDLogVerbose(@"%@ initItems", LOG_TAG);
    
    self.headerMigrationStateItem = [[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeHeader];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeInit]];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeTransfer]];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeSettings]];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeDatabase]];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeAcocunt]];
    [self.migrationsItems addObject:[[UIMigrationStateItem alloc]initWithType:MigrationStateItemTypeTerminated]];
}

- (void)updateItems:(TLAccountMigrationState)state status:(TLAccountMigrationStatus *)status {
    DDLogVerbose(@"%@ updateItems", LOG_TAG);
    
    if (self.headerMigrationStateItem) {
        [self.headerMigrationStateItem update:state status:status];
    }
    
    for (UIMigrationStateItem *migrationStateItem in self.migrationsItems) {
        [migrationStateItem update:state status:status];
    }
    
    [self reloadData];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if (self.headerMigrationStateItem) {
        if ([self.headerMigrationStateItem getInfo] && [[self.headerMigrationStateItem getInfo] length] > 0) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[self.headerMigrationStateItem  getTitle] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
            if ([self.headerMigrationStateItem  getInfo]) {
                [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
                [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[self.headerMigrationStateItem  getInfo] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
            }
            self.infoLabel.attributedText = attributedString;
        } else {
            self.infoLabel.font = Design.FONT_MEDIUM36;
            self.infoLabel.textColor = Design.FONT_COLOR_DEFAULT;
            self.infoLabel.text = [self.headerMigrationStateItem  getTitle];
        }
    }
    
    [self.tableView reloadData];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.cancelLabel.font = Design.FONT_MEDIUM34;
    self.declineLabel.font = Design.FONT_MEDIUM34;
    self.startLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);

    self.cancelView.backgroundColor = Design.BLACK_COLOR;
    self.cancelLabel.textColor = Design.WHITE_COLOR;
}

@end
