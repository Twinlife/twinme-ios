/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SplashScreenViewController.h"

#import <TwinmeCommon/Design.h>

#import "UIView+Toast.h"
#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/SplashService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat ANIMATION_DURATION = 2.f;

//
// Interface: SplashScreenViewController ()
//
@interface SplashScreenViewController () <CAAnimationDelegate, SplashServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *splashScreenLogoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenLogoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenTwinmeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updgradeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updgradeLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *updgradeLabel;

@property ApplicationStateType state;
@property BOOL isAnimationFinished;
@property (nonatomic) SplashService *splashService;

@end

//
// Implementation: SplashScreenViewController
//

#undef LOG_TAG
#define LOG_TAG @"SplashScreenViewController"

@implementation SplashScreenViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _isAnimationFinished = NO;
        _state = ApplicationStateTypeStarting;
        _splashService = [[SplashService alloc] initWithTwinmeContext:self.twinmeContext subscriptionTwincodeId:nil delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self animateLogo];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");

    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    DDLogVerbose(@"%@ animationDidStop: %@ finished:%d", LOG_TAG, animation, finished);
    
    self.isAnimationFinished = YES;
    if (self.state == ApplicationStateTypeReady || self.state == ApplicationStateTypeMigration) {
        [self checkAnimation];
    }
}

#pragma mark - SplashServiceDelegate

- (void)onState:(ApplicationStateType)state {
    DDLogVerbose(@"%@ onState: %d", LOG_TAG, state);
    
    self.state = state;
    
    if (self.state == ApplicationStateTypeUpgrading) {
        self.updgradeLabel.hidden = NO;
    } else if (self.state == ApplicationStateTypeDisabled) {
        self.updgradeLabel.hidden = NO;
        self.updgradeLabel.text = TwinmeLocalizedString(@"application_state_disabled", nil);
    } else if (self.isAnimationFinished && (self.state == ApplicationStateTypeReady || self.state == ApplicationStateTypeMigration)) {
        [self checkAnimation];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.splashScreenLogoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.splashScreenLogoImage.alpha = 0.0;
    
    self.splashScreenLogoImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.splashScreenTwinmeImage.alpha = 0.0;
    self.splashScreenTwinmeImage.backgroundColor = [UIColor clearColor];
    self.splashScreenTwinmeImage.tintColor = Design.SPLASHSCREEN_LOGO_COLOR;
    
    self.splashScreenTwinmeImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenTwinmeImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.updgradeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.updgradeLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.updgradeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.updgradeLabel.font = Design.FONT_REGULAR34;
    self.updgradeLabel.text = TwinmeLocalizedString(@"application_upgrade", nil);
    self.updgradeLabel.hidden = YES;
}

- (void)animateLogo {
    DDLogVerbose(@"%@ animateLogo", LOG_TAG);
    
    CABasicAnimation *animationLogo = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationLogo.repeatCount = 1;
    animationLogo.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationLogo.fromValue = [NSNumber numberWithFloat:0.0];
    animationLogo.toValue = [NSNumber numberWithFloat:2.0];
    animationLogo.removedOnCompletion = NO;
    self.splashScreenLogoImage.layer.opacity = 1.0;
    
    CABasicAnimation *animationTwinme = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationTwinme.repeatCount = 1;
    animationTwinme.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationTwinme.fromValue = [NSNumber numberWithFloat:0.0];
    animationTwinme.toValue = [NSNumber numberWithFloat:2.0];
    animationTwinme.removedOnCompletion = NO;
    self.splashScreenTwinmeImage.layer.opacity = 1.0;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[animationLogo, animationTwinme];
    animationGroup.delegate = self;
    animationGroup.duration = ANIMATION_DURATION;
    [self.splashScreenTwinmeImage.layer addAnimation:animationGroup forKey:nil];
}

- (void)checkAnimation {
    DDLogVerbose(@"%@ checkAnimation", LOG_TAG);
    
    if (self.isAnimationFinished) {
        [self.splashService dispose];
        self.splashService = nil;
        [self.splashScreenDelegate animationDidFinish:self.state == ApplicationStateTypeMigration];
    }
}

@end
