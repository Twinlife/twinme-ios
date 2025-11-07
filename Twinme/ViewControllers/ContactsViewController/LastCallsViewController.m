/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Romain Kolb (romain.kolb@skyrock.com)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "LastCallsViewController.h"
#import "InAppSubscriptionViewController.h"

#import "CallCell.h"
#import "CellActionView.h"

#import <TwinmeCommon/CallsService.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "DeleteConfirmView.h"
#import "CallAgainConfirmView.h"
#import "PremiumFeatureConfirmView.h"
#import "DeviceAuthorization.h"
#import "UIContact.h"
#import "UICall.h"
#import "UIPremiumFeature.h"
#import "UIViewController+ProgressIndicator.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *CALL_CELL_IDENTIFIER = @"CallCellIdentifier";

//
// Interface: LastCallsViewController
//

@interface LastCallsViewController ()<UITableViewDataSource, UITableViewDelegate, CallsServiceDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *callsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noCallImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noCallTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noCallLabel;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) UIBarButtonItem *resetCallsBarButtonItem;

@property (nonatomic) NSMutableArray<TLCallDescriptor *> *allCalls;
@property (nonatomic) NSArray<TLCallDescriptor *> *filteredCalls;
@property (nonatomic) CallsService *callsService;
@property (nonatomic) id<TLOriginator> callOriginator;
@property (nonatomic) TLCallDescriptor *callDescriptor;
@property (nonatomic) UIContact *uiContact;

@property (nonatomic) BOOL videoCalls;
@property (nonatomic) BOOL resetAllCalls;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL isCallReceiver;

@end

//
// Implementation: LastCallsViewController
//

#undef LOG_TAG
#define LOG_TAG @"LastCallsViewController"

@implementation LastCallsViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _allCalls = [[NSMutableArray alloc] init];
        _filteredCalls = [[NSArray alloc] init];
        _videoCalls = NO;
        _resetAllCalls = NO;
        _needRefresh = NO;
        _isCallReceiver = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.callsService getCallsDescriptors];
    }
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    self.needRefresh = NO;
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
}

- (void)initWithOriginator:(id<TLOriginator>)originator callReceiver:(BOOL)callReceiver {
    DDLogVerbose(@"%@ initWithOriginator: %@", LOG_TAG, originator);
    
    self.callOriginator = originator;
    self.isCallReceiver = callReceiver;
    self.callsService = [[CallsService alloc] initWithTwinmeContext:self.twinmeContext delegate:self originator:originator];
    self.uiContact = [[UIContact alloc]initWithContact:originator];
    
    if (self.callOriginator.isGroup) {
        [self.callsService getImageWithGroup:(TLGroup *)self.callOriginator withBlock:^(UIImage *image) {
            [self.uiContact updateAvatar:image];
        }];
    } else {
        [self.callsService getImageWithContact:self.callOriginator withBlock:^(UIImage *image) {
            [self.uiContact updateAvatar:image];
        }];
    }
    
    [self showProgressIndicator];
}

#pragma mark - CallsServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
}

- (void)onGetDescriptors:(nonnull NSArray<TLCallDescriptor *> *)descriptors {
    DDLogVerbose(@"%@ onGetDescriptors: %@", LOG_TAG, descriptors);
    
    for (TLCallDescriptor *descriptor in descriptors) {
        if (![self.allCalls containsObject:descriptor]) {
            [self.allCalls addObject:descriptor];
        }
    }
    
    if (self.resetAllCalls) {
        NSInteger count = self.allCalls.count;
        if (count == 0) {
            self.resetAllCalls = NO;
            self.resetCallsBarButtonItem.enabled = NO;
            [self hideProgressIndicator];
            [self updateCalls];
        } else {
            for (NSInteger i = 0; i < count; i++) {
                TLCallDescriptor *callDescriptor = self.allCalls[i];
                [self.callsService deleteCallDescriptor:callDescriptor];
            }
        }
    } else {
        [self updateCalls];
    }
}

- (void)onAddDescriptor:(nonnull TLCallDescriptor *)descriptor {
    DDLogVerbose(@"%@ onAddDescriptor: %@", LOG_TAG, descriptor);
    
    if ([descriptor isTwincodeOutbound:self.callOriginator.twincodeOutboundId]) {
        if (![self.allCalls containsObject:descriptor]) {
            [self.allCalls insertObject:descriptor atIndex:0];
        }
        
        [self updateCalls];
    }
}

