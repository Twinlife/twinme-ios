/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "NotificationView.h"

#import <Twinme/TLTwinmeAttributes.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int64_t CHAT_DURATION = 5; // s
static const int64_t CALL_DURATION = 30; // s

static CGFloat DESIGN_NOTIFICATION_HEIGHT = 184.f;
static CGFloat DESIGN_NOTIFICATION_CALL_HEIGHT = 520.f;
static CGFloat DESIGN_NOTIFICATION_TOP = 100.f;
static CGFloat DESIGN_NOTIFICATION_LINE_HEIGHT = 22.f;

//
// Interface: NotificationView ()
//

@interface NotificationView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property BOOL hidden;
@property (nonatomic, readonly, nonnull) NSUUID *notificationId;
@property (nonatomic, readonly, nonnull) NSString *title_;
@property (nonatomic, readonly, nonnull) NSString *message;
@property (nonatomic, readonly, nonnull) UIImage *avatar;
@property (nonatomic, readonly, nullable) NotificationSound *notificationSound;
@property BOOL actionButtons;
@property int64_t duration;
@property id<NotificationViewDelegate> notificationViewDelegate;
@property CGFloat frameWidth;
@property CGFloat frameHeight;

@end

//
// Implementation: NotificationView ()
//

#undef LOG_TAG
#define LOG_TAG @"NotificationView"

@implementation NotificationView

