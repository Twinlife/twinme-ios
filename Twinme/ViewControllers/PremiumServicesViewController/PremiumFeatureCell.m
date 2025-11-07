/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PremiumFeatureCell.h"

#import <TwinmeCommon/Design.h>

#import "UIPremiumFeature.h"
#import "UIPremiumFeatureDetail.h"

static float DESIGN_CONTAINER_RADIUS = 28;
static float DESIGN_CONTAINER_MARGIN = 40;
static float DESIGN_BORDER_SIZE = 2;

//
// Interface: PremiumFeatureCell ()
//

@interface PremiumFeatureCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *premiumImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailOneImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailOneImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *featureDetailOneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailOneLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailOneLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailOneLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *featureDetailOneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailTwoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *featureDetailTwoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailTwoLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *featureDetailTwoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailThreeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *featureDetailThreeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailThreeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *featureDetailThreeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailFourImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *featureDetailFourImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailFourLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featureDetailFourLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *featureDetailFourLabel;

@end

@implementation PremiumFeatureCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
        
    self.backgroundColor = [UIColor blackColor];
    
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewWidthConstraint.constant = Design.DISPLAY_WIDTH - (DESIGN_CONTAINER_MARGIN * Design.WIDTH_RATIO * 2);
    
    self.containerView.backgroundColor = Design.WHITE_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.cornerRadius = DESIGN_CONTAINER_RADIUS;
    
    self.logoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_MEDIUM34;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.subTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.subTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.subTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.subTitleLabel.font = Design.FONT_MEDIUM32;
    self.subTitleLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    
    self.premiumImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.premiumImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.premiumImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailOneImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.featureDetailOneImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.featureDetailOneLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.featureDetailOneLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.featureDetailOneLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailOneLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailOneLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailOneLabel.adjustsFontSizeToFitWidth = YES;
    
    self.featureDetailTwoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailTwoLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailTwoLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailTwoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailTwoLabel.adjustsFontSizeToFitWidth = YES;
    
    self.featureDetailThreeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailThreeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailThreeLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailThreeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailThreeLabel.adjustsFontSizeToFitWidth = YES;
    
    self.featureDetailFourImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailFourLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.featureDetailFourLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.featureDetailFourLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailFourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailFourLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)bind:(UIPremiumFeature *)premiumFeature showBorder:(BOOL)showBorder {
    
    if (showBorder) {
        self.containerView.layer.borderWidth = DESIGN_BORDER_SIZE;
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.containerView.layer.borderWidth = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    
    self.titleLabel.text = [premiumFeature getTitle];
    self.subTitleLabel.text = [premiumFeature getSubTitle];
    self.premiumImageView.image = [premiumFeature getImage];
    
    if (premiumFeature.featureDetails.count > 3) {
        UIPremiumFeatureDetail *premiumFeatureDetail1 = [premiumFeature.featureDetails objectAtIndex:0];
        UIPremiumFeatureDetail *premiumFeatureDetail2 = [premiumFeature.featureDetails objectAtIndex:1];
        UIPremiumFeatureDetail *premiumFeatureDetail3 = [premiumFeature.featureDetails objectAtIndex:2];
        UIPremiumFeatureDetail *premiumFeatureDetail4 = [premiumFeature.featureDetails objectAtIndex:3];
        
        self.featureDetailOneLabel.text = premiumFeatureDetail1.featureDetailMessage;
        self.featureDetailTwoLabel.text = premiumFeatureDetail2.featureDetailMessage;
        self.featureDetailThreeLabel.text = premiumFeatureDetail3.featureDetailMessage;
        self.featureDetailFourLabel.text = premiumFeatureDetail4.featureDetailMessage;
        
        self.featureDetailOneImageView.image = premiumFeatureDetail1.featureDetailImage;
        self.featureDetailTwoImageView.image = premiumFeatureDetail2.featureDetailImage;
        self.featureDetailThreeImageView.image = premiumFeatureDetail3.featureDetailImage;
        self.featureDetailFourImageView.image = premiumFeatureDetail4.featureDetailImage;
    }
    
    [self updateColor];
}

- (void)updateFont {
    
    self.titleLabel.font = Design.FONT_MEDIUM34;
    self.subTitleLabel.font = Design.FONT_MEDIUM32;
    self.featureDetailOneLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailTwoLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailThreeLabel.font = Design.FONT_MEDIUM30;
    self.featureDetailFourLabel.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    
    self.containerView.backgroundColor = Design.WHITE_COLOR;
    self.containerView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.subTitleLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.featureDetailOneLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailTwoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailThreeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.featureDetailFourLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
