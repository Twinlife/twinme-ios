/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallQualityView.h"

#import <Utils/NSString+Utils.h>

#import "UIColor+Hex.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallQualityView ()
//

@interface CallQualityView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starOneImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starOneImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starOneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starTwoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starTwoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starThreeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starThreeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starFourImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starFourImageView;

@property int callQuality;

@end

//
// Implementation: MenuRoomMemberView
//

#undef LOG_TAG
#define LOG_TAG @"CallQualityView"

@implementation CallQualityView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallQualityView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self) {
        _callQuality = 4;
        [self initViews];
    }
    return self;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.starOneImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.starOneImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starOneImageView.userInteractionEnabled = YES;
    self.starOneImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starOneGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starOneImageView addGestureRecognizer:starOneGestureRecognizer];
    
    self.starTwoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starTwoImageView.userInteractionEnabled = YES;
    self.starTwoImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starTwoGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starTwoImageView addGestureRecognizer:starTwoGestureRecognizer];
    
    self.starThreeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starThreeImageView.userInteractionEnabled = YES;
    self.starThreeImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starThreeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starThreeImageView addGestureRecognizer:starThreeGestureRecognizer];
    
    self.starFourImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starFourImageView.userInteractionEnabled = YES;
    self.starFourImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starFourGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starFourImageView addGestureRecognizer:starFourGestureRecognizer];
        
    self.titleLabel.text = TwinmeLocalizedString(@"call_view_controller_quality_title", nil);
    self.messageLabel.text = TwinmeLocalizedString(@"call_view_controller_quality_message", nil);
    self.confirmLabel.text = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    
    [self updateStars];
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.callQualityViewDelegate respondsToSelector:@selector(didSendCallQuality:quality:)]) {
            [self.callQualityViewDelegate didSendCallQuality:self quality:self.callQuality];
        }
    }
}

- (void)handleStarTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStarTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (sender.view == self.starOneImageView) {
            self.callQuality = 1;
        } else if (sender.view == self.starTwoImageView) {
            self.callQuality = 2;
        } else if (sender.view == self.starThreeImageView) {
            self.callQuality = 3;
        } else if (sender.view == self.starFourImageView) {
            self.callQuality = 4;
        }
        
        [self updateStars];
    }
}

- (void)updateStars {
    DDLogVerbose(@"%@ updateStars", LOG_TAG);
    
    self.starOneImageView.image = self.callQuality > 0 ? [UIImage imageNamed:@"StarRed"]:[UIImage imageNamed:@"StarGrey"];
    self.starTwoImageView.image = self.callQuality > 1 ? [UIImage imageNamed:@"StarRed"]:[UIImage imageNamed:@"StarGrey"];
    self.starThreeImageView.image = self.callQuality > 2 ? [UIImage imageNamed:@"StarRed"]:[UIImage imageNamed:@"StarGrey"];
    self.starFourImageView.image = self.callQuality > 3 ? [UIImage imageNamed:@"StarRed"]:[UIImage imageNamed:@"StarGrey"];
}

@end
