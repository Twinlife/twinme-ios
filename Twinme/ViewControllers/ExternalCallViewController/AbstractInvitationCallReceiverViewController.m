/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLTwincodeURI.h>

#import <Twinme/TLCallReceiver.h>

#import "AbstractInvitationCallReceiverViewController.h"

#import <TwinmeCommon/CallReceiverService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Utils.h>

#include <Photos/Photos.h>

#import <Utils/NSString+Utils.h>

#import "DeviceAuthorization.h"
#import "UIView+Toast.h"
#import "ClickToCallView.h"
#import "DeleteConfirmView.h"
#import "ResetInvitationConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_INVITATION_RADIUS = 6;
static UIColor *DESIGN_NAVIGATION_BAR_COLOR;
static UIColor *DESIGN_INVITATION_VIEW_COLOR;
static UIColor *DESIGN_INVITATION_VIEW_BORDER_COLOR;
static UIColor *DESIGN_HEADER_COLOR;
static UIColor *DESIGN_NAME_VIEW_COLOR;
static UIColor *DESIGN_RED_VIEW_COLOR;
static UIColor *DESIGN_YELLOW_VIEW_COLOR;
static UIColor *DESIGN_GREEN_VIEW_COLOR;

//
// Interface: AbstractInvitationCallReceiverViewController ()
//

@interface AbstractInvitationCallReceiverViewController ()<PHPhotoLibraryChangeObserver, ConfirmViewDelegate, CallReceiverServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *invitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedRedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedRedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedRedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedYellowViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedYellowViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedYellowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedGreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedGreenViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedGreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *generateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareSubLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;

@property BOOL saveQRCodeInGallery;

@property (nonatomic) CallReceiverService *callReceiverService;
@property (nonatomic) TLTwincodeURI *uri;

@end

//
// Implementation: AbstractInvitationCallReceiverViewController
//

#undef LOG_TAG
#define LOG_TAG @"AbstractInvitationCallReceiverViewController"

@implementation AbstractInvitationCallReceiverViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_NAVIGATION_BAR_COLOR = [UIColor colorWithRed:30./255. green:30./255. blue:30./255. alpha:1.0];
    DESIGN_INVITATION_VIEW_COLOR = [UIColor colorWithRed:69./255. green:69./255. blue:69./255. alpha:1.0];
    DESIGN_INVITATION_VIEW_BORDER_COLOR = [UIColor colorWithRed:151./255. green:151./255. blue:151./255. alpha:0.47];
    DESIGN_HEADER_COLOR = [UIColor colorWithRed:102./255. green:102./255. blue:102./255. alpha:1.0];
    DESIGN_NAME_VIEW_COLOR = [UIColor colorWithRed:81./255. green:79./255. blue:79./255. alpha:1.0];
    DESIGN_RED_VIEW_COLOR = [UIColor colorWithRed:191./255. green:60./255. blue:52./255. alpha:1.0];
    DESIGN_YELLOW_VIEW_COLOR = [UIColor colorWithRed:255./255. green:207./255. blue:8./255. alpha:1.0];
    DESIGN_GREEN_VIEW_COLOR = [UIColor colorWithRed:23./255. green:196./255. blue:164./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveQRCodeInGallery = NO;
        _callReceiverService = [[CallReceiverService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    // Update again the QR-code because the twincode could change.
    if (self.callReceiver) {
        [self updateCallReceiver];
    }
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *)self.navigationController;
    [navigationController setNavigationBarStyle:DESIGN_NAVIGATION_BAR_COLOR];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *)self.navigationController;
    [navigationController setNavigationBarStyle];
}

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ initWithCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    [self.callReceiverService initWithCallReceiver:self.callReceiver];
}

- (void)deleteCallReceiver {
    DDLogVerbose(@"%@ deleteCallReceiver", LOG_TAG);
    
    [self.callReceiverService getImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
        NSString *message;
        if (self.callReceiver.isTransfer) {
            message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"transfert_call_view_controller_delete_message", nil), TwinmeLocalizedString(@"transfert_call_view_controller_delete_confirm_message", nil)];
        } else {
            message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"edit_external_call_view_controller_message", nil), TwinmeLocalizedString(@"edit_external_call_view_controller_confirm_message", nil)];
        }
        
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeOriginator;
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:image icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }];
}

