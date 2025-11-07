/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuConversationButtonView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_HEIGHT_INSET = 24;
static CGFloat DESIGN_LEFT_INSET = 8;
static CGFloat DESIGN_INPUT_BAR_MARGIN = 10;

//
// Interface: MenuConversationButtonView
//

#undef LOG_TAG
#define LOG_TAG @"MenuConversationButtonView"


@interface MenuConversationButtonView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;

@end

//
// Implementation: RecordButtonView
//

@implementation MenuConversationButtonView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuConversationButtonView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)editMode:(BOOL)enable {
    DDLogVerbose(@"%@ editMode: %@", LOG_TAG, enable ? @"YES" : @"NO");
    
    self.menuView.hidden = enable;
    self.closeView.hidden = !enable;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat recordViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2) + DESIGN_INPUT_BAR_MARGIN;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:recordViewHeight];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:DESIGN_LEFT_INSET + recordViewHeight];
    
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    
    self.menuViewHeightConstraint.constant = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
        
    self.menuView.userInteractionEnabled = YES;
    self.menuView.backgroundColor = Design.MAIN_COLOR;
    self.menuView.clipsToBounds = YES;
    self.menuView.layer.cornerRadius = self.menuViewHeightConstraint.constant * 0.5;
    
    self.menuImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.menuImageView.tintColor = [UIColor whiteColor];
    
    self.closeImageView.tintColor = Design.BLACK_COLOR;
}

@end
