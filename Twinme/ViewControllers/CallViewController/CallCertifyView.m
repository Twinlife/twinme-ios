/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallCertifyView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/WordCheckChallenge.h>

#import "UIView+GradientBackgroundColor.h"

#import <Utils/NSString+Utils.h>
#import <Lottie/Lottie.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_CANCEL_COLOR [UIColor colorWithRed:253./255. green:96./255. blue:83./255. alpha:1.0]
#define DESIGN_CONFIRM_COLOR [UIColor colorWithRed:78./255. green:229./255. blue:184./255. alpha:1.0]

static CGFloat DELAY_CLOSE = 5.f;


//
// Interface: CallCertifyView ()
//

@interface CallCertifyView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *confirmImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletsViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletOneViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletOneView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletTwoViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletTwoView;
@property (weak, nonatomic) IBOutlet UIView *bulletThreeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletFourViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletFourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletFiveViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletFiveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lottieAnimationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet LOTAnimationView *lottieAnimationView;

@property (nonatomic) WordCheckChallenge *wordCheckChallenge;

@end

//
// Implementation: CallCertifyView
//

#undef LOG_TAG
#define LOG_TAG @"CallCertifyView"

@implementation CallCertifyView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallCertifyView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)updateMessage {
    DDLogVerbose(@"%@ updateMessage", LOG_TAG);
        
    self.avatarView.image = self.avatar;
    self.nameLabel.text = self.name;
    
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_repeat_word", nil), self.name];
    self.successLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_certified_message", nil), self.name];
}

- (void)updateWord:(WordCheckChallenge *)wordCheckChallenge {
    DDLogVerbose(@"%@ updateWord: %@", LOG_TAG, wordCheckChallenge);
    
    if (!wordCheckChallenge) {
        return;
    }
    
    if (!self.wordCheckChallenge ||self.wordCheckChallenge.index != wordCheckChallenge.index) {
        self.wordCheckChallenge = wordCheckChallenge;
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.3;
        [self.wordLabel.layer addAnimation:animation forKey:nil];
        self.wordLabel.text = wordCheckChallenge.word.uppercaseString;
        
        self.progressLabel.text = [NSString stringWithFormat:@"%d / 5", self.wordCheckChallenge.index + 1];
        [self updateBulletsView:wordCheckChallenge.index];
    }

    [self setupGradientBackgroundFromColors:Design.BACKGROUND_GRADIENT_COLORS_BLACK];
    
    if (wordCheckChallenge.checker) {
        self.cancelView.hidden = NO;
        self.confirmView.hidden = NO;
        self.titleLabel.text = TwinmeLocalizedString(@"call_view_controller_confirm_word_title", nil);
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_confirm_word", nil), self.name];
    } else {
        self.cancelView.hidden = YES;
        self.confirmView.hidden = YES;
        self.titleLabel.text = TwinmeLocalizedString(@"call_view_controller_repeat_word_title", nil);
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_repeat_word", nil), self.name];
    }
}

- (void)certifyRelationSuccess {
    DDLogVerbose(@"%@ certifyRelationSuccess", LOG_TAG);
    
    self.avatarView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.certifiedRelationImageView.hidden = NO;
    self.successLabel.hidden = NO;
    self.titleLabel.hidden = YES;
    self.messageLabel.hidden = YES;
    self.wordLabel.hidden = YES;
    self.cancelView.hidden = YES;
    self.confirmView.hidden = YES;
    self.progressLabel.hidden = YES;
    self.bulletsView.hidden = YES;
    
    [self startSuccessAnimation];
    
    dispatch_time_t closeTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_CLOSE * NSEC_PER_SEC));
    dispatch_after(closeTime, dispatch_get_main_queue(), ^(void){
        if ([self.callCertifyViewDelegate respondsToSelector:@selector(certifyViewDidFinish)]) {
            [self.callCertifyViewDelegate certifyViewDidFinish];
        }
    });
}

