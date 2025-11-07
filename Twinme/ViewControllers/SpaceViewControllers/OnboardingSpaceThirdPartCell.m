/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "OnboardingSpaceThirdPartCell.h"

#import <Utils/NSString+Utils.h>

#import "OnboardingSpaceViewController.h"

#import <TwinmeCommon/Design.h>

//
// Interface: OnboardingSpaceThirdPartCell
//

@interface OnboardingSpaceThirdPartCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *onboardingImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextView *onboardingTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *doNotShowLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *doNotShowView;

@end

@implementation OnboardingSpaceThirdPartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.onboardingImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.onboardingTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.onboardingTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.onboardingTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.onboardingTextView.font = Design.FONT_MEDIUM32;
    self.onboardingTextView.editable = NO;
    self.onboardingTextView.selectable = NO;
    self.onboardingTextView.textContainerInset = UIEdgeInsetsZero;
    self.onboardingTextView.textContainer.lineFragmentPadding = 0;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_4", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_5", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_6", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_7", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_8", nil)];
    self.onboardingTextView.text = message;
    
    self.createViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.createViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.createViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.createView.backgroundColor = Design.MAIN_COLOR;
    self.createView.userInteractionEnabled = YES;
    self.createView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.createView.clipsToBounds = YES;
    [self.createView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCreateTapGesture:)]];
    
    self.createLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.createLabel.font = Design.FONT_BOLD36;
    self.createLabel.textColor = [UIColor whiteColor];
    self.createLabel.text = TwinmeLocalizedString(@"spaces_view_controller_create_new_space", nil);
    
    self.doNotShowLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.doNotShowLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.doNotShowLabel.font = Design.FONT_BOLD36;;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.doNotShowLabel.text = TwinmeLocalizedString(@"application_do_not_display", nil);
        
    self.doNotShowViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.doNotShowViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.doNotShowView.userInteractionEnabled = YES;
    [self.doNotShowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoNotShowTapGesture:)]];
}

- (void)bind:(BOOL)fromSupportSection {
    
    if (fromSupportSection) {
        self.createLabel.text = TwinmeLocalizedString(@"application_ok", nil);
        self.doNotShowView.hidden = YES;
        self.doNotShowViewHeightConstraint.constant = 0;
    } else {
        self.createLabel.text = TwinmeLocalizedString(@"spaces_view_controller_create_new_space", nil);
    }
    
    [self updateColor];
    [self updateFont];
}

- (void)handleCreateTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.onboardingSpaceDelegate respondsToSelector:@selector(didTouchCreateSpace)]) {
        [self.onboardingSpaceDelegate didTouchCreateSpace];
    }
}

- (void)handleDoNotShowTapGesture:(UITapGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateEnded && [self.onboardingSpaceDelegate respondsToSelector:@selector(didTouchDoNotDisplayAgain)]) {
        [self.onboardingSpaceDelegate didTouchDoNotDisplayAgain];
    }
}

- (void)updateFont {
    
    self.onboardingTextView.font = Design.FONT_MEDIUM32;
    self.createLabel.font = Design.FONT_BOLD36;
    self.doNotShowLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    
    self.onboardingTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
}


@end
