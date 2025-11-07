/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TimeoutCell.h"
#import "UITimeout.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: TimeoutCell
//

@interface TimeoutCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: TimeoutCell
//

#undef LOG_TAG
#define LOG_TAG @"TimeoutCell"

@implementation TimeoutCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_REGULAR32;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithTimeout:(UITimeout *)timeout hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithTimeout: %@", LOG_TAG, timeout);
    
    self.titleLabel.text = timeout.title;
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}
@end
