/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ProxyCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ProxyCell
//

@interface ProxyCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: ProxyCell
//

#undef LOG_TAG
#define LOG_TAG @"ProxyCell"

@implementation ProxyCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithProxy:(NSString *)proxy showError:(BOOL)showError hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithProxy: %@ showError: %@ hideSeparator: %@", LOG_TAG, proxy, showError ? @"YES" : @"NO", hideSeparator ? @"YES" : @"NO");
    
    self.nameLabel.text = proxy;
    
    self.iconView.hidden = !showError;
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
