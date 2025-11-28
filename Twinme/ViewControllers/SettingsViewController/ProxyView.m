/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ProxyView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_INVITATION_RADIUS = 6;
static UIColor *DESIGN_INVITATION_VIEW_COLOR;
static UIColor *DESIGN_INVITATION_VIEW_BORDER_COLOR;
static UIColor *DESIGN_HEADER_COLOR;
static UIColor *DESIGN_NAME_VIEW_COLOR;
static UIColor *DESIGN_ACTION_BORDER_COLOR;

//
// Interface: ProxyView
//

@interface ProxyView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *invitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *proxyLabel;

@property (nonatomic) NSString *proxy;
@property (nonatomic) UIImage *qrcode;
@property (nonatomic) NSString *message;

@end

//
// Implementation: ProxyView
//

#undef LOG_TAG
#define LOG_TAG @"ProxyView"

@implementation ProxyView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_INVITATION_VIEW_COLOR = [UIColor colorWithRed:69./255. green:69./255. blue:69./255. alpha:1.0];
    DESIGN_INVITATION_VIEW_BORDER_COLOR = [UIColor colorWithRed:151./255. green:151./255. blue:151./255. alpha:0.47];
    DESIGN_HEADER_COLOR = [UIColor colorWithRed:102./255. green:102./255. blue:102./255. alpha:1.0];
    DESIGN_ACTION_BORDER_COLOR = [UIColor colorWithRed:84./255. green:84./255. blue:84./255. alpha:1.0];
}

- (instancetype)initWithProxy:(NSString *)proxy qrcode:(UIImage *)qrcode message:(NSString *)message {
    DDLogVerbose(@"%@ initWithProxy: %@ qrcode: %@ message: %@", LOG_TAG, proxy, qrcode, message);
    
    self = [super init];
    
    if (self) {
        _qrcode = qrcode;
        _proxy = proxy;
        _message = message;
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
            
    self.invitationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.invitationView.backgroundColor = DESIGN_INVITATION_VIEW_COLOR;
    self.invitationView.clipsToBounds = YES;
    self.invitationView.layer.borderColor = DESIGN_INVITATION_VIEW_BORDER_COLOR.CGColor;
    self.invitationView.layer.borderWidth = 1.0;
    self.invitationView.layer.cornerRadius = DESIGN_INVITATION_RADIUS;
       
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.text = self.message;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.clipsToBounds = YES;
    self.qrcodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.qrcodeView.userInteractionEnabled = YES;
    self.qrcodeView.backgroundColor = [UIColor whiteColor];
    
    self.qrcodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeImageView.image = self.qrcode;
    
    self.proxyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.proxyLabel setFont:Design.FONT_MEDIUM28];
    self.proxyLabel.textColor = [UIColor whiteColor];
    self.proxyLabel.numberOfLines = 1;
    [self.proxyLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.proxyLabel.text = self.proxy;
}

@end
