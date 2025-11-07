/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLBaseService.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/NotificationErrorView.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int64_t NOTIFICATION_DURATION = 5; // s

static CGFloat DESIGN_NOTIFICATION_HEIGHT = 184.f;
static CGFloat DESIGN_NOTIFICATION_TOP = 100.f;
static CGFloat DESIGN_NOTIFICATION_LINE_HEIGHT = 22.f;

//
// Interface: NotificationErrorView ()
//

@interface NotificationErrorView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property BOOL hidden;
@property (nonatomic, readonly, nonnull) NSString *message;
@property int64_t duration;
@property CGFloat frameWidth;
@property CGFloat frameHeight;

@end

//
// Implementation: NotificationErrorView ()
//

#undef LOG_TAG
#define LOG_TAG @"NotificationErrorView"

@implementation NotificationErrorView

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message {
    DDLogVerbose(@"%@ initWithMessage: %@", LOG_TAG, message);
    
    self = [super initWithNibName:@"NotificationErrorView" bundle:nil];
    
    if (self) {
        _hidden = NO;
        _message = message;
        _duration = NOTIFICATION_DURATION;
    }
    
    return self;
}

- (nonnull instancetype)initWithErrorCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ initWithErrorCode: %u", LOG_TAG, errorCode);
    
    self = [super initWithNibName:@"NotificationErrorView" bundle:nil];
    
    if (self) {
        _hidden = NO;
        _message = [self getMessageWithErrorCode:errorCode];
        _duration = NOTIFICATION_DURATION;
    }
    
    return self;
}

- (NSString *)getMessageWithErrorCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ getMessageWithErrorCode: %u", LOG_TAG, errorCode);
    
    switch (errorCode) {
        case TLBaseServiceErrorCodeTimeoutError:
            return TwinmeLocalizedString(@"application_server_timeout", nil);
            
        case TLBaseServiceErrorCodeNoStorageSpace:
            return TwinmeLocalizedString(@"application_error_no_storage_space", nil);
            
        case TLBaseServiceErrorCodeDatabaseError:
            return TwinmeLocalizedString(@"application_database_error", nil);
            
        case TLBaseServiceErrorCodeFileNotFound:
            return TwinmeLocalizedString(@"application_error_file_not_found", nil);
            
        case TLBaseServiceErrorCodeFileNotSupported:
            return TwinmeLocalizedString(@"application_error_media_not_supported", nil);
            
        default:
            break;
    }
    
    return TwinmeLocalizedString(@"application_operation_failure", nil);
}

- (void)showInView:(UIView *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.frameWidth = view.frame.size.width;
    self.frameHeight = DESIGN_NOTIFICATION_HEIGHT * Design.HEIGHT_RATIO;
    
    self.view.frame = CGRectMake(0., -self.frameHeight, self.frameWidth, self.frameHeight);
    
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frameWidth, self.frameHeight)];
    overlayView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:overlayView atIndex:0];
    
    [UIView animateWithDuration:0.3 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.frame = CGRectMake(0., DESIGN_NOTIFICATION_TOP * Design.HEIGHT_RATIO, self.frameWidth, self.frameHeight);
    } completion:^(BOOL finished) {
    }];
    [view addSubview:self.view];
    
    [self initViews];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hideNotification];
    });
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ swipeHandler: %@", LOG_TAG, recognizer);
    
    [self hideNotification];
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ tapHandler: %@", LOG_TAG, recognizer);
    
    [self hideNotification];
}

- (void)hideNotification {
    DDLogVerbose(@"%@ hideNotification", LOG_TAG);
    
    if (self.hidden) {
        return;
    }
    self.hidden = YES;
    
    [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.frame = CGRectMake(0., -self.frameHeight + DESIGN_NOTIFICATION_TOP * Design.HEIGHT_RATIO, self.frameWidth, self.frameHeight);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.popupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.popupViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.popupViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.popupView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    CALayer *poupViewLayer = self.popupView.layer;
    poupViewLayer.cornerRadius = Design.POPUP_RADIUS;
    poupViewLayer.shadowColor = [UIColor colorWithRed:129./255 green:129./255 blue:129./255 alpha:0.20].CGColor;
    poupViewLayer.shadowOpacity = 1;
    poupViewLayer.shadowOffset = CGSizeMake(0, 24 * Design.HEIGHT_RATIO);
    poupViewLayer.shadowRadius = 32 * Design.MIN_RATIO;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.closeImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.notificationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.notificationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.notificationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:DESIGN_NOTIFICATION_LINE_HEIGHT * Design.HEIGHT_RATIO];
    
    NSMutableAttributedString *notificationAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_name", nil) attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR28 forKey:NSFontAttributeName]];
    [notificationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [notificationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.message attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR32 forKey:NSFontAttributeName]]];
    [notificationAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, notificationAttributedString.length - 1)];
    self.notificationLabel.attributedText = notificationAttributedString;
}

@end
