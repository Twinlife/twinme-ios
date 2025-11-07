/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuActionConversationCell.h"

#import <TwinmeCommon/Design.h>
#import "UIActionConversation.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MenuActionConversationCell ()
//

@interface MenuActionConversationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

//
// Implementation: MenuActionConversationCell
//

#undef LOG_TAG
#define LOG_TAG @"MenuActionConversationCell"

@implementation MenuActionConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.iconView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = self.iconViewHeightConstraint.constant * 0.5f;
    self.iconView.alpha = 0.f;
    
    self.iconImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_REGULAR34;
    self.titleLabel.textColor = Design.BLACK_COLOR;
    self.titleLabel.alpha = 0.f;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.titleLabel.alpha = 0.f;
    self.iconView.alpha = 0.f;
}

- (void)bindWithAction:(UIActionConversation *)actionConversation delay:(CGFloat)delay {
    DDLogVerbose(@"%@ bindWithAction: %@", LOG_TAG, actionConversation);
    
    self.titleLabel.text = actionConversation.title;
    
    self.iconView.backgroundColor = Design.WHITE_COLOR;
    
    self.iconImageView.image = actionConversation.icon;
    self.iconImageView.image = [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconImageView.tintColor = actionConversation.iconColor;
        
   [UIView animateWithDuration:0.2 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.iconView.alpha = 1.0f;
        self.titleLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
        
    [self updateColor];
    [self updateFont];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.titleLabel.textColor = Design.BLACK_COLOR;
}

@end
