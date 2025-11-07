/*
 *  Copyright (c) 2016-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SendButtonView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_HEIGHT_INSET = 24;
static CGFloat DESIGN_LEFT_INSET = 8;
static CGFloat DESIGN_INPUT_BAR_MARGIN = 10;
// static CGFloat DESIGN_SEND_MARGIN = 14;

//
// Interface: SendButtonView
//

#undef LOG_TAG
#define LOG_TAG @"SendButtonView"


@interface SendButtonView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;

@property (nonatomic) BOOL enable;

@end

//
// Implementation: SendButtonView
//

@implementation SendButtonView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SendButtonView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
        self.enable = NO;
        [self initViews];
    }
    return self;
}

- (void)editMode:(BOOL)enable {
    DDLogVerbose(@"%@ editMode: %@", LOG_TAG, enable ? @"YES" : @"NO");
    
    self.sendView.hidden = enable;
    self.editView.hidden = !enable;
}

- (void)setEnabled:(BOOL)enable {
    
    if (enable) {
        self.sendView.alpha = 1.0;
    } else {
        self.sendView.alpha = 0.7;
    }
    
    if (enable != self.enable) {
        self.enable = enable;
    }
}

- (BOOL)isEnabled {
    
    return self.enable;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat sendViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
        
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2) + DESIGN_INPUT_BAR_MARGIN];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(DESIGN_LEFT_INSET * 2 + sendViewHeight)];
    
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    
    self.sendViewHeightConstraint.constant = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.clipsToBounds = YES;
    self.sendView.layer.cornerRadius = self.sendViewHeightConstraint.constant * 0.5;
    
    self.sendImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.editView.backgroundColor = [UIColor colorWithRed:38./255. green:209./255. blue:160./255. alpha:1.0];
    self.editView.clipsToBounds = YES;
    self.editView.layer.cornerRadius = self.sendViewHeightConstraint.constant * 0.5;
    
    self.editImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editImageView.tintColor = [UIColor whiteColor];
    
}

@end
