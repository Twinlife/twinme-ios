/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupFooterCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupFooterCell ()
//

@interface BackupFooterCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@property BOOL actionEnable;

@end

//
// Implementation: BackupFooterCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupFooterCell"

@implementation BackupFooterCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.actionEnable = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.actionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.backgroundColor = Design.MAIN_COLOR;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.actionView.clipsToBounds = YES;
    self.actionView.isAccessibilityElement = YES;
    self.actionView.accessibilityLabel = TwinmeLocalizedStringFromTable(@"backup_view_backup", @"LocalizableBackup", nil);
    [self.actionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionTapGesture:)]];
    
    self.actionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.actionLabel.font = Design.FONT_BOLD36;
    self.actionLabel.textColor = [UIColor whiteColor];
    self.actionLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_backup", @"LocalizableBackup", nil);
}

- (void)bindWithTitle:(NSString *)title enable:(BOOL)enable backgroundColor:(UIColor *)backgroundColor {
    DDLogVerbose(@"%@ bindWithTitle: %@enable: %@", LOG_TAG, title, enable ? @"YES":@"NO");
    
    self.actionEnable = enable;
    self.actionView.alpha =  enable ? 1.0f : 0.5f;
    
    self.actionView.accessibilityLabel = title;
    self.actionLabel.text = title;
    
    self.contentView.backgroundColor = backgroundColor;
}

- (void)handleActionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleActionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.backupFooterDelegate respondsToSelector:@selector(didTapFooterAction)] && self.actionEnable) {
        [self.backupFooterDelegate didTapFooterAction];
    }
}

@end
