/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ResetInvitationConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define ICON_BACKGROUND_COLOR [UIColor colorWithRed:213./255. green:213./255. blue:213./255. alpha:1.0]

//
// Implementation: ResetInvitationConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"ResetInvitationConfirmView"

@implementation ResetInvitationConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ResetInvitationConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.confirmLabel.text = TwinmeLocalizedString(@"fullscreen_qrcode_view_controller_generate_code_title", nil);
    
    self.iconView.backgroundColor = ICON_BACKGROUND_COLOR;
    self.iconImageView.tintColor = [UIColor whiteColor];
    
    self.bulletView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
