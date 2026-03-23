/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupCell.h"

#import <TwinmeCommon/Design.h>

#import "UIBackupInfo.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupCell ()
//

@interface BackupCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backupLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backupLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *backupLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: BackupCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupCell"

@implementation BackupCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backupLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.backupLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.backupLabel.font = Design.FONT_REGULAR32;
    self.backupLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
}

- (void)bindWithBackupInfo:(UIBackupInfo *)backupInfo hiddenSeparator:(BOOL)hiddenSeparator {
    DDLogVerbose(@"%@ bindWithBackupInfo: %@", LOG_TAG, backupInfo);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[backupInfo getId] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[backupInfo getDate] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.backupLabel.attributedText = attributedString;
    
    self.separatorView.hidden = hiddenSeparator;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.backgroundColor = Design.WHITE_COLOR;
}

@end

