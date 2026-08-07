/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ShareContactConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define ICON_BACKGROUND_COLOR [UIColor colorWithRed:213./255. green:213./255. blue:213./255. alpha:1.0]

static const CGFloat DESIGN_AVATAR_HEIGHT = 148;
static const CGFloat DESIGN_CONFIRM_HEIGHT = 82;
static const CGFloat DESIGN_CANCEL_HEIGHT = 140;

//
// Interface: ShareContactViewController
//

@interface ShareContactConfirmView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftAvatarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *leftAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightAvatarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *rightAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineLeftView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineRightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLeftLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameRightLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameRightLabel;

@end

//
// Implementation: ShareContactConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"ShareContactConfirmView"

@implementation ShareContactConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShareContactConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setup:(NSString *)leftName rightName:(NSString *)rightName contactName:(NSString *)contactName leftAvatar:(UIImage *)leftAvatar rightAvatar:(UIImage *)rightAvatar {
    DDLogVerbose(@"%@ setup", LOG_TAG);
    
    self.nameLeftLabel.text = leftName;
    self.nameRightLabel.text = rightName;
    self.leftAvatarView.image = leftAvatar;
    self.rightAvatarView.image = rightAvatar;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"share_contact_accept_view_message", nil), contactName, rightName];
    
    [self updateLineView];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.leftAvatarContainerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftAvatarContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.leftAvatarContainerView.clipsToBounds = YES;
    self.leftAvatarContainerView.layer.cornerRadius = self.leftAvatarContainerViewHeightConstraint.constant * 0.5f;
    self.leftAvatarContainerView.layer.borderWidth = 3.f;
    self.leftAvatarContainerView.layer.borderColor = [UIColor whiteColor].CGColor;

    self.leftAvatarContainerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.leftAvatarContainerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.leftAvatarContainerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.leftAvatarContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.leftAvatarContainerView.layer.masksToBounds = NO;
    
    self.leftAvatarView.clipsToBounds = YES;
    self.leftAvatarView.layer.cornerRadius = self.leftAvatarContainerViewHeightConstraint.constant * 0.5f;
    
    self.rightAvatarContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightAvatarContainerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.rightAvatarContainerView.clipsToBounds = YES;
    self.rightAvatarContainerView.layer.cornerRadius = self.rightAvatarContainerViewHeightConstraint.constant * 0.5f;
    self.rightAvatarContainerView.layer.borderWidth = 3.f;
    self.rightAvatarContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.rightAvatarContainerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.rightAvatarContainerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.rightAvatarContainerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.rightAvatarContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.rightAvatarContainerView.layer.masksToBounds = NO;
    
    self.rightAvatarView.clipsToBounds = YES;
    self.rightAvatarView.layer.cornerRadius = self.rightAvatarContainerViewHeightConstraint.constant * 0.5f;
    
    self.lineLeftViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineLeftViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lineLeftViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.lineLeftView.backgroundColor = [UIColor clearColor];
    
    self.lineRightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineRightViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lineRightViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.lineRightView.backgroundColor = [UIColor clearColor];
    
    self.nameLeftLabelTopConstraint.constant *= Design.HEIGHT_RATIO;

    self.nameLeftLabel.font = Design.FONT_BOLD36;
    self.nameLeftLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.nameRightLabelTopConstraint.constant *= Design.HEIGHT_RATIO;

    self.nameRightLabel.font = Design.FONT_BOLD36;
    self.nameRightLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.confirmLabel.text = TwinmeLocalizedString(@"application_accept", nil);
    self.cancelLabel.text = TwinmeLocalizedString(@"application_decline", nil);
    
    self.iconView.backgroundColor = ICON_BACKGROUND_COLOR;
    self.iconImageView.tintColor = [UIColor whiteColor];
    
    self.bulletView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateLineView {
    DDLogVerbose(@"%@ updateLineView", LOG_TAG);
    
    NSArray<NSNumber *> *lineDashPattern = @[
        @(Design.LINE_DASH_LONG_LENGTH),
        @(Design.LINE_DASH_SPACING),
        @(Design.LINE_DASH_SHORT_LENGTH),
        @(Design.LINE_DASH_SPACING)
    ];
    
    CAShapeLayer *lineDashLayer = [CAShapeLayer layer];
    lineDashLayer.frame = self.lineLeftView.bounds;

    UIBezierPath *lineLeftPath = [UIBezierPath bezierPath];
    [lineLeftPath moveToPoint:CGPointMake(0, self.lineLeftView.bounds.size.height / 2.0)];
    [lineLeftPath addLineToPoint:CGPointMake(self.lineLeftView.bounds.size.width,
                                     self.lineLeftView.bounds.size.height / 2.0)];

    lineDashLayer.path = lineLeftPath.CGPath;
    lineDashLayer.strokeColor = ICON_BACKGROUND_COLOR.CGColor;
    lineDashLayer.fillColor = nil;
    lineDashLayer.lineWidth = self.lineLeftViewHeightConstraint.constant;
    lineDashLayer.lineCap = kCALineCapRound;
    lineDashLayer.lineDashPattern = lineDashPattern;
    
    [self.lineLeftView.layer addSublayer:lineDashLayer];
    
    lineDashLayer = [CAShapeLayer layer];
    lineDashLayer.frame = self.lineRightView.bounds;
    
    UIBezierPath *lineRightPath = [UIBezierPath bezierPath];
    [lineRightPath moveToPoint:CGPointMake(self.lineRightView.bounds.size.width,
                                     self.lineRightView.bounds.size.height / 2.0)];
    [lineRightPath addLineToPoint:CGPointMake(0, self.lineRightView.bounds.size.height / 2.0)];

    lineDashLayer.path = lineRightPath.CGPath;
    lineDashLayer.strokeColor = ICON_BACKGROUND_COLOR.CGColor;
    lineDashLayer.fillColor = nil;
    lineDashLayer.lineWidth = self.lineRightViewHeightConstraint.constant;
    lineDashLayer.lineCap = kCALineCapRound;
    lineDashLayer.lineDashPattern = lineDashPattern;
    
    [self.lineRightView.layer addSublayer:lineDashLayer];
}

@end
