/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLTwincodeURI.h>

#import <Twinme/TLContact.h>

#import "InvitationRoomViewController.h"
#import "AddParticipantsViewController.h"

#import <TwinmeCommon/InvitationRoomService.h>
#import <TwinmeCommon/Utils.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import "TwincodeView.h"
#import "UIView+Toast.h"

static CGFloat DESIGN_AVATAR_BORDER_WIDTH = 6;
static const CGFloat DESIGN_QRCODE_TOP_MARGIN = 60;

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InvitationRoomViewController ()
//

@interface InvitationRoomViewController ()<InvitationRoomServiceDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *roomView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomCopyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomCopyViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *roomCopyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomCopyRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *roomCopyRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomCopyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *roomCopyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomCopyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *roomCopyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareSubLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) TLContact *room;
@property (nonatomic, nullable) TLTwincodeURI *uri;

@property(nonatomic) InvitationRoomService *invitationRoomService;

@property (nonatomic) BOOL zoomQRCode;
@property (nonatomic) CGFloat qrCodeInitialTop;
@property (nonatomic) CGFloat qrCodeInitialHeight;
@property (nonatomic) CGFloat qrCodeMaxHeight;
@property BOOL saveQRCodeInGallery;

@end

//
// Implementation: InvitationRoomViewController
//

#undef LOG_TAG
#define LOG_TAG @"InvitationRoomViewController"

@implementation InvitationRoomViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveQRCodeInGallery = NO;
        _qrCodeInitialTop = DESIGN_QRCODE_TOP_MARGIN * Design.HEIGHT_RATIO;
        _qrCodeInitialHeight = 0;
        _qrCodeMaxHeight = 0;
        _invitationRoomService = [[InvitationRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
    
    [self updateRoom];
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    [self.invitationRoomService initWithRoom:self.room];
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

#pragma mark - InvitationRoomServiceDelegate delegate methods

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
}

- (void)onGetTwincodeURI:(TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);
    
    self.uri = uri;
    [self updateRoom];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"show_room_view_controller_invite_participants", nil)];
    
    self.roomViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.roomView.userInteractionEnabled = NO;
        
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.roomViewHeightConstraint.constant * 0.5;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.containerView.clipsToBounds = YES;
    
    self.containerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.containerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.containerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.containerView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.containerView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.containerView.layer.masksToBounds = NO;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.clipsToBounds = YES;
    self.qrcodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.qrcodeView.userInteractionEnabled = YES;
    self.qrcodeView.backgroundColor = [UIColor whiteColor];
    
    [self.qrcodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)]];
        
    self.zoomViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.zoomViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.zoomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomView.clipsToBounds = YES;
    self.zoomView.backgroundColor = Design.WHITE_COLOR;
    self.zoomView.layer.cornerRadius = self.zoomViewHeightConstraint.constant * 0.5;
    self.zoomView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.zoomView.layer.borderWidth = 1.0;
    self.zoomView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *zoomGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)];
    [self.zoomView addGestureRecognizer:zoomGestureRecognizer];
    
    self.zoomImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomImageView.tintColor = Design.BLACK_COLOR;
    
    self.roomLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.roomLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.roomLabel setFont:Design.FONT_MEDIUM28];
    self.roomLabel.textColor = [UIColor whiteColor];
    self.roomLabel.numberOfLines = 1;
    [self.roomLabel setAdjustsFontSizeToFitWidth:YES];
    self.roomLabel.userInteractionEnabled = YES;
    [self.roomLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyTapGesture:)]];
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *saveCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveQRCodeTapGesture:)];
    [self.saveView addGestureRecognizer:saveCodeGestureRecognizer];
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    
    self.saveRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveRoundedView.clipsToBounds = YES;
    self.saveRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.saveRoundedView.layer.cornerRadius = self.saveRoundedViewHeightConstraint.constant * 0.5;
    self.saveRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.saveRoundedView.layer.borderWidth = 1.0;

    self.saveImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveImageView.tintColor =Design.BLACK_COLOR;
    
    self.saveLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveLabel.font = Design.FONT_MEDIUM28;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.roomCopyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomCopyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *roomCopyGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyTapGesture:)];
    [self.roomCopyView addGestureRecognizer:roomCopyGestureRecognizer];
    self.roomCopyView.isAccessibilityElement = YES;
    self.roomCopyView.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    
    self.roomCopyRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomCopyRoundedView.clipsToBounds = YES;
    self.roomCopyRoundedView.backgroundColor = [UIColor blackColor];
    self.roomCopyRoundedView.layer.cornerRadius = self.roomCopyRoundedViewHeightConstraint.constant * 0.5;
    self.roomCopyRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.roomCopyRoundedView.layer.borderWidth = 1.0;
    
    self.roomCopyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomCopyImageView.tintColor = Design.BLACK_COLOR;
    
    self.roomCopyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.roomCopyLabel.font = Design.FONT_MEDIUM28;
    self.roomCopyLabel.textColor = [UIColor whiteColor];
    self.roomCopyLabel.text = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    
    self.shareViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    self.shareView.userInteractionEnabled = YES;
    self.shareView.layer.cornerRadius = self.shareViewHeightConstraint.constant * 0.5;
    self.shareView.clipsToBounds = YES;
    self.shareView.isAccessibilityElement = YES;
    self.shareView.accessibilityLabel = TwinmeLocalizedString(@"share_view_controller_title", nil);
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareTapGesture:)]];
    
    self.shareImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.shareImageView.tintColor = [UIColor whiteColor];
    
    self.shareLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.shareLabel.font = Design.FONT_MEDIUM36;
    self.shareLabel.textColor = [UIColor whiteColor];
    self.shareLabel.text = TwinmeLocalizedString(@"share_view_controller_title", nil);
    
    [self.shareLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.shareSubLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareSubLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareSubLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareSubLabel.font = Design.FONT_REGULAR24;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.shareSubLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_social_subtitle", nil);
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.text = TwinmeLocalizedString(@"invitation_room_view_controller_message", nil);
        
    self.qrCodeInitialHeight = self.qrcodeViewHeightConstraint.constant;
    self.qrCodeInitialTop = self.qrcodeViewTopConstraint.constant;
    self.qrCodeMaxHeight = self.containerViewWidthConstraint.constant - self.roomLabelLeadingConstraint.constant - self.roomLabelTrailingConstraint.constant;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.invitationRoomService) {
        [self.invitationRoomService dispose];
        self.invitationRoomService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateQRCodeSize {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    self.zoomQRCode = !self.zoomQRCode;
    float alpha = self.zoomQRCode ? 0.0 : 1.0;
    
    CGFloat qrCodeHeight = self.zoomQRCode ? self.qrCodeMaxHeight : self.qrCodeInitialHeight;
    CGFloat qrCodeTop = self.qrCodeInitialTop;
    CGFloat animateActionDelay = self.zoomQRCode ? 0.f : 0.1f;
    CGFloat animateQRCodeDelay = self.zoomQRCode ? 0.1f : 0.f;
   
    [self animateQRCodeAction:alpha delay:animateActionDelay];
    [self animateQRCodeSize:qrCodeTop height:qrCodeHeight delay:animateQRCodeDelay];
}

- (void)animateQRCodeAction:(CGFloat)alpha delay:(CGFloat)delay {
    DDLogVerbose(@"%@ animateQRCodeAction", LOG_TAG);
        
    [UIView animateWithDuration:0.1 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.roomCopyView.alpha = alpha;
        self.saveView.alpha = alpha;
        self.zoomView.alpha = alpha;
        self.roomLabel.alpha = alpha;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateQRCodeSize:(CGFloat)top height:(CGFloat)height delay:(CGFloat)delay {
    DDLogVerbose(@"%@ animateQRCodeSize", LOG_TAG);
    
    [UIView animateWithDuration:0.1 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.qrcodeViewTopConstraint.constant = top;
        self.qrcodeViewHeightConstraint.constant = height;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];
}


- (void)handleInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AddParticipantsViewController *addParticipantsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddParticipantsViewController"];
        [addParticipantsViewController initWithRoom:self.room];
        [self.navigationController pushViewController:addParticipantsViewController animated:YES];
    }
}

- (void)handleShareTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleShareTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // To avoid hyperlink injections in names, we replace '.' and ':' into special UTF-8 characters
        // that also visually correspond to '.' and ':'.  These two replacements allow to break
        // hyperlink recognition and forwarding.  Even cut&paste will not allow to follow such link.
        NSString *name = [self.room.name stringByReplacingOccurrencesOfString:@"." withString:@"\u2024"];
        name = [name stringByReplacingOccurrencesOfString:@":" withString:@"\u02d0"];
        NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"add_contact_view_controller_invite_message %@ %@", nil), self.uri.uri, name];
        
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
}

