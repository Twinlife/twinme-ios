/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "DeletedAccountViewController.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: DeletedAccountViewController ()
//

@interface DeletedAccountViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twinmeImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twinmeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twinmeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

#undef LOG_TAG
#define LOG_TAG @"DeleteAccountViewController"

@implementation DeletedAccountViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.logoImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twinmeImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twinmeImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twinmeImage.tintColor = Design.SPLASHSCREEN_LOGO_COLOR;
    
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabel.font = Design.FONT_REGULAR36;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"deleted_account_view_controller_message", nil);
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_REGULAR36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