#pragma mark - CallReceiverServiceDelegate

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceiver:(nullable TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);
    
    self.uri = uri;
    [self updateCallReceiver];
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
    if ([callReceiver.uuid isEqual:self.callReceiver.uuid]) {
        self.callReceiver = callReceiver;
        [self updateCallReceiver];
    }
}

- (void)onChangeCallReceiverTwincode:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onChangeCallReceiverTwincode: %@", LOG_TAG, callReceiver);
    
    if ([callReceiver.uuid isEqual:self.callReceiver.uuid]) {
        self.callReceiver = callReceiver;
        [self updateCallReceiver];
    }
}

- (void)onUpdateCallReceiverAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateCallReceiverAvatar: %@", LOG_TAG, avatar);
    
    [self updateCallReceiver];
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
    if ([callReceiverId isEqual:self.callReceiver.uuid]) {
        [self finish];
    }
}

#pragma mark - PHPhotoLibraryChangeObserver Methods

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    DDLogVerbose(@"%@ photoLibraryDidChange: %@", LOG_TAG, changeInstance);
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    if (self.saveQRCodeInGallery) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveQRCodeWithPermissionCheck];
        });
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
        [self.callReceiverService deleteCallReceiverWithCallReceiver:self.callReceiver];
    } else {
        [self.callReceiverService changeCallReceiverTwincodeWithCallReceiver:self.callReceiver];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if (self.callReceiver.isTransfer) {
        [self setNavigationTitle:TwinmeLocalizedString(@"premium_services_view_controller_transfert_title", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil)];
    }
    
    self.invitationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.invitationView.backgroundColor = DESIGN_INVITATION_VIEW_COLOR;
    self.invitationView.clipsToBounds = YES;
    self.invitationView.layer.borderColor = DESIGN_INVITATION_VIEW_BORDER_COLOR.CGColor;
    self.invitationView.layer.borderWidth = 1.0;
    self.invitationView.layer.cornerRadius = DESIGN_INVITATION_RADIUS;
    
    self.headerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.headerView.clipsToBounds = YES;
    self.headerView.backgroundColor = DESIGN_HEADER_COLOR;
    
    self.headerView.layer.borderColor = DESIGN_INVITATION_VIEW_BORDER_COLOR.CGColor;
    self.headerView.layer.borderWidth = 1.0;
    
    self.roundedRedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedRedViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedRedView.clipsToBounds = YES;
    self.roundedRedView.layer.cornerRadius = self.roundedRedViewHeightConstraint.constant * 0.5;
    self.roundedRedView.backgroundColor = DESIGN_RED_VIEW_COLOR;
    
    self.roundedYellowViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedYellowViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedYellowView.clipsToBounds = YES;
    self.roundedYellowView.layer.cornerRadius = self.roundedYellowViewHeightConstraint.constant * 0.5;
    self.roundedYellowView.backgroundColor = DESIGN_YELLOW_VIEW_COLOR;
    
    self.roundedGreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedGreenViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedGreenView.clipsToBounds = YES;
    self.roundedGreenView.layer.cornerRadius = self.roundedGreenViewHeightConstraint.constant * 0.5;
    self.roundedGreenView.backgroundColor = DESIGN_GREEN_VIEW_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    
    self.nameViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameView.clipsToBounds = YES;
    self.nameView.layer.cornerRadius = self.nameViewHeightConstraint.constant * 0.5;
    self.nameView.backgroundColor = DESIGN_NAME_VIEW_COLOR;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    self.messageLabelTopConstraint.constant *= Design.MIN_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.text = TwinmeLocalizedString(@"invitation_call_view_controller_message", nil);
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.clipsToBounds = YES;
    self.qrcodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.qrcodeView.userInteractionEnabled = YES;
    self.qrcodeView.backgroundColor = [UIColor whiteColor];
    
    [self.qrcodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeLabelTapGesture:)]];
    
    self.qrcodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.twincodeLabel setFont:Design.FONT_MEDIUM28];
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.numberOfLines = 1;
    [self.twincodeLabel setAdjustsFontSizeToFitWidth:YES];
    self.twincodeLabel.userInteractionEnabled = YES;
    [self.twincodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeLabelTapGesture:)]];
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *saveCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveQRCodeTapGesture:)];
    [self.saveView addGestureRecognizer:saveCodeGestureRecognizer];
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    
    self.saveRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveRoundedView.clipsToBounds = YES;
    self.saveRoundedView.backgroundColor = [UIColor blackColor];
    self.saveRoundedView.layer.cornerRadius = self.saveRoundedViewHeightConstraint.constant * 0.5;
    self.saveRoundedView.layer.borderColor = Design.ACTION_BORDER_COLOR.CGColor;
    self.saveRoundedView.layer.borderWidth = 1.0;
    
    self.saveImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveImageView.tintColor = [UIColor whiteColor];
    
    self.saveLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveLabel.font = Design.FONT_MEDIUM28;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.generateViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *generateCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGenerateTwincodeTapGesture:)];
    [self.generateView addGestureRecognizer:generateCodeGestureRecognizer];
    self.generateView.isAccessibilityElement = YES;
    self.generateView.accessibilityLabel = TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil);
    
    self.generateRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateRoundedView.clipsToBounds = YES;
    self.generateRoundedView.backgroundColor = [UIColor blackColor];
    self.generateRoundedView.layer.cornerRadius = self.generateRoundedViewHeightConstraint.constant * 0.5;
    self.generateRoundedView.layer.borderColor = Design.ACTION_BORDER_COLOR.CGColor;
    self.generateRoundedView.layer.borderWidth = 1.0;
    
    self.generateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateImageView.tintColor = [UIColor whiteColor];
    
    self.generateLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.generateLabel.font = Design.FONT_MEDIUM28;
    self.generateLabel.textColor = [UIColor whiteColor];
    self.generateLabel.text = TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil);
    
    self.shareViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    self.shareView.userInteractionEnabled = YES;
    self.shareView.layer.cornerRadius = self.shareViewHeightConstraint.constant * 0.5;
    self.shareView.clipsToBounds = YES;
    self.shareView.isAccessibilityElement = YES;
    self.shareView.accessibilityLabel = TwinmeLocalizedString(@"invitation_call_view_controller_share", nil);
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSocialTapGesture)]];
    
    self.shareImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.shareImageView.tintColor = [UIColor whiteColor];
    
    self.shareLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.shareLabel.font = Design.FONT_MEDIUM36;
    self.shareLabel.textColor = [UIColor whiteColor];
    
    if (self.callReceiver.isTransfer) {
        self.shareLabel.text = TwinmeLocalizedString(@"transfert_call_view_controller_share", nil);
    } else {
        self.shareLabel.text = TwinmeLocalizedString(@"invitation_call_view_controller_share", nil);
    }
    
    [self.shareLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.shareSubLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareSubLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareSubLabel.font = Design.FONT_REGULAR24;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.shareSubLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_social_subtitle", nil);
    
    self.invitationView.hidden = NO;
    self.messageLabel.hidden = NO;
    self.shareView.hidden = NO;
    self.shareLabel.hidden = NO;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callReceiverService) {
        [self.callReceiverService dispose];
        self.callReceiverService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSaveQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.saveQRCodeInGallery = YES;
        [self saveQRCodeWithPermissionCheck];
    }
}

