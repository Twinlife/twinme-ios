/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SettingsIconCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SettingsIconCell
//

@interface SettingsIconCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SettingsIconCell
//

#undef LOG_TAG
#define LOG_TAG @"SettingsIconCell"

@implementation SettingsIconCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.title.font = Design.FONT_REGULAR32;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.accessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.accessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.accessoryImageView.image = [self.accessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithTitle:(NSString *)title icon:(UIImage *)icon textColor:(UIColor *)textColor iconTintColor:(UIColor *)iconTintColor hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithTitle: %@ icon: %@ textColor: %@ iconTintColor: %@ hideSeparator: %@", LOG_TAG, title, icon, textColor, iconTintColor, hideSeparator ? @"YES" : @"NO");
    
    self.title.text = title;
    self.title.textColor = textColor;
    
    self.iconView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconView.tintColor = iconTintColor;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
