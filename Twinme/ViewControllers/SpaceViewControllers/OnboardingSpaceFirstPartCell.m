/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "OnboardingSpaceFirstPartCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

//
// Interface: OnboardingSpaceFirstPartCell
//

@interface OnboardingSpaceFirstPartCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceBusinessView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceBusinessImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceBusinessLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceBusinessLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceFamilyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceFamilyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFamilyLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceFamilyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sampleSpaceFriendsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sampleSpaceFriendsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sampleSpaceFriendsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sampleSpaceFriendsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation OnboardingSpaceFirstPartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.sampleSpaceFriendsViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceFriendsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.sampleSpaceFriendsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFriendsImageView.image = [UIImage imageNamed:@"SpaceSampleFriends"];
    
    self.sampleSpaceFriendsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFriendsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sampleSpaceFamilyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceFamilyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.sampleSpaceFamilyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFamilyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceFamilyImageView.image = [UIImage imageNamed:@"SpaceSampleFamily"];
    
    self.sampleSpaceFamilyLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceFamilyLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sampleSpaceBusinessViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sampleSpaceBusinessViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.sampleSpaceBusinessImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceBusinessImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sampleSpaceBusinessImageView.image = [UIImage imageNamed:@"SpaceSampleBusiness"];
    
    self.sampleSpaceBusinessLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sampleSpaceBusinessLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.text = TwinmeLocalizedString(@"spaces_view_controller_message", nil);
}

- (void)bind {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_friends", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_friends_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceFriendsLabel.attributedText = attributedString;
    
    self.sampleSpaceFamilyView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.sampleSpaceFamilyView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sampleSpaceFamilyView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sampleSpaceFamilyView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sampleSpaceFamilyView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.sampleSpaceFamilyView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_family", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_family_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceFamilyLabel.attributedText = attributedString;
    
    self.sampleSpaceBusinessView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.sampleSpaceBusinessView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sampleSpaceBusinessView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sampleSpaceBusinessView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sampleSpaceBusinessView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.sampleSpaceBusinessView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_business", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"spaces_view_controller_sample_business_name", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.sampleSpaceBusinessLabel.attributedText = attributedString;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.font = Design.FONT_MEDIUM32;
}

@end