- (void)saveQRCodeWithPermissionCheck {
    DDLogVerbose(@"%@ saveQRCodeWithPermissionCheck", LOG_TAG);
    
    PHAuthorizationStatus photoAuthorizationStatus = [DeviceAuthorization devicePhotoAuthorizationStatus];
    switch (photoAuthorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            if (@available(iOS 14, *)) {
                [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self saveQRCode];
                        });
                    }
                }];
            } else {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self saveQRCode];
                        });
                    }
                }];
            }
            break;
        }
            
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [DeviceAuthorization showPhotoSettingsAlertInController:self];
            break;
            
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusLimited:
            [self saveQRCode];
            break;
    }
}

- (void)saveQRCode {
    DDLogVerbose(@"%@ saveQRCode", LOG_TAG);
    
    [self.callReceiverService getImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
        [self saveQRCodeWithAvatar:image];
    }];
}

- (void)saveQRCodeWithAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ saveQRCodeWithAvatar", LOG_TAG);
    
    UIImage *qrcodeToSave;
    ClickToCallView *clickToCallView;
    
    if (self.callReceiver) {
        NSString *message;
        if (self.callReceiver.isTransfer) {
            message = TwinmeLocalizedString(@"transfert_call_view_controller_gallery_message", nil);
        } else {
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"invitation_call_view_controller_save_message", nil), self.callReceiver.name];
        }
        
        clickToCallView = [[ClickToCallView alloc] initWithName:self.callReceiver.name avatar:avatar qrcode:self.qrcodeImageView.image twincodeId:self.callReceiver.twincodeOutboundId message:message];
        qrcodeToSave = [clickToCallView screenshot];
    }
    
    if (!qrcodeToSave) {
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", TwinmeLocalizedString(@"application_name", nil)];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *albumRequest;
        if (result.count == 0) {
            albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:TwinmeLocalizedString(@"application_name", nil)];
        } else {
            albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:result.firstObject];
        }
        PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:qrcodeToSave];
        [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saveQRCodeInGallery = NO;
                if (self.callReceiver.isTransfer) {
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"transfert_call_view_controller_saved_message",nil)];
                } else {
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"capture_view_controller_qrcode_saved",nil)];
                }
                
            });
        }
    }];
}

