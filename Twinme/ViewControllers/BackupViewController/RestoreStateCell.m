/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "RestoreStateCell.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: RestoreStateCell ()
//

@interface RestoreStateCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

//
// Implementation: RestoreStateCell
//

#undef LOG_TAG
#define LOG_TAG @"RestoreStateCell"

@implementation RestoreStateCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];

    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.activityIndicatorViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.activityIndicatorView startAnimating];
    
    self.stateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.stateLabel.font = Design.FONT_REGULAR34;
    self.stateLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bind:(nonnull NSMutableAttributedString *)message hideIndecator:(BOOL)hideIndicator {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, message);
    
    self.stateLabel.attributedText = message;
    
    if (hideIndicator) {
        [self.activityIndicatorView stopAnimating];
    } else {
        [self.activityIndicatorView startAnimating];
    }
}

@end