- (void)onUpdateDescriptor:(nonnull TLCallDescriptor *)descriptor {
    DDLogVerbose(@"%@ onAddDescriptor: %@", LOG_TAG, descriptor);
    
    BOOL isUpdated = NO;
    NSInteger count = self.allCalls.count;
    for (int i = 0; i < count; i++) {
        TLDescriptor *lDescriptor = [self.allCalls objectAtIndex:i];
        if ([lDescriptor isEqualDescriptor:descriptor]) {
            [self.allCalls replaceObjectAtIndex:i withObject:descriptor];
            isUpdated = YES;
            break;
        }
    }
    
    if (!isUpdated) {
        [self.allCalls insertObject:descriptor atIndex:0];
    }
    
    [self updateCalls];
}

- (void)onDeleteDescriptors:(nonnull NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);
    
    NSMutableSet *descriptorList = [[NSMutableSet alloc] initWithSet:descriptors];
    for (TLCallDescriptor *lDescriptor in self.allCalls) {
        TLDescriptorId *descriptorId = lDescriptor.descriptorId;
        if ([descriptorList containsObject:descriptorId]) {
            [descriptorList removeObject:descriptorId];
            [self.allCalls removeObject:lDescriptor];
            if (descriptorList.count == 0) {
                break;
            }
        }
    }
    
    if (self.resetAllCalls && self.allCalls.count == 0) {
        if ([self.callsService isGetDescriptorsDone]) {
            self.resetAllCalls = NO;
            self.resetCallsBarButtonItem.enabled = NO;
            [self hideProgressIndicator];
            [self updateCalls];
        } else {
            [self getPreviousDescriptors];
        }
    } else if (!self.resetAllCalls) {
        [self updateCalls];
    }
}

- (void)onGetOriginators:(nonnull NSArray<id<TLOriginator>> *)originators {
    DDLogVerbose(@"%@ onGetOriginators: %@", LOG_TAG, originators);
    
}

- (void)onCreateOriginator:(id<TLOriginator>)originator avatar:(nonnull UIImage*)avatar {
    DDLogVerbose(@"%@ onCreateOriginator: %@", LOG_TAG, originator);
    
}

- (void)onUpdateOriginator:(nonnull id<TLOriginator>)originator avatar:(nonnull UIImage*)avatar {
    DDLogVerbose(@"%@ onUpdateOriginator: %@", LOG_TAG, originator);
    
}

- (void)onRefreshContactAvatar:(nonnull UIImage*)avatar {
    DDLogVerbose(@"%@ onRefreshContactAvatar: %@", LOG_TAG, avatar);
    
    [self.uiContact updateAvatar:avatar];
}

- (void)onDeleteOriginator:(NSUUID *)originatorId {
    DDLogVerbose(@"%@ onDeleteOriginator: %@", LOG_TAG, originatorId);
    
    if ([self.callOriginator.uuid isEqual:originatorId]) {
        [self finish];
    }
    
    [self updateCalls];
}

- (void)onResetConversation:(id<TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversation: %@ clearMode: %d", LOG_TAG, conversation, clearMode);
    
    if (clearMode == TLConversationServiceClearMedia) {
        return;
    }
    
    if ([conversation.contactId isEqual:self.callOriginator.uuid]) {
        [self.allCalls removeAllObjects];
        [self updateCalls];
    }
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceivers {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceivers);
    
}

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);

}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
}

