/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AccountMigrationCell.h"

#import "UIAccountMigrationItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AccountMigrationCell ()
//

@interface AccountMigrationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

//
// Implementation: AccountMigrationCell
//

#undef LOG_TAG
#define LOG_TAG @"AccountMigrationCell"

@implementation AccountMigrationCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.roundedViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.roundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.roundedView.clipsToBounds = YES;
    self.roundedView.alpha = 0.5f;
    self.roundedView.layer.cornerRadius = self.roundedViewHeightConstraint.constant * 0.5f;
    self.roundedView.layer.backgroundColor = Design.MAIN_COLOR.CGColor;
    
    self.positionLabel.textColor = [UIColor whiteColor];
    self.positionLabel.font = Design.FONT_BOLD36;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)bindWithItem:(nonnull UIAccountMigrationItem *)accountMigrationItem {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, accountMigrationItem);
    
    self.positionLabel.text = [NSString stringWithFormat:@"%d", [accountMigrationItem getPosition]];
    self.messageLabel.text = [accountMigrationItem getText];
    
    [self updateFont];
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.roundedView.layer.backgroundColor = Design.MAIN_COLOR.CGColor;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.positionLabel.font = Design.FONT_BOLD36;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
