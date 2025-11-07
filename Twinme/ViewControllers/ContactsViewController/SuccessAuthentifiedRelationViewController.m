/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "SuccessAuthentifiedRelationViewController.h"

#import <TwinmeCommon/Design.h>

#import <Lottie/Lottie.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SuccessAuthentifiedRelationViewController ()
//

@interface SuccessAuthentifiedRelationViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lottieAnimationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lottieAnimationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet LOTAnimationView *lottieAnimationView;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;

@end

#undef LOG_TAG
#define LOG_TAG @"SuccessAuthentifiedRelationViewController"

@implementation SuccessAuthentifiedRelationViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

#pragma mark - Public methods

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showInView", LOG_TAG);
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    
    [self initViews];
    
    self.view.alpha = 0.;
    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 1.;
    } completion:^(BOOL finished) {
        [self startSuccessAnimation];
    }];
}

- (void)initWithName:(NSString *)name avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ initWithName: %@ avatar: %@", LOG_TAG, name, avatar);
    
    self.contactName = name;
    self.contactAvatar = avatar;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.isAccessibilityElement = NO;
    self.overlayView.isAccessibilityElement = NO;
    
    self.containerTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.containerHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.avatarView.image = self.contactAvatar;
    
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.text = self.contactName;
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_certified_message", nil), self.contactName];
    
    self.certifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.confirmLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmLabel.font = Design.FONT_MEDIUM34;
    self.confirmLabel.textColor = [UIColor whiteColor];
    self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
    
    self.lottieAnimationViewTopConstraint.constant *= Design.DISPLAY_HEIGHT;
    self.lottieAnimationViewHeightConstraint.constant = Design.DISPLAY_HEIGHT * 0.5f;
    
    self.lottieAnimationView.hidden = YES;
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        if ([self.successAuthentifiedRelationDelegate respondsToSelector:@selector(closeSuccessAuthentifiedRelation)]) {
            [self.successAuthentifiedRelationDelegate closeSuccessAuthentifiedRelation];
        }
        
        [self finish];
    }
}

- (void)startSuccessAnimation {
    DDLogVerbose(@"%@ startSuccessAnimation", LOG_TAG);
    
    self.lottieAnimationView.hidden = NO;
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"certification_animation_success" ofType:@"json"]];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self.lottieAnimationView setAnimationFromJSON:dictionary];
    self.lottieAnimationView.loopAnimation = NO;
    
    [self.lottieAnimationView playWithCompletion:^(BOOL finished){
        [UIView animateWithDuration:2 animations:^{
            self.lottieAnimationView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
            
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.confirmLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
