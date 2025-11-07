/*
 *  Copyright (c) 2022-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallHoldView.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_CONTAINER_COLOR [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1]

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_MIN_MARGIN_ACTION = 34;
static const CGFloat DESIGN_AVATAR_RADIUS = 6;


//
// Interface: CallHoldView ()
//

@interface CallHoldView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *hangupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *hangupImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swapViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swapViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *swapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swapImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *swapImageView;

@end

#undef LOG_TAG
#define LOG_TAG @"CallHoldView"

@implementation CallHoldView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogVerbose(@"%@ initWithCoder", LOG_TAG);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *playerView = [[[NSBundle mainBundle] loadNibNamed:@"CallHoldView" owner:self options:nil] objectAtIndex:0];
        playerView.frame = self.bounds;
        playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:playerView];
        [self initViews];
    }
    
    return self;
}

- (void)setCallInfo:(NSString *)name avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ setCallInfo: %@ avatar: %@", LOG_TAG, name, avatar);
    
    self.nameLabel.text = name;
    self.avatarImageView.image = avatar;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewWidthConstraint.constant = Design.DISPLAY_WIDTH - (DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO * 2);
    
    self.containerView.backgroundColor = DESIGN_CONTAINER_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.avatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.avatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = DESIGN_AVATAR_RADIUS;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.hangupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hangupViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.hangupView.userInteractionEnabled = YES;
    self.hangupView.clipsToBounds = YES;
    self.hangupView.backgroundColor = Design.BUTTON_RED_COLOR;
    self.hangupView.layer.cornerRadius = self.hangupViewHeightConstraint.constant * 0.5;
    self.hangupView.accessibilityLabel = TwinmeLocalizedString(@"audio_call_view_controller_hangup", nil);
    
    UITapGestureRecognizer *hangUpTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleHangupTapGesture:)];
    [self.hangupView addGestureRecognizer:hangUpTapGestureRecognizer];
    
    self.hangupImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.addView.userInteractionEnabled = YES;
    self.addView.clipsToBounds = YES;
    self.addView.backgroundColor = [UIColor whiteColor];
    self.addView.layer.cornerRadius = self.addViewHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *hangUpAddGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAddTapGesture:)];
    [self.addView addGestureRecognizer:hangUpAddGestureRecognizer];
    
    self.addImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addImageView.tintColor = [UIColor blackColor];
    
    self.swapViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.swapViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.swapView.userInteractionEnabled = YES;
    self.swapView.clipsToBounds = YES;
    self.swapView.backgroundColor = [UIColor whiteColor];
    self.swapView.layer.cornerRadius = self.swapViewHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *swapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwapTapGesture:)];
    [self.swapView addGestureRecognizer:swapGestureRecognizer];
    
    self.swapImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.swapImageView.tintColor = [UIColor blackColor];
}

- (void)handleHangupTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleHangupTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.callHoldDelegate respondsToSelector:@selector(onHangupHoldCall:)]) {
            [self.callHoldDelegate onHangupHoldCall:self];
        }
    }
}

- (void)handleAddTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAddTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.callHoldDelegate respondsToSelector:@selector(onAddHoldCall:)]) {
            [self.callHoldDelegate onAddHoldCall:self];
        }
    }
}

- (void)handleSwapTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSwapTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.callHoldDelegate respondsToSelector:@selector(onSwapHoldCall:)]) {
            [self.callHoldDelegate onSwapHoldCall:self];
        }
    }
}

@end
