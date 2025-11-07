/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "OnboardingExternalCallViewController.h"
#import "OnboardingExternalCallCell.h"

#import <TwinmeCommon/Design.h>
#import "UIOnboarding.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_TEXT_BOTTOM = 200;
static const CGFloat DESIGN_DO_NOT_SHOW_VIEW_HEIGHT = 140;

//
// Interface: OnboardingExternalCallCell ()
//

@interface OnboardingExternalCallCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *onboardingImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextView *onboardingTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createViewBottomConstraint;
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

//
// Implementation: OnboardingExternalCallCell
//

#undef LOG_TAG
#define LOG_TAG @"OnboardingExternalCallCell"

@implementation OnboardingExternalCallCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
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
    
    self.createViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.createViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
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
    self.createLabel.text = TwinmeLocalizedString(@"history_view_controller_create_link", nil);
    
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

- (void)bindWithOnboarding:(UIOnboarding *)uiOnboarding fromSupportSection:(BOOL)fromSupportSection {
    DDLogVerbose(@"%@ bindWithOnboarding: %@", LOG_TAG, uiOnboarding);
    
    self.onboardingImageView.image = [uiOnboarding getImage];
    self.onboardingTextView.text = [uiOnboarding getMessage];
    
    self.createView.hidden = [uiOnboarding hideAction];
    self.doNotShowView.hidden = [uiOnboarding hideAction];
    
    if ([uiOnboarding hideAction]) {
        self.onboardingTextViewBottomConstraint.constant = self.createViewBottomConstraint.constant;
    } else {
        
        if (fromSupportSection) {
            self.createLabel.text = TwinmeLocalizedString(@"application_ok", nil);
            self.doNotShowView.hidden = YES;
            self.createViewBottomConstraint.constant = 0;
            self.doNotShowViewHeightConstraint.constant = 0;
            self.onboardingTextViewBottomConstraint.constant = self.createViewHeightConstraint.constant;
        } else {
            self.createLabel.text = TwinmeLocalizedString(@"history_view_controller_create_link", nil);
            self.doNotShowViewHeightConstraint.constant = DESIGN_DO_NOT_SHOW_VIEW_HEIGHT * Design.HEIGHT_RATIO;
            self.createViewBottomConstraint.constant = DESIGN_DO_NOT_SHOW_VIEW_HEIGHT * Design.HEIGHT_RATIO;
            self.onboardingTextViewBottomConstraint.constant = DESIGN_TEXT_BOTTOM * Design.HEIGHT_RATIO;
        }
    }
    
    [self updateFont];
}

- (void)handleCreateTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.onboardingExternalCallDelegate respondsToSelector:@selector(didTouchCreateExernalCall)]) {
        [self.onboardingExternalCallDelegate didTouchCreateExernalCall];
    }
}

- (void)handleDoNotShowTapGesture:(UITapGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateEnded && [self.onboardingExternalCallDelegate respondsToSelector:@selector(didTouchDoNotDisplayAgain)]) {
        [self.onboardingExternalCallDelegate didTouchDoNotDisplayAgain];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.onboardingTextView.font = Design.FONT_MEDIUM32;
    self.createLabel.font = Design.FONT_BOLD36;
    self.doNotShowLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.onboardingTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