- (void)onGetGroupMembers:(nonnull NSMutableArray<id<TLGroupMemberConversation>> *)members {
    DDLogVerbose(@"%@ onGetGroupMembers: %@", LOG_TAG, members);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.filteredCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == [self.filteredCalls count] - 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPreviousDescriptors];
        });
    }
    
    CallCell *callCell = (CallCell *)[tableView dequeueReusableCellWithIdentifier:CALL_CELL_IDENTIFIER];
    if (!callCell) {
        callCell = [[CallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CALL_CELL_IDENTIFIER];
    }

    TLCallDescriptor *callDescriptor = [self.filteredCalls objectAtIndex:indexPath.row];
    UICall *uiCall = [[UICall alloc]initWithCall:[NSArray arrayWithObject:callDescriptor] uiContact:self.uiContact];
    BOOL hideSeparator = indexPath.row + 1 == self.filteredCalls.count ? YES : NO;

    [callCell bindWithCall:uiCall hideSeparator:hideSeparator];
    
    return callCell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the callDescriptor now since the list could change while contextualActionWithStyle executes.
    TLCallDescriptor *callDescriptor = [self.filteredCalls objectAtIndex:indexPath.row];
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TwinmeLocalizedString(@"application_remove", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self handleDeleteHistory:callDescriptor];
    }];
    
    CellActionView *deleteActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"application_remove", nil) icon:@"ToolbarTrash" backgroundColor:[UIColor clearColor] iconWidth:32 iconHeight:38 iconTopMargin:28];
    deleteAction.image = [deleteActionView imageFromView];
    deleteAction.backgroundColor = Design.DELETE_COLOR_RED;
    
    UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
    
    return swipeActionConfiguration;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    if (!self.isCallReceiver && !self.twinmeApplication.inCall && self.callOriginator) {
        if (self.callOriginator.isGroup && ![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
            PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
            premiumFeatureConfirmView.confirmViewDelegate = self;
            [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall spaceSettings:[self currentSpaceSettings]] parentViewController:self.navigationController];
            [self.navigationController.view addSubview:premiumFeatureConfirmView];
            [premiumFeatureConfirmView showConfirmView];
            return;
        }
        
        self.callDescriptor = [self.filteredCalls objectAtIndex:indexPath.row];
        
        if ((!self.callDescriptor.isVideo && self.callOriginator.capabilities.hasAudio) || (self.callDescriptor.isVideo && self.callOriginator.capabilities.hasVideo)) {
            
            CallAgainConfirmView *callAgainConfirmView = [[CallAgainConfirmView alloc] init];
            callAgainConfirmView.confirmViewDelegate = self;
            
            NSString *message = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
            UIImage *icon = [UIImage imageNamed:@"AudioCall"];
            if (self.callDescriptor.isVideo) {
                message = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
                icon = [UIImage imageNamed:@"VideoCall"];
            }
            
            [callAgainConfirmView initWithTitle:self.uiContact.name message:message avatar:self.uiContact.avatar icon:icon];
            
            [self.navigationController.view addSubview:callAgainConfirmView];
            [callAgainConfirmView showConfirmView];
        }
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[CallAgainConfirmView class]]) {
        if (self.callOriginator) {
            if (self.callDescriptor.isVideo) {
                [self startVideoCallWithPermissionCheck:NO];
            } else {
                [self startAudioCallWithPermissionCheck];
            }
        }
        
        self.callDescriptor = nil;
    } else if ([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
        self.resetAllCalls = YES;
        self.resetCallsBarButtonItem.enabled = NO;
        [self showProgressIndicator];
        
        NSInteger count = self.allCalls.count;
        for (NSInteger i = 0; i < count; i++) {
            TLCallDescriptor *callDescriptor = self.allCalls[i];
            [self.callsService deleteCallDescriptor:callDescriptor];
        }
    } else if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    self.callDescriptor = nil;
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    self.callDescriptor = nil;
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.resetCallsBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(handleResetTapGesture:)];
    self.resetCallsBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"history_view_controller_reset_title", nil);
    self.resetCallsBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.resetCallsBarButtonItem;
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[TwinmeLocalizedString(@"last_calls_view_controller_audio", nil), TwinmeLocalizedString(@"last_calls_view_controller_video", nil)]];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    if (@available(iOS 13.0, *)) {
        self.segmentedControl.selectedSegmentTintColor = [UIColor whiteColor];
    }
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = self.segmentedControl;
    
    self.callsTableView.delegate = self;
    self.callsTableView.dataSource = self;
    self.callsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.callsTableView.backgroundColor = Design.WHITE_COLOR;
    [self.callsTableView registerNib:[UINib nibWithNibName:@"CallCell" bundle:nil] forCellReuseIdentifier:CALL_CELL_IDENTIFIER];
    self.callsTableView.tableFooterView = [[UIView alloc] init];
    
    self.noCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noCallImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noCallImageView.hidden = YES;
    
    self.noCallTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noCallTitleLabel.font = Design.FONT_MEDIUM34;
    self.noCallTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noCallTitleLabel.text = TwinmeLocalizedString(@"history_view_controller_no_call_title", nil);
    self.noCallTitleLabel.hidden = YES;
    
    self.noCallLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noCallLabel.font = Design.FONT_MEDIUM28;
    self.noCallLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noCallLabel.text = TwinmeLocalizedString(@"history_view_controller_no_call_message", nil);
    self.noCallLabel.hidden = YES;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callsService) {
        [self.callsService dispose];
        self.callsService = nil;
    }
}

