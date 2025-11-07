/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuIconCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MenuIconCell
//

@interface MenuIconCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: MenuIconCell
//

#undef LOG_TAG
#define LOG_TAG @"MenuIconCell"

@implementation MenuIconCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.font = Design.FONT_REGULAR34;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)bindWithTitle:(NSString *)title icon:(NSString *)icon hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithTitle: %@ icon: %@ hideSeparator: %d", LOG_TAG, title, icon, hideSeparator);
        
    self.titleLabel.text = title;
    self.iconView.image = [UIImage imageNamed:icon];
    self.iconView.image = [self.iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconView.tintColor = Design.BLACK_COLOR;
    self.separatorView.hidden = hideSeparator;
}

@end
