/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MigrationDeviceView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MigrationDeviceView ()
//

@interface MigrationDeviceView ()

@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notchViewViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notchViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notchViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *notchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *progressView;

@property (nonatomic) CGFloat progressPercentage;

@property (nonatomic) BOOL initColors;

@end

//
// Implementation: MigrationDeviceView
//

#undef LOG_TAG
#define LOG_TAG @"MigrationDeviceView"

@implementation MigrationDeviceView

#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];

    return self;
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];

    [self initViews];
}

#pragma mark - Public methods

- (void)updateColors:(nonnull UIColor *)backgroundColor progressColor:(nonnull UIColor *)progressColor {
    
    if (!self.initColors) {
        self.initColors = YES;
        self.deviceView.backgroundColor = backgroundColor;
        self.progressView.backgroundColor = progressColor;
    }
}

- (void)updateProgress:(CGFloat)progress animated:(BOOL)animated {
    DDLogVerbose(@"%@ updateProgress: %f animated: %d", LOG_TAG, progress, animated);
    
    self.progressPercentage = progress;
    [self updateProgressViewAnimated:animated];
}

#pragma mark - UIView

- (void)layoutSubviews {
    DDLogVerbose(@"%@ layoutSubviews", LOG_TAG);
    
    [super layoutSubviews];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
            
    self.initColors = NO;
    
    self.deviceView.clipsToBounds = YES;
    self.deviceView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.deviceView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    self.deviceView.layer.borderWidth = 2.f;
    self.deviceView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.notchViewViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.notchViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.notchViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.notchView.clipsToBounds = YES;
    self.notchView.layer.cornerRadius = self.notchViewHeightConstraint.constant * 0.5f;
    self.notchView.backgroundColor = Design.BLACK_COLOR;
    
    self.progressViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressViewTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.progressView.backgroundColor = [UIColor clearColor];
    
    [self updateProgressViewAnimated:NO];
}

- (void)updateProgressViewAnimated:(BOOL)animated {
    DDLogVerbose(@"%@ updateProgressViewAnimated: %d", LOG_TAG, animated);
    
    if (!self.deviceView || !self.progressView || !self.progressViewTopConstraint || !self.progressViewBottomConstraint) {
        return;
    }
    
    CGFloat availableHeight = CGRectGetHeight(self.deviceView.bounds) * self.progressPercentage;
    if (availableHeight <= 0.0f) {
        return;
    }
    
    self.progressViewTopConstraint.constant = availableHeight;
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.deviceView layoutIfNeeded];
        }];
    } else {
        [self.deviceView layoutIfNeeded];
    }
}

@end
