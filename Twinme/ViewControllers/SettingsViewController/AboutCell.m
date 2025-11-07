/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AboutCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AboutCell
//

@interface AboutCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

//
// Implementation: AboutCell
//

#undef LOG_TAG
#define LOG_TAG @"AboutCell"

@implementation AboutCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.infoLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.infoLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.infoLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.infoLabel.font = Design.FONT_REGULAR34;
    self.infoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithText:(NSString *)text {
    DDLogVerbose(@"%@ bindWithText: %@", LOG_TAG, text);
    
    self.infoLabel.text = text;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.infoLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.infoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
