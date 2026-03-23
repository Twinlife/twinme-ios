/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupContentCell.h"

#import "UIBackupContent.h"
#import "UIRestoreItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupContentCell ()
//

@interface BackupContentCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: BackupContentCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupContentCell"

@implementation BackupContentCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.contentLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLabel.font = Design.FONT_REGULAR34;
    self.contentLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.valueLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabel.font = Design.FONT_REGULAR32;
    self.valueLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bind:(UIBackupContent *)backupContent hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, backupContent);
    
    self.iconView.image = [backupContent getContentIcon];
    self.contentLabel.text = [backupContent getContentTitle];
    self.valueLabel.text = [NSString stringWithFormat:@"%d", [backupContent getContentCount]];
    self.separatorView.hidden = hideSeparator;
}

- (void)bind:(UIRestoreItem *)restoreItem backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, restoreItem);
    
    self.contentView.backgroundColor = backgroundColor;
    
    if ([restoreItem getIcon]) {
        self.iconView.image = [restoreItem getIcon];
        
        if ([restoreItem getColor]) {
            self.iconView.image = [self.iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.iconView setTintColor:[restoreItem getColor]];
        } else {
            [self.iconView setTintColor:nil];
        }
    }
    
    self.contentLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.contentLabel.text = [restoreItem getText];
    
    if ([restoreItem getValue] != -1) {
        self.valueLabel.text = [NSString stringWithFormat:@"%d", [restoreItem getValue]];
    } else {
        self.valueLabel.text = @"";
    }
    
    
    self.separatorView.hidden = hideSeparator;
}


@end
