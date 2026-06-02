/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupConfirmCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupConfirmCell ()
//

@interface BackupConfirmCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@property (nonatomic) BOOL confirmRead;

@end

//
// Implementation: BackupConfirmCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupConfirmCell"

@implementation BackupConfirmCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.confirmRead = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleConfirmTapGesture:)];
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
    
    self.confirmLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.confirmLabel.font = Design.FONT_REGULAR32;
    self.confirmLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.confirmLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_confirm_message", @"LocalizableBackup", nil);
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    self.checkMarkImageView.hidden = !self.confirmRead;
    
    [self updateColor];
    [self updateFont];
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.backupConfirmDelegate respondsToSelector:@selector(didTapConfirmBackup:)]) {
        self.confirmRead = !self.confirmRead;
        [self.backupConfirmDelegate didTapConfirmBackup:self.confirmRead];
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.confirmLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.confirmLabel.font = Design.FONT_REGULAR32;
}

@end
