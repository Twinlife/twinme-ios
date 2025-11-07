/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeAttributes.h>

#import "AlertMessageView.h"

#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AlertMessageView ()
//

@interface AlertMessageView ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;

@property (nonatomic) UIView *overlayView;

@end

//
// Implementation: AlertMessageView
//

#undef LOG_TAG
#define LOG_TAG @"AlertMessageView"

@implementation AlertMessageView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"AlertMessageView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        _forceDarkMode = NO;
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
    DDLogVerbose(@"%@ initWithTitle: %@ message: %@", LOG_TAG, title, message);
    
    self.titleLabel.text = title;
    self.messageLabel.text = message;
}

- (void)showAlertView {
    DDLogVerbose(@"%@ showAlertView", LOG_TAG);
    
    [self updateFont];
    [self updateColor];
            
    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.3f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT - self.actionView.frame.size.height, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:nil];
}

- (void)closeAlertView {
    DDLogVerbose(@"%@ closeAlertView", LOG_TAG);
    
    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
        [self finish];
        
        if ([self.alertMessageViewDelegate respondsToSelector:@selector(didFinishCloseAlertMessageAnimation:)]) {
            [self.alertMessageViewDelegate didFinishCloseAlertMessageAnimation:self];
        }
    }];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.userInteractionEnabled = YES;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .0f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    [self insertSubview:self.overlayView atIndex:0];
    
    UITapGestureRecognizer *tapOverlayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseSwipeGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGestureRecognizer];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.actionView.layer.cornerRadius = 40 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
        
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseSwipeGesture:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.actionView addGestureRecognizer:swipeGestureRecognizer];
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;

    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_MEDIUM40;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM38;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    
    self.closeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.closeView.backgroundColor = Design.MAIN_COLOR;
    self.closeView.userInteractionEnabled = YES;
    self.closeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.closeView.clipsToBounds = YES;
    self.closeView.isAccessibilityElement = YES;
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.closeLabel.font = Design.FONT_BOLD36;
    self.closeLabel.textColor = [UIColor whiteColor];
    self.closeLabel.text = TwinmeLocalizedString(@"application_ok", nil);
}

#pragma mark - Private methods

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.alertMessageViewDelegate respondsToSelector:@selector(didCloseAlertMessage:)]) {
            [self.alertMessageViewDelegate didCloseAlertMessage:self];
        }
    }
}

- (void)handleCloseSwipeGesture:(UISwipeGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseSwipeGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.alertMessageViewDelegate respondsToSelector:@selector(didCloseAlertMessage:)]) {
            [self.alertMessageViewDelegate didCloseAlertMessage:self];
        }
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD44;
    self.messageLabel.font = Design.FONT_MEDIUM40;
    self.closeLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    if (self.forceDarkMode) {
        self.actionView.backgroundColor = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
}

@end