- (IBAction)segmentedControlValueDidChange:(id)sender {
    DDLogVerbose(@"%@ segmentedControlValueDidChange: %@", LOG_TAG, sender);
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.videoCalls = NO;
    } else {
        self.videoCalls = YES;
    }
    
    [self updateCalls];
}

- (void)handleDeleteHistory:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ handleDeleteHistory: %@", LOG_TAG, callDescriptor);
    
    if (callDescriptor) {
        [self.callsService deleteCallDescriptor:callDescriptor];
    }
}

- (void)getPreviousDescriptors {
    DDLogVerbose(@"%@ getPreviousDescriptors", LOG_TAG);
    
    [self.callsService getPreviousDescriptors];
}

- (void)updateCalls {
    DDLogVerbose(@"%@ updateCalls", LOG_TAG);
    
    self.filteredCalls = [self.allCalls filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TLCallDescriptor *callDescriptor, NSDictionary *bindings) {
        return [self showCall:callDescriptor];
    }]];
    
    [self.callsTableView reloadData];
    
    if (self.filteredCalls.count == 0) {
        self.noCallImageView.hidden = NO;
        self.noCallTitleLabel.hidden = NO;
        self.noCallLabel.hidden = NO;
        self.callsTableView.hidden = YES;
        self.view.backgroundColor = Design.WHITE_COLOR;
    } else {
        self.noCallImageView.hidden = YES;
        self.noCallTitleLabel.hidden = YES;
        self.noCallLabel.hidden = YES;
        self.callsTableView.hidden = NO;
        self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    }
    
    self.resetCallsBarButtonItem.enabled = self.allCalls.count > 0 ? YES : NO;
    
    if (self.filteredCalls.count == 0 && ![self.callsService isGetDescriptorsDone]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPreviousDescriptors];
        });
    }
}

- (BOOL)showCall:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ showCall: %@", LOG_TAG, callDescriptor);
    
    if (self.videoCalls == callDescriptor.isVideo) {
        return YES;
    }
    
    return NO;
}

- (void)startAudioCallWithPermissionCheck {
    DDLogVerbose(@"%@ startAudioCallWithPermissionCheck", LOG_TAG);
    
    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
    switch (audioSessionRecordPermission) {
        case AVAudioSessionRecordPermissionUndetermined: {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self startAudioCallViewController];
                    });
                }
            }];
            break;
        }
            
        case AVAudioSessionRecordPermissionDenied:
            [DeviceAuthorization showMicrophoneSettingsAlertInController:self];
            break;
            
        case AVAudioSessionRecordPermissionGranted: {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self startAudioCallViewController];
            });
            break;
        }
    }
}

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    [callViewController startCallWithOriginator:self.callOriginator videoBell:NO isVideoCall:NO isCertifyCall:NO];
    [self.navigationController pushViewController:callViewController animated:YES];
}

- (void)startVideoCallWithPermissionCheck:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallWithPermissionCheck: %d", LOG_TAG, videoBell);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                if (granted) {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        [self startVideoCallViewController:videoBell];
                                    });
                                }
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied:
                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            break;
                            
                        case AVAudioSessionRecordPermissionGranted: {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                            break;
                        }
                    }
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
            switch (audioSessionRecordPermission) {
                case AVAudioSessionRecordPermissionUndetermined: {
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                        }
                    }];
                    break;
                }
                    
                case AVAudioSessionRecordPermissionDenied:
                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    break;
                    
                case AVAudioSessionRecordPermissionGranted: {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self startVideoCallViewController:videoBell];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)startVideoCallViewController:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallViewController: %d", LOG_TAG, videoBell);
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    [callViewController startCallWithOriginator:self.callOriginator videoBell:videoBell isVideoCall:YES isCertifyCall:NO];
    [self.navigationController pushViewController:callViewController animated:YES];
}

- (void)handleResetTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (self.allCalls.count > 0) {
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeHistory;
        
        NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"application_operation_irreversible", nil), TwinmeLocalizedString(@"history_view_controller_reset", nil)];
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:self.uiContact.avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [deleteConfirmView setConfirmTitle:TwinmeLocalizedString(@"history_view_controller_reset_title", nil)];
        
        [self.tabBarController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    self.noCallTitleLabel.font = Design.FONT_MEDIUM34;
    self.noCallLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.callsTableView.backgroundColor = Design.WHITE_COLOR;
    
    self.noCallTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noCallLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
}

@end