- (void)certifyRelationFailed {
    DDLogVerbose(@"%@ certifyRelationFailed", LOG_TAG);
        
    self.titleLabel.hidden = YES;
    self.cancelView.hidden = YES;
    self.confirmView.hidden = YES;
    
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_certify_error_message", nil), self.name];
        
    dispatch_time_t closeTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_CLOSE * NSEC_PER_SEC));
    dispatch_after(closeTime, dispatch_get_main_queue(), ^(void){
        if ([self.callCertifyViewDelegate respondsToSelector:@selector(certifyViewDidFinish)]) {
            [self.callCertifyViewDelegate certifyViewDidFinish];
        }
    });
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTapGesture:)]];
        
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = Design.FONT_MEDIUM54;
    self.titleLabel.text = TwinmeLocalizedString(@"call_view_controller_repeat_word_title", nil);;
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.messageLabel.font = Design.FONT_MEDIUM38;
    
    self.wordLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.wordLabel.textColor = [UIColor whiteColor];
    self.wordLabel.font = Design.FONT_BOLD88;
    self.wordLabel.text = @"";
    
    self.progressLabel.font = Design.FONT_MEDIUM44;
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.text = @"";
    self.progressLabel.hidden = YES;
    
    self.bulletsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.bulletsViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.bulletsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.bulletOneViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletOneView.clipsToBounds = YES;
    
    self.bulletOneView.layer.cornerRadius = self.bulletsViewHeightConstraint.constant * 0.5f;
    self.bulletOneView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    self.bulletOneView.layer.borderWidth = 2;
    self.bulletOneView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.bulletTwoViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletTwoView.layer.cornerRadius = self.bulletsViewHeightConstraint.constant * 0.5f;
    self.bulletTwoView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    self.bulletTwoView.layer.borderWidth = 2;
    self.bulletTwoView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.bulletThreeView.layer.cornerRadius = self.bulletsViewHeightConstraint.constant * 0.5f;
    self.bulletThreeView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    self.bulletThreeView.layer.borderWidth = 2;
    self.bulletThreeView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.bulletFourViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletFourView.layer.cornerRadius = self.bulletsViewHeightConstraint.constant * 0.5f;
    self.bulletFourView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    self.bulletFourView.layer.borderWidth = 2;
    self.bulletFourView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.bulletFiveViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletFiveView.layer.cornerRadius = self.bulletsViewHeightConstraint.constant * 0.5f;
    self.bulletFiveView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    self.bulletFiveView.layer.borderWidth = 2;
    self.bulletFiveView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewLeadingConstraint.constant = self.confirmViewHeightConstraint.constant * 0.75f;
    
    self.confirmView.clipsToBounds = YES;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = self.confirmViewHeightConstraint.constant * 0.5f;
    self.confirmView.layer.backgroundColor = DESIGN_CONFIRM_COLOR.CGColor;
    
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    
    self.confirmImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewTrailingConstraint.constant = -self.cancelViewHeightConstraint.constant * 0.75f;
    
    self.cancelView.clipsToBounds = YES;
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.layer.cornerRadius = self.cancelViewHeightConstraint.constant * 0.5f;
    self.cancelView.layer.backgroundColor = DESIGN_CANCEL_COLOR.CGColor;
    
    [self.cancelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)]];
    
    self.cancelImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.avatarView.hidden = YES;
    
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.nameLabel.hidden = YES;
    
    self.successLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.successLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.successLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.successLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.successLabel.font = Design.FONT_REGULAR32;
    self.successLabel.textColor = [UIColor whiteColor];
    self.successLabel.hidden = YES;
    
    self.certifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.certifiedRelationImageView.hidden = YES;
    
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

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleCancelTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callCertifyViewDelegate respondsToSelector:@selector(certifyViewCancelWord)]) {
        [self.callCertifyViewDelegate certifyViewCancelWord];
        [self.callCertifyViewDelegate certifyViewDidFinish];
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleConfirmTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callCertifyViewDelegate respondsToSelector:@selector(certifyViewConfirmWord)]) {
        [self.callCertifyViewDelegate certifyViewConfirmWord];
    }
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleSingleTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callCertifyViewDelegate respondsToSelector:@selector(certifyViewSingleTap)]) {
        [self.callCertifyViewDelegate certifyViewSingleTap];
    }
}

- (void)updateBulletsView:(int)index {
    DDLogVerbose(@"%@ updateBulletsView: %d", LOG_TAG, index);
    
    if (index > 0) {
        self.bulletTwoView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bulletTwoView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
    if (index > 1) {
        self.bulletThreeView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bulletThreeView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
    if (index > 2) {
        self.bulletFourView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bulletFourView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
    if (index > 3) {
        self.bulletFiveView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bulletFiveView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
}

@end
