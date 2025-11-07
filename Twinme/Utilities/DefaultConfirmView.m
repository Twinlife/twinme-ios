/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "DefaultConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_LARGE_IMAGE_HEIGHT = 400;

//
// Interface: DefaultConfirmView ()
//

@interface DefaultConfirmView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;

@end

//
// Implementation: DefaultConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"DefaultConfirmView"

@implementation DefaultConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DefaultConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image avatar:(UIImage *)avatar action:(NSString *)action actionColor:(UIColor *)actionColor cancel:(NSString *)cancel {
    DDLogVerbose(@"%@ initWithTitle: %@ message: %@ image: %@ action: %@ actionColor: %@", LOG_TAG, title, message, image, action, actionColor);
    
    self.actionImageView.image = image;
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    self.confirmLabel.text = action;
    
    if (cancel) {
        self.cancelLabel.text = cancel;
    }
    
    if (!title) {
        self.titleLabel.hidden = YES;
        self.titleLabelTopConstraint.constant = 0;
    } else {
        self.titleLabel.text = title;
    }
    
    if (actionColor) {
        self.confirmView.backgroundColor = actionColor;
    }
    
    if (!image && !avatar) {
        self.actionImageView.hidden = YES;
        self.actionImageViewHeightConstraint.constant = 0;
        self.actionImageViewTopConstraint.constant = 0;
    } else if (avatar) {
        self.avatarView.image = avatar;
        self.avatarContainerView.hidden = NO;
        self.actionImageViewHeightConstraint.constant = self.avatarContainerViewHeightConstraint.constant;
    }
}

- (void)hideCancelAction {
    DDLogVerbose(@"%@ hideCancelAction", LOG_TAG);
    
    self.cancelView.hidden = YES;
    self.cancelViewHeightConstraint.constant = 0;
    
    if (self.cancelViewBottomConstraint.constant == 0) {
        self.cancelViewBottomConstraint.constant = self.actionImageViewTopConstraint.constant;
    }
}

- (void)useLargeImage {
    DDLogVerbose(@"%@ useLargeImage", LOG_TAG);
    
    self.actionImageViewHeightConstraint.constant = DESIGN_LARGE_IMAGE_HEIGHT * Design.HEIGHT_RATIO;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.actionImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.actionImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.bulletView.hidden = YES;
    self.iconView.hidden = YES;
    self.avatarContainerView.hidden = YES;
            
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
