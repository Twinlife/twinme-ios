/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "DeleteConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <Twinme/TLTwinmeAttributes.h>

#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Implementation: DeleteConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"DeleteConfirmView"

@implementation DeleteConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DeleteConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon {
    
    [super initWithTitle:title message:message avatar:avatar icon:icon];
    
    if ([avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
}

- (void)hideAvatar {
    DDLogVerbose(@"%@ hideAvatar", LOG_TAG);
    
    self.avatarContainerView.hidden = YES;
    self.avatarView.hidden = YES;
    self.bulletView.hidden = YES;
    self.iconView.hidden = YES;
    self.iconImageView.hidden = YES;
    self.avatarContainerViewTopConstraint.constant = 0;
    self.avatarContainerViewHeightConstraint.constant = 0;
}

- (void)setConfirmTitle:(NSString *)confirmTitle {
    DDLogVerbose(@"%@ setConfirmTitle: %@", LOG_TAG, confirmTitle);
    
    self.confirmLabel.text = confirmTitle;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm_deletion", nil);
    
    self.iconView.backgroundColor = Design.DELETE_COLOR_RED;
    self.bulletView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.confirmView.backgroundColor = Design.DELETE_COLOR_RED;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
