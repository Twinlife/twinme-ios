/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuItemCell.h"

#import <TwinmeCommon/Design.h>
#import "UIMenuItemAction.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MenuItemCell ()
//

@interface MenuItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: MenuItemCell
//

#undef LOG_TAG
#define LOG_TAG @"MenuItemCell"

@implementation MenuItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor colorWithRed:116./255. green:116./255. blue:116./255. alpha:0.08];
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_REGULAR34;
    self.titleLabel.textColor = Design.BLACK_COLOR;
    
    self.menuImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.menuImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.menuImageView.tintColor = [UIColor blackColor];
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)bindWithMenuItem:(UIMenuItemAction *)menuItemAction enabled:(BOOL)enabled hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithMenuItem: %@ enable: %@", LOG_TAG, menuItemAction, enabled ? @"YES":@"NO");
    
    self.titleLabel.text = menuItemAction.title;
    self.menuImageView.image = menuItemAction.image;
    
    if (enabled) {
        self.titleLabel.alpha = 1.0;
        self.menuImageView.alpha = 1.0;
    } else {
        self.titleLabel.alpha = 0.5;
        self.menuImageView.alpha = 0.5;
    }
    
    if (menuItemAction.actionType == ActionTypeDelete) {
        self.menuImageView.tintColor = Design.DELETE_COLOR_RED;
    } else {
        self.menuImageView.tintColor = Design.BLACK_COLOR;
    }
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.titleLabel.textColor = Design.BLACK_COLOR;
}

@end

