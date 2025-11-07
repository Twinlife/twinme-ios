/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "InvitationCodeShareView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif


//
// Interface: AbstractConfirmView ()
//

@interface InvitationCodeShareView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;

@end

//
// Implementation: InvitationCodeShareView
//

#undef LOG_TAG
#define LOG_TAG @"InvitationCodeShareView"

@implementation InvitationCodeShareView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"InvitationCodeShareView" owner:self options:nil];
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
    
    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabel.font = Design.FONT_BOLD88;
    self.messageLabel.font = Design.FONT_MEDIUM36;
    self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm", nil);
        
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
 
    [super updateFont];
    
    self.titleLabel.font = Design.FONT_BOLD88;
    self.messageLabel.font = Design.FONT_MEDIUM36;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