- (nonnull instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId title:(nonnull NSString *)title message:(nonnull NSString *)message avatar:(nonnull UIImage *)avatar notificationSound:(nullable NotificationSound *)notificationSound actionButtons:(BOOL)actionButtons notificationViewDelegate:(nonnull id<NotificationViewDelegate>)notificationViewDelegate {
    DDLogVerbose(@"%@ initWithNotificationId: %@ title: %@ message: %@ avatar: %@ notiifcationSound: %@ actionButtons: %@ notificationViewDelegate: %@", LOG_TAG, notificationId, title, message, avatar, notificationSound, actionButtons ? @"YES" : @"NO", notificationViewDelegate);
    
    if (actionButtons) {
        self = [super initWithNibName:@"NotificationCallView" bundle:nil];
    } else {
        self = [super initWithNibName:@"NotificationView" bundle:nil];
    }
    
    if (self) {
        _hidden = NO;
        _notificationId = notificationId;
        _title_ = title;
        _message = message;
        _avatar = avatar;
        _notificationSound = notificationSound;
        _actionButtons = actionButtons;
        if (_actionButtons) {
            _duration = CALL_DURATION;
        } else {
            _duration = CHAT_DURATION;
        }
        _notificationViewDelegate = notificationViewDelegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)showInView:(UIView*)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    if (self.notificationSound) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        if (!twinmeApplication.inCall) {
            if(self.actionButtons) {
                [self.notificationSound playWithLoop:YES audioSessionCategory:AVAudioSessionCategorySoloAmbient];
            } else {
                [self.notificationSound playWithLoop:NO audioSessionCategory:AVAudioSessionCategorySoloAmbient];
            }
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
    
    self.frameWidth = view.frame.size.width;
    if (self.actionButtons) {
        self.frameHeight = DESIGN_NOTIFICATION_CALL_HEIGHT * Design.HEIGHT_RATIO;
    } else {
        self.frameHeight = DESIGN_NOTIFICATION_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    self.view.frame = CGRectMake(0., -self.frameHeight, self.frameWidth, self.frameHeight);
    
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frameWidth, self.frameHeight)];
    overlayView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:overlayView atIndex:0];
    
    [UIView animateWithDuration:0.3 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.frame = CGRectMake(0., DESIGN_NOTIFICATION_TOP * Design.HEIGHT_RATIO, self.frameWidth, self.frameHeight);
    }
                     completion:^(BOOL finished) {
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
    if ([self.notificationViewDelegate respondsToSelector:@selector(handleSwipeActionWithNotificationId:)]) {
        [self.notificationViewDelegate handleSwipeActionWithNotificationId:self.notificationId];
    }
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ tapHandler: %@", LOG_TAG, recognizer);
    
    [self hideNotification];
    if ([self.notificationViewDelegate respondsToSelector:@selector(handleTapActionWithNotificationId:)]) {
        [self.notificationViewDelegate handleTapActionWithNotificationId:self.notificationId];
    }
}

- (IBAction)acceptButtonAction:(id)sender {
    DDLogVerbose(@"%@ acceptButtonAction: %@", LOG_TAG, sender);
    
    [self hideNotification];
    if ([self.notificationViewDelegate respondsToSelector:@selector(handleAcceptActionWithNotificationId:)]) {
        [self.notificationViewDelegate handleAcceptActionWithNotificationId:self.notificationId];
    }
}

- (IBAction)declineButtonAction:(id)sender {
    DDLogVerbose(@"%@ declineButtonAction: %@", LOG_TAG, sender);
    
    [self hideNotification];
    if ([self.notificationViewDelegate respondsToSelector:@selector(handleDeclineActionWithNotificationId:)]) {
        [self.notificationViewDelegate handleDeclineActionWithNotificationId:self.notificationId];
    }
}

- (void)hideNotification {
    DDLogVerbose(@"%@ hideNotification", LOG_TAG);
    
    if (self.hidden) {
        return;
    }
    self.hidden = YES;
    
    if (self.notificationSound) {
        [self.notificationSound dispose];
    }
    [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.frame = CGRectMake(0., -self.frameHeight + DESIGN_NOTIFICATION_TOP * Design.HEIGHT_RATIO, self.frameWidth, self.frameHeight);
    }
                     completion:^(BOOL finished) {
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
    self.avatarView.image = self.avatar;
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    if ([self.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    }
    
    if (self.actionButtons) {
        self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
        self.notificationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
        
        self.declineButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
        self.declineButtonLeadingConstraint.constant *= Design.WIDTH_RATIO;
        self.declineButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
        self.declineButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
        
        CALayer *declineButtonLayer = self.declineButton.layer;
        declineButtonLayer.cornerRadius = 6.f;
        declineButtonLayer.masksToBounds = YES;
        [self.declineButton setBackgroundColor:Design.BUTTON_RED_COLOR];
        self.declineButton.titleLabel.font = Design.FONT_BOLD28;
        [self.declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.declineButton setTitle:TwinmeLocalizedString(@"notification_center_cancel", nil) forState:UIControlStateNormal];
        
        self.acceptButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
        self.acceptButtonTrailingConstraint.constant *= Design.WIDTH_RATIO;
        self.acceptButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
        self.acceptButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
        
        CALayer *acceptButtonLayer = self.acceptButton.layer;
        acceptButtonLayer.cornerRadius = 6.f;
        acceptButtonLayer.masksToBounds = YES;
        [self.acceptButton setBackgroundColor:Design.BLUE_NORMAL];
        self.acceptButton.titleLabel.font = Design.FONT_BOLD28;
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.acceptButton setTitle:TwinmeLocalizedString(@"application_accept", nil) forState:UIControlStateNormal];
    }
    
    self.notificationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.notificationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.notificationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:DESIGN_NOTIFICATION_LINE_HEIGHT * Design.HEIGHT_RATIO];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    if (self.actionButtons) {
        [style setAlignment:NSTextAlignmentCenter];
    }
    
    NSMutableAttributedString *notificationAttributedString = [[NSMutableAttributedString alloc] initWithString:self.title_ attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR28 forKey:NSFontAttributeName]];
    [notificationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    NSAttributedString *messageAttributedString;
    @try {
        messageAttributedString = [NSString formatText:self.message fontSize:Design.FONT_REGULAR32.pointSize fontColor:Design.FONT_COLOR_DEFAULT fontSearch:nil];
    } @catch (NSException *exception) {
        messageAttributedString = [[NSMutableAttributedString alloc] initWithString:self.message attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR32 forKey:NSFontAttributeName]];
    }
    
    [notificationAttributedString appendAttributedString:messageAttributedString];
    [notificationAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, notificationAttributedString.length)];
    self.notificationLabel.attributedText = notificationAttributedString;
}

@end
