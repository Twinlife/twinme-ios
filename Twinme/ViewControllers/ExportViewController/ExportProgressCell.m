/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ExportProgressCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ExportProgressCell ()
//

@interface ExportProgressCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

//
// Implementation: ExportProgressCell
//

#undef LOG_TAG
#define LOG_TAG @"ExportProgressCell"

@implementation ExportProgressCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.progressViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.progressView.trackTintColor =  [UIColor whiteColor];
    self.progressView.progressTintColor = Design.MAIN_COLOR;
    self.progressView.clipsToBounds = true;
    
    if (self.progressView.subviews.count > 1) {
        self.progressView.subviews[1].clipsToBounds = true;
        self.progressView.transform = CGAffineTransformMakeScale(1.0, Design.PROGRESS_VIEW_SCALE);
    }
    
    if (self.progressView.layer.sublayers.count > 1) {
        CALayer *layer = [self.progressView.layer.sublayers objectAtIndex:1];
        layer.cornerRadius =  self.progressView.frame.size.height * 0.5;
        self.progressView.layer.cornerRadius = self.progressView.frame.size.height * 0.5;
    }
    
    self.progressLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.progressLabel.font = Design.FONT_BOLD34;
    self.progressLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithProgress:(float)progress message:(NSString *)message {
    DDLogVerbose(@"%@ bindWithProgress: %f message: %@", LOG_TAG, progress, message);

    self.progressView.hidden = YES;
    self.messageLabel.hidden = YES;
    
    self.progressLabel.text = message;
    
    [self udpateColor];
    [self updateFont];
}

- (void)udpateColor {
    DDLogVerbose(@"%@ udpateColor", LOG_TAG);
    
    self.progressView.progressTintColor = Design.MAIN_COLOR;
    self.progressLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.progressLabel.font = Design.FONT_BOLD34;
    self.messageLabel.font = Design.FONT_REGULAR34;
}

@end
