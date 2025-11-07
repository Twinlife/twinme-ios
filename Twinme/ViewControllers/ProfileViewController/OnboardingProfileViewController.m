/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "OnboardingProfileViewController.h"

#import <TwinmeCommon/Design.h>
#import "SpaceSetting.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_CLOSE_TOP_MARGIN = 70;
static CGFloat DESIGN_TITLE_TOP_MARGIN = 144;

//
// Interface: OnboardingProfileViewController ()

@interface OnboardingProfileViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *onboardingImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *moreTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreTextImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *moreTextImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *createProfileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *createProfileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *doNotShowLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *doNotShowView;

@property (nonatomic) UIView *overlayView;

@end

#undef LOG_TAG
#define LOG_TAG @"OnboardingProfileViewController"

@implementation OnboardingProfileViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _startFromSupportSection = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    if (self.startFromSupportSection) {
        [self initViews];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
    
    if (self.startFromSupportSection) {
        self.navigationController.navigationBarHidden = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.messageTextView setContentOffset:CGPointZero];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    if (self.startFromSupportSection) {
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)showInView:(UIViewController*)view {
    DDLogVerbose(@"%@ showInView", LOG_TAG);
    
    self.overlayView = [[UIView alloc]initWithFrame:view.view.bounds];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .3f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    [view.view insertSubview:self.overlayView atIndex:0];
    [view.view bringSubviewToFront:self.overlayView];
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    
    [self initViews];
    
    self.view.alpha = 0.;
    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 1.;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.messageTextView setContentOffset:CGPointZero];
        });
    }];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    if (!self.startFromSupportSection) {
        self.view.backgroundColor = [UIColor clearColor];
        self.view.isAccessibilityElement = NO;
        self.view.userInteractionEnabled = YES;
        
        self.containerTopConstraint.constant *= Design.HEIGHT_RATIO;
        self.containerWidthConstraint.constant *= Design.WIDTH_RATIO;
        self.containerHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
        self.containerView.layer.cornerRadius = Design.POPUP_RADIUS;
        self.containerView.userInteractionEnabled = YES;
        self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        
        self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
        self.closeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
        self.createProfileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        self.doNotShowView.hidden = NO;
    } else {
        self.view.backgroundColor = Design.WHITE_COLOR;
        self.containerTopConstraint.constant = 0;
        self.containerWidthConstraint.constant = Design.DISPLAY_WIDTH;
        self.containerHeightConstraint.constant = Design.DISPLAY_HEIGHT;
        
        self.containerView.backgroundColor = Design.WHITE_COLOR;
        
        self.titleLabelTopConstraint.constant = DESIGN_TITLE_TOP_MARGIN * Design.HEIGHT_RATIO;
        self.closeViewTopConstraint.constant = DESIGN_CLOSE_TOP_MARGIN * Design.HEIGHT_RATIO;
        
        self.createProfileViewHeightConstraint.constant = 0;
        self.doNotShowView.hidden = YES;
    }
    
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_MEDIUM36;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.onboardingImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.onboardingImageView.image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.hidden = YES;

    self.messageTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageTextView.font = Design.FONT_REGULAR34;
    self.messageTextView.hidden = NO;
    self.messageTextView.editable = NO;
    self.messageTextView.selectable = NO;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_1", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_2", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_3", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_4", nil)];
    self.messageLabel.text = message;
    self.messageTextView.text = message;
    
    self.moreTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.moreTextViewHeightConstraint.constant = 0;
    
    self.moreTextView.hidden = YES;
    [self.moreTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlMoreTextGesture:)]];

    self.moreTextImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.moreTextImageView.tintColor = Design.BLACK_COLOR;
        
    self.createProfileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.createProfileViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.createProfileViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createProfileViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.createProfileView.backgroundColor = Design.MAIN_COLOR;
    self.createProfileView.userInteractionEnabled = YES;
    self.createProfileView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.createProfileView.clipsToBounds = YES;
    self.createProfileView.hidden = self.startFromSupportSection;
    [self.createProfileView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCreateProfileGesture:)]];
    
    self.createProfileLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createProfileLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.createProfileLabel.font = Design.FONT_MEDIUM34;
    self.createProfileLabel.textColor = [UIColor whiteColor];
    self.createProfileLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil);
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
    
    self.doNotShowLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.doNotShowLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.doNotShowLabel.font = Design.FONT_MEDIUM28;
    self.doNotShowLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    NSMutableAttributedString *laterAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_do_not_display", nil)];
    [laterAttributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,
                                                                                                 [laterAttributedString length])];
    [self.doNotShowLabel setAttributedText:laterAttributedString];
    
    self.doNotShowViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.doNotShowViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.doNotShowView.userInteractionEnabled = YES;
    [self.doNotShowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoNotShowTapGesture:)]];
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        [self finish];
    }
}

- (void)handleDoNotShowTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDoNotShowTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeProfile state:NO];
        [self finish];
    }
}

- (void)handleCreateProfileGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlecreateProfileGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        [self finish];
    }
}

- (void)handlMoreTextGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlMoreTextGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        self.moreTextView.hidden = YES;
        self.moreTextViewHeightConstraint.constant = 0;
        
        NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_1", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_2", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_3", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_4", nil)];
        self.messageLabel.text = message;
        self.messageTextView.text = message;
        
        self.messageLabel.hidden = YES;
        self.messageTextView.hidden = NO;
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    if (self.startFromSupportSection) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.overlayView removeFromSuperview];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_MEDIUM36;
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageTextView.font = Design.FONT_REGULAR34;
    self.createProfileLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
