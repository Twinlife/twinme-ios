/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "WelcomeCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: WelcomeCell ()
//

@interface WelcomeCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

//
// Implementation: WelcomeCell
//

#undef LOG_TAG
#define LOG_TAG @"WelcomeCell"

@implementation WelcomeCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.welcomeImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.welcomeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.welcomeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeLabel.font = Design.FONT_MEDIUM34;
    self.welcomeLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font {
    DDLogVerbose(@"%@ bindWithTitle: %@ image: %@", LOG_TAG, title, image);
    
    self.welcomeImageView.image = image;
    self.welcomeLabel.text = title;
    
    self.welcomeLabel.font = font;
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.welcomeLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