- (void)handleGenerateTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleGenerateTwincodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self.callReceiverService getImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
            NSString *message;
            if (self.callReceiver.isTransfer) {
                message = TwinmeLocalizedString(@"transfert_call_view_controller_reset_message", nil);
            } else {
                message = TwinmeLocalizedString(@"invitation_call_view_controller_generate_code_message", nil);
            }
            
            ResetInvitationConfirmView *resetInvitationConfirmView = [[ResetInvitationConfirmView alloc] init];
            resetInvitationConfirmView.confirmViewDelegate = self;
            [resetInvitationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:image icon:[UIImage imageNamed:@"GenerateCode"]];
            [self.navigationController.view addSubview:resetInvitationConfirmView];
            [resetInvitationConfirmView showConfirmView];
        }];
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self finish];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleTwincodeLabelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeLabelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];

        [[UIPasteboard generalPasteboard] setString:self.uri.uri];
        
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
    }
}

- (void)handleSocialTapGesture {
    DDLogVerbose(@"%@ handleSocialTapGesture", LOG_TAG);
    
    NSString *name = [self.callReceiver.name stringByReplacingOccurrencesOfString:@"." withString:@"\u2024"];
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@"\u02d0"];
    
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"invitation_call_view_controller_invite_message", nil), self.uri.uri, name];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.sourceView = self.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0);
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)updateCallReceiver {
    DDLogVerbose(@"%@ updateCallReceiver", LOG_TAG);
    
    [self.callReceiverService getImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
        self.avatarView.image = image;
    }];
    self.qrcodeImageView.image = [Utils makeQRCodeWithUri:self.uri scale:10];
    self.nameLabel.text = self.callReceiver.name;
    self.twincodeLabel.text = self.uri.label;
    
    if (self.callReceiver.isTransfer) {
        self.messageLabel.text = TwinmeLocalizedString(@"transfert_call_view_controller_message", nil);
    } else {
        self.messageLabel.text = TwinmeLocalizedString(@"invitation_call_view_controller_message", nil);
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    [self.saveLabel setFont:Design.FONT_MEDIUM28];
    [self.generateLabel setFont:Design.FONT_MEDIUM28];
    [self.twincodeLabel setFont:Design.FONT_MEDIUM28];
    [self.messageLabel setFont:Design.FONT_MEDIUM28];
    [self.shareLabel setFont:Design.FONT_MEDIUM32];
    self.shareSubLabel.font = Design.FONT_REGULAR24;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *)self.navigationController;
    [navigationController setNavigationBarStyle:DESIGN_NAVIGATION_BAR_COLOR];
}

@end
