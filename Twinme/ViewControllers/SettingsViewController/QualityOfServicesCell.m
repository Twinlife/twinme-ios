/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "QualityOfServicesCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "QualityOfServicesViewController.h"
#import "UIQuality.h"

//
// Interface: QualityOfServicesCell
//

@interface QualityOfServicesCell() <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qualityImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@end

@implementation QualityOfServicesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.qualityImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qualityImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageTextViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageTextViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageTextView.text = TwinmeLocalizedString(@"quality_of_services_view_controller_step1_message", nil);
    self.messageTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageTextView.font = Design.FONT_MEDIUM32;
    self.messageTextView.editable = NO;
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.settingsView.backgroundColor = Design.MAIN_COLOR;
    self.settingsView.userInteractionEnabled = YES;
    self.settingsView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.settingsView.clipsToBounds = YES;
    [self.settingsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)]];
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsLabel.font = Design.FONT_MEDIUM34;
    self.settingsLabel.textColor = [UIColor whiteColor];
    self.settingsLabel.text = TwinmeLocalizedString(@"quality_of_services_view_controller_settings", nil);
    [self.settingsLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.settingsViewHeightConstraint.constant =  Design.FONT_MEDIUM34.lineHeight * 2 + self.settingsLabelBottomConstraint.constant * 2;
}

- (void)bindWithQuality:(UIQuality *)uiQuality hideAction:(BOOL)hideAction {
        
    self.qualityImageView.image = [uiQuality getImage];
    self.messageTextView.text = [uiQuality getMessage];
    self.settingsView.hidden = hideAction;
        
    if (hideAction) {
        self.messageTextViewBottomConstraint.constant = 0;
    } else {
        self.messageTextViewBottomConstraint.constant = self.settingsViewBottomConstraint.constant + self.settingsViewTopConstraint.constant + self.settingsViewHeightConstraint.constant;
    }
    
    [self updateColor];
    [self updateFont];
    
    CGFloat delay = 0.1f;
    if (uiQuality.qualityOfServicesPart == QualityOfServicesPartOne) {
        delay = 0.5f;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.messageTextView setContentOffset:CGPointZero];
    });
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.qualityOfServicesDelegate respondsToSelector:@selector(didTouchSettings)]) {
        [self.qualityOfServicesDelegate didTouchSettings];
    }
}

- (void)updateColor {
    
    self.messageTextView.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    
    self.messageTextView.font = Design.FONT_MEDIUM32;
    self.settingsLabel.font = Design.FONT_MEDIUM34;
}

@end
