/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ResetConversationConfirmView.h"

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
// Implementation: ResetConversationConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"ResetConversationConfirmView"

@implementation ResetConversationConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ResetConversationConfirmView" owner:self options:nil];
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

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.confirmLabel.text = TwinmeLocalizedString(@"main_view_reset_conversation_title", nil);
    
    self.iconView.backgroundColor = Design.DELETE_COLOR_RED;
    self.bulletView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.confirmView.backgroundColor = Design.DELETE_COLOR_RED;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
