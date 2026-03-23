/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupInfoCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupInfoCell ()
//

@interface BackupInfoCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

//
// Implementation: BackupInfoCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupInfoCell"

@implementation BackupInfoCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.backgroundColor = Design.GREY_ITEM;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.iconView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.iconView.backgroundColor = Design.WHITE_COLOR;
    
    self.iconViewImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.infoLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.infoLabel.font = Design.FONT_MEDIUM34;
    self.infoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithTitle:(NSString *)title {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    self.infoLabel.text = title;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.infoLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.containerView.backgroundColor = Design.GREY_ITEM;
    self.iconView.backgroundColor = Design.WHITE_COLOR;
    self.infoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
