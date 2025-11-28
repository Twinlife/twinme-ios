/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import <CocoaLumberjack.h>
#import "SuccessAuthentifiedRelationView.h"

#import <Twinme/TLContact.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import <Lottie/Lottie.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SuccessAuthentifiedRelationView ()
//

@interface SuccessAuthentifiedRelationView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lottieAnimationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lottieAnimationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet LOTAnimationView *lottieAnimationView;

@end

//
// Implementation: SuccessAuthentifiedRelationView
//

#undef LOG_TAG
#define LOG_TAG @"SuccessAuthentifiedRelationView"

@implementation SuccessAuthentifiedRelationView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SuccessAuthentifiedRelationView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon {
    DDLogVerbose(@"%@ initWithTitle: %@ message: %@ avatar: %@ icon: %@", LOG_TAG, title, message, avatar, icon);
 
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    
    if (avatar) {
        self.avatarView.image = avatar;
        self.avatarView.hidden = NO;
    } else {
        self.avatarView.hidden = YES;
    }    
}

- (void)showConfirmView {
    DDLogVerbose(@"%@ showConfirmView", LOG_TAG);
    
    [super showConfirmView];
    
    [self startSuccessAnimation];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.certifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
    
    self.lottieAnimationViewTopConstraint.constant *= Design.DISPLAY_HEIGHT;
    self.lottieAnimationViewHeightConstraint.constant = Design.DISPLAY_HEIGHT * 0.5f;
    
    self.lottieAnimationView.hidden = YES;
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

@end

