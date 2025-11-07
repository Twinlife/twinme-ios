/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TwincodeView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_AVATAR_BORDER_WIDTH = 6;

//
// Interface: TwincodeView
//

@interface TwincodeView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerQrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerQrcodeHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerQrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) NSString *name;
@property (nonatomic) NSUUID *twincodeId;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *qrcode;

@end

//
// Implementation: TwincodeView
//

#undef LOG_TAG
#define LOG_TAG @"TwincodeView"

@implementation TwincodeView

- (instancetype)initWithName:(NSString *)name avatar:(UIImage *)avatar qrcode:(UIImage *)qrcode twincodeId:(NSUUID *)twincodeId {
    DDLogVerbose(@"%@ initWithName: %@ avatar: %@ qrcode: %@ twincodeId: %@", LOG_TAG, name, avatar, qrcode, twincodeId);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _avatar = avatar;
        _qrcode = qrcode;
        _twincodeId = twincodeId;
        self.view.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (UIImage *)screenshot {
    DDLogVerbose(@"%@ screenshot", LOG_TAG);
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0f);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedImage;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.profileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.profileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.profileViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.profileView.backgroundColor = Design.MAIN_COLOR;
    
    CALayer *profileViewLayer = self.profileView.layer;
    profileViewLayer.shadowOpacity = Design.SHADOW_OPACITY;
    profileViewLayer.shadowOffset = Design.SHADOW_OFFSET;
    profileViewLayer.shadowRadius = Design.SHADOW_RADIUS;
    profileViewLayer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    profileViewLayer.cornerRadius = Design.CONTAINER_RADIUS;
    profileViewLayer.masksToBounds = NO;
    
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarView.layer.borderWidth = DESIGN_AVATAR_BORDER_WIDTH;
    self.avatarView.image = self.avatar;
    
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.nameLabel setFont:Design.FONT_MEDIUM34];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = self.name;
    
    self.containerQrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerQrcodeHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerQrcodeView.clipsToBounds = YES;
    self.containerQrcodeView.backgroundColor = [UIColor whiteColor];
    self.containerQrcodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeView.image = self.qrcode;
    
    self.twincodeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.twincodeLabel setFont:Design.FONT_MEDIUM34];
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.numberOfLines = 1;
    [self.twincodeLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.messageLabel setFont:Design.FONT_MEDIUM28];
    self.messageLabel.textColor = [UIColor blackColor];
    
    self.twincodeLabel.text = [NSString stringWithFormat:@"%@",self.twincodeId];
    self.messageLabel.text = TwinmeLocalizedString(@"fullscreen_qrcode_view_controller_save_message", nil);
}

@end

