/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CoachMarkViewController.h"

#import "CoachMarkView.h"
#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CoachMarkViewController ()
//

@interface CoachMarkViewController ()

@property (weak, nonatomic) IBOutlet CoachMarkView *coachMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clippedViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clippedViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clippedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clippedViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *clippedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) CoachMark *coachMark;

@property (nonatomic) BOOL needsUpdateConstraints;

@end

//
// Implementation: CoachMarkViewController
//

#undef LOG_TAG
#define LOG_TAG @"CoachMarkViewController"

@implementation CoachMarkViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _needsUpdateConstraints = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)initWithCoachMark:(CoachMark *)coachMark {
    DDLogVerbose(@"%@ initWithCoachMark: %@", LOG_TAG, coachMark);

    self.coachMark = coachMark;
}

- (CoachMark *)getCoachMark {
    DDLogVerbose(@"%@ getCoachMark", LOG_TAG);
    
    return self.coachMark;
}

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showInView", LOG_TAG);
        
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    
    [self initViews];
    [self updateConstraints];
    [self.coachMarkView clipView:self.coachMark.featureRect radius:self.coachMark.featureRadius];

    self.view.alpha = 0.;
    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 1.;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)closeView {
    DDLogVerbose(@"%@ closeView", LOG_TAG);
    
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];

    if (self.coachMark.featureRect.size.width == Design.DISPLAY_WIDTH) {
        self.clippedViewTrailingConstraint.constant = 0;
    } else {
        self.clippedViewTrailingConstraint.constant = self.view.frame.size.width - (self.coachMark.featureRect.size.width + self.coachMark.featureRect.origin.x);
    }
    
    self.clippedViewBottomConstraint.constant = Design.DISPLAY_HEIGHT - (self.coachMark.featureRect.size.height + self.coachMark.featureRect.origin.y);
    self.clippedViewHeightConstraint.constant = self.coachMark.featureRect.size.height;
    self.clippedViewWidthConstraint.constant = self.coachMark.featureRect.size.width;

    self.clippedView.backgroundColor = [UIColor clearColor];
    self.clippedView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapFeatureGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapFeatureGesture:)];
    [self.clippedView addGestureRecognizer:tapFeatureGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressFeatureGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFeatureGesture:)];
    [self.clippedView addGestureRecognizer:longPressFeatureGestureRecognizer];
    
    self.messageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.messageView.backgroundColor = [UIColor whiteColor];
    self.messageView.clipsToBounds = YES;
    self.messageView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.font = Design.FONT_MEDIUM34;
    self.messageLabel.text = self.coachMark.message;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self.coachMarkView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view bringSubviewToFront:self.clippedView];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCoachMarkOverlay:)]) {
            [self.delegate didTapCoachMarkOverlay:self];
        }
    }
}

- (void)handleTapFeatureGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTapFeatureGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCoachMarkFeature:)]) {
            [self.delegate didTapCoachMarkFeature:self];
        }
    }
}

- (void)handleLongPressFeatureGesture:(UILongPressGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLongPressFeatureGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLongPressCoachMarkFeature:)]) {
            [self.delegate didLongPressCoachMarkFeature:self];
        }
    }
}

- (void)updateConstraints {
    DDLogVerbose(@"%@ updateConstraints", LOG_TAG);
    
    if (!self.coachMark.onTop) {
        CGFloat constantBottom = self.messageViewBottomConstraint.constant;
        self.messageViewBottomConstraint.active = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.clippedView attribute:NSLayoutAttributeBottom multiplier:1 constant:constantBottom]];
    }
    
    if (self.coachMark.alignLeft) {
        CGFloat constantLeading = self.messageViewLeadingConstraint.constant;
        CGFloat constantTrailing = self.messageViewTrailingConstraint.constant;
        self.messageViewLeadingConstraint.active = NO;
        self.messageViewTrailingConstraint.active = NO;
                
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.clippedView attribute:NSLayoutAttributeLeading multiplier:1 constant:constantLeading]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.messageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:constantTrailing]];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_MEDIUM34;
}

@end