- (void)handleQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateQRCodeSize];
    }
}

- (void)handleCopyTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCopyTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        [[UIPasteboard generalPasteboard] setString:self.uri.uri];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
    }
}

- (void)handleSaveQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
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
    
    [self saveQRCodeWithAvatar:self.avatarView.image];
}

- (void)saveQRCodeWithAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ saveQRCodeWithAvatar", LOG_TAG);
    
    UIImage *qrcodeToSave;
    TwincodeView *twincodeView;
    
    if (self.room) {
        twincodeView = [[TwincodeView alloc] initWithName:self.room.name avatar:avatar qrcode:self.qrcodeView.image twincodeId:self.room.twincodeOutbound.uuid];
        qrcodeToSave = [twincodeView screenshot];
    }
    
    if (!qrcodeToSave) {
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", TwinmeLocalizedString(@"application_name", nil)];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    twincodeView = nil;
    
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
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"capture_view_controller_qrcode_saved",nil)];
            });
        }
    }];
}


- (void)updateRoom {
    DDLogVerbose(@"%@ updateRoom", LOG_TAG);
    
    self.roomLabel.text = [self.room.publicPeerTwincodeOutboundId  UUIDString];
    self.qrcodeView.image = [Utils makeQRCodeWithUri:self.uri scale:10];
    self.nameLabel.text = self.room.name;
    [self.invitationRoomService getImageWithContact:self.room withBlock:^(UIImage *image) {
        self.avatarView.image = image;
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.saveLabel.font = Design.FONT_MEDIUM28;
    self.roomCopyLabel.font = Design.FONT_MEDIUM28;
    self.roomLabel.font = Design.FONT_BOLD34;
    [self.messageLabel setFont:Design.FONT_REGULAR28];
    [self.shareLabel setFont:Design.FONT_MEDIUM32];
    self.shareSubLabel.font = Design.FONT_REGULAR24;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.GREY_BACKGROUND_COLOR;
    self.roomLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.saveLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.roomCopyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    
    self.saveRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.saveRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.saveImageView.tintColor = Design.BLACK_COLOR;
    
    self.roomCopyRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.roomCopyRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.roomCopyImageView.tintColor = Design.BLACK_COLOR;
}
@end
