/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "InvitationCodeConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define ICON_BACKGROUND_COLOR [UIColor colorWithRed:213./255. green:213./255. blue:213./255. alpha:1.0]

//
// Implementation: InvitationCodeConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"InvitationCodeConfirmView"

@implementation InvitationCodeConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"InvitationCodeConfirmView" owner:self options:nil];
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
    
    self.confirmLabel.text = TwinmeLocalizedString(@"application_accept", nil);
    
    self.iconView.backgroundColor = ICON_BACKGROUND_COLOR;
    self.iconImageView.tintColor = [UIColor whiteColor];
    
    self.bulletView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
   
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    if (self.forceDarkMode) {
        self.cancelLabel.textColor = [UIColor whiteColor];
    } else {
        self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

@end
