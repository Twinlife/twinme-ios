/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MigrationHeaderCell.h"

#import "UIMigrationStateItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MigrationHeaderCell ()
//

@interface MigrationHeaderCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

//
// Implementation: MigrationHeaderCell
//

#undef LOG_TAG
#define LOG_TAG @"MigrationHeaderCell"

@implementation MigrationHeaderCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.font = Design.FONT_MEDIUM38;
}

- (void)bindWithItem:(nonnull UIMigrationStateItem *)migrationStateItem {
    DDLogVerbose(@"%@ bind", LOG_TAG);
        
    if ([migrationStateItem getInfo] && [[migrationStateItem getInfo] length] > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[migrationStateItem getTitle] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
        if ([migrationStateItem getInfo]) {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[migrationStateItem getInfo] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        self.messageLabel.attributedText = attributedString;
    } else {
        self.messageLabel.font = Design.FONT_MEDIUM36;
        self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
        self.messageLabel.text = [migrationStateItem getTitle];
    }
}

@end
