/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "PremiumFeatureConfirmView.h"

#import "PremiumServicesViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AbstractConfirmView ()
//

@interface PremiumFeatureConfirmView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *premiumFeatureImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureLinkLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureLinkLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumFeatureLinkLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *premiumFeatureLinkLabel;

@property (nonatomic) UIViewController *parentViewController;

@end

//
// Implementation: ResetInvitationConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"PremiumFeatureConfirmView"

@implementation PremiumFeatureConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PremiumFeatureConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithPremiumFeature:(UIPremiumFeature *)premiumFeature parentViewController:(UIViewController *)parentViewController {
    DDLogVerbose(@"%@ initWithPremiumFeature: %@", LOG_TAG, premiumFeature);
        
    self.titleLabel.text = [premiumFeature getTitle];
    self.premiumFeatureImageView.image = [premiumFeature getImage];
    self.parentViewController = parentViewController;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.premiumFeatureImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.premiumFeatureImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.premiumFeatureImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.premiumFeatureLinkLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.premiumFeatureLinkLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.premiumFeatureLinkLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.premiumFeatureLinkLabel.font = Design.FONT_MEDIUM34;
    self.premiumFeatureLinkLabel.textColor = Design.MAIN_COLOR;
    self.premiumFeatureLinkLabel.userInteractionEnabled = YES;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"about_view_controller_premium_services", nil)];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,[attributedString length])];
    [self.premiumFeatureLinkLabel setAttributedText:attributedString];
    
    UITapGestureRecognizer *linkGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLink:)];
    [self.premiumFeatureLinkLabel addGestureRecognizer:linkGestureRecognizer];
        
    self.bulletView.hidden = YES;
    self.iconView.hidden = YES;
    self.avatarContainerView.hidden = YES;
    
    self.messageLabel.text = TwinmeLocalizedString(@"application_premium_feature_message", nil);
    self.confirmLabel.text = TwinmeLocalizedString(@"application_premium_feature_title", nil);
        
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)handleTapLink:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ UITapGestureRecognizer: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
        
        PremiumServicesViewController *premiumServicesViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
        premiumServicesViewController.hideDoNotShow = YES;
        [self.parentViewController presentViewController:premiumServicesViewController animated:YES completion:^{
            [self closeConfirmView];
        }];
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    if (self.forceDarkMode) {
        self.cancelLabel.textColor = [UIColor whiteColor];
    } else {
        self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

@end
