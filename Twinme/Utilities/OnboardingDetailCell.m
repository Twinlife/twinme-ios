/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "OnboardingDetailCell.h"

#import <TwinmeCommon/Design.h>

#import "UIPremiumFeatureDetail.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: OnboardingDetailCell
//

@interface OnboardingDetailCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

//
// Implementation: OnboardingDetailCell
//

#undef LOG_TAG
#define LOG_TAG @"OnboardingDetailCell"

@implementation OnboardingDetailCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.title.font = Design.FONT_MEDIUM30;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)bindWithPremiumFeatureDetail:(nonnull UIPremiumFeatureDetail *)premiumFeatureDetail {
    DDLogVerbose(@"%@ bindWithPremiumFeatureDetail: %@", LOG_TAG, premiumFeatureDetail);
    
    self.title.text = premiumFeatureDetail.featureDetailMessage;
    self.iconView.image = premiumFeatureDetail.featureDetailImage;
        
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end
