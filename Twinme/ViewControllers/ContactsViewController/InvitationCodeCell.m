/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "InvitationCodeCell.h"

#import <TwinmeCommon/Design.h>

#import "UIInvitationCode.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InvitationCodeCell ()
//

@interface InvitationCodeCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: InvitationCodeCell
//

#undef LOG_TAG
#define LOG_TAG @"InvitationCodeCell"

@implementation InvitationCodeCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.codeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.codeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.codeLabel.font = Design.FONT_REGULAR32;
    self.codeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
}

- (void)bindWithInvitation:(UIInvitationCode *)invitationCode hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithInvitation: %@ hideSeparator: %@", LOG_TAG, invitationCode, hideSeparator ? @"YES" : @"NO");
    
    UIColor *codeColor = [invitationCode hasExpired] ? Design.FONT_COLOR_GREY : Design.FONT_COLOR_DEFAULT;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:invitationCode.code  attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM38, NSFontAttributeName, codeColor, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[invitationCode formatExpirationDate] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.codeLabel.attributedText = attributedString;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.backgroundColor = Design.WHITE_COLOR;
}

@end

