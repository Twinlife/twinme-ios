/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "OnboardingSpaceSecondPartCell.h"

#import <Utils/NSString+Utils.h>

#import "OnboardingSpaceViewController.h"

#import <TwinmeCommon/Design.h>

//
// Interface: OnboardingSpaceSecondPartCell
//

@interface OnboardingSpaceSecondPartCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *onboardingImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextView *onboardingTextView;

@end

@implementation OnboardingSpaceSecondPartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.onboardingImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.onboardingTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingTextViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.onboardingTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.onboardingTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.onboardingTextView.font = Design.FONT_MEDIUM32;
    self.onboardingTextView.editable = NO;
    self.onboardingTextView.selectable = NO;
    self.onboardingTextView.textContainerInset = UIEdgeInsetsZero;
    self.onboardingTextView.textContainer.lineFragmentPadding = 0;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_1", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_2", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_3", nil)];
    
    self.onboardingTextView.text = message;
}

- (void)bind {
    
    [self.onboardingTextView setContentOffset:CGPointZero];

    [self updateColor];
    [self updateFont];
}

- (void)updateColor {
    
    self.onboardingTextView.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    
    self.onboardingTextView.font = Design.FONT_MEDIUM32;
}

@end
