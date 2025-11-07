/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ClickToCallView.h"

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
static UIColor *DESIGN_RED_VIEW_COLOR;
static UIColor *DESIGN_YELLOW_VIEW_COLOR;
static UIColor *DESIGN_GREEN_VIEW_COLOR;
static UIColor *DESIGN_ACTION_BORDER_COLOR;

//
// Interface: ClickToCallView
//

@interface ClickToCallView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *invitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedRedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedRedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedRedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedYellowViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedYellowViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedYellowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedGreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedGreenViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedGreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;

@property (nonatomic) NSString *name;
@property (nonatomic) NSUUID *twincodeId;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *qrcode;
@property (nonatomic) NSString *message;

@end

//
// Implementation: ClickToCallView
//

#undef LOG_TAG
#define LOG_TAG @"ClickToCallView"

@implementation ClickToCallView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_INVITATION_VIEW_COLOR = [UIColor colorWithRed:69./255. green:69./255. blue:69./255. alpha:1.0];
    DESIGN_INVITATION_VIEW_BORDER_COLOR = [UIColor colorWithRed:151./255. green:151./255. blue:151./255. alpha:0.47];
    DESIGN_HEADER_COLOR = [UIColor colorWithRed:102./255. green:102./255. blue:102./255. alpha:1.0];
    DESIGN_NAME_VIEW_COLOR = [UIColor colorWithRed:81./255. green:79./255. blue:79./255. alpha:1.0];
    DESIGN_RED_VIEW_COLOR = [UIColor colorWithRed:191./255. green:60./255. blue:52./255. alpha:1.0];
    DESIGN_YELLOW_VIEW_COLOR = [UIColor colorWithRed:255./255. green:207./255. blue:8./255. alpha:1.0];
    DESIGN_GREEN_VIEW_COLOR = [UIColor colorWithRed:23./255. green:196./255. blue:164./255. alpha:1.0];
    DESIGN_ACTION_BORDER_COLOR = [UIColor colorWithRed:84./255. green:84./255. blue:84./255. alpha:1.0];
}

- (instancetype)initWithName:(NSString *)name avatar:(UIImage *)avatar qrcode:(UIImage *)qrcode twincodeId:(NSUUID *)twincodeId message:(NSString *)message {
    DDLogVerbose(@"%@ initWithName: %@ avatar: %@ qrcode: %@ twincodeId: %@ message: %@", LOG_TAG, name, avatar, qrcode, twincodeId, message);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _avatar = avatar;
        _qrcode = qrcode;
        _twincodeId = twincodeId;
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
    
    self.headerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.headerView.clipsToBounds = YES;
    self.headerView.backgroundColor = DESIGN_HEADER_COLOR;
    
    self.headerView.layer.borderColor = DESIGN_INVITATION_VIEW_BORDER_COLOR.CGColor;
    self.headerView.layer.borderWidth = 1.0;
    
    self.roundedRedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedRedViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedRedView.clipsToBounds = YES;
    self.roundedRedView.layer.cornerRadius = self.roundedRedViewHeightConstraint.constant * 0.5;
    self.roundedRedView.backgroundColor = DESIGN_RED_VIEW_COLOR;
    
    self.roundedYellowViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedYellowViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedYellowView.clipsToBounds = YES;
    self.roundedYellowView.layer.cornerRadius = self.roundedYellowViewHeightConstraint.constant * 0.5;
    self.roundedYellowView.backgroundColor = DESIGN_YELLOW_VIEW_COLOR;
    
    self.roundedGreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roundedGreenViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.roundedGreenView.clipsToBounds = YES;
    self.roundedGreenView.layer.cornerRadius = self.roundedGreenViewHeightConstraint.constant * 0.5;
    self.roundedGreenView.backgroundColor = DESIGN_GREEN_VIEW_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.image = self.avatar;
    
    self.nameViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameView.clipsToBounds = YES;
    self.nameView.layer.cornerRadius = self.nameViewHeightConstraint.constant * 0.5;
    self.nameView.backgroundColor = DESIGN_NAME_VIEW_COLOR;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = self.name;
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    self.messageLabelTopConstraint.constant *= Design.MIN_RATIO;
    
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
    
    self.twincodeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.twincodeLabel setFont:Design.FONT_MEDIUM28];
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.numberOfLines = 1;
    [self.twincodeLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.twincodeLabel.text = [NSString fromUUID:self.twincodeId];
}

@end
