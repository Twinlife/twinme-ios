/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "NotificationSoundCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: NotificationSoundCell
//

@interface NotificationSoundCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *soundLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *soundLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: NotificationSoundCell
//

#undef LOG_TAG
#define LOG_TAG @"NotificationSoundCell"

@implementation NotificationSoundCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.soundLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.soundLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.soundLabel.font = Design.FONT_REGULAR32;
    self.soundLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.soundLabel.text = nil;
}

- (void)bindWithName:(NSString *)name {
    
    self.soundLabel.text = name;
    
    [self updateFont];
    [self updateColor];
}

- (void)setChecked:(BOOL)checked {
    DDLogVerbose(@"%@ setChecked: %@", LOG_TAG, checked ? @"NO" : @"YES");
    
    if (_checked == checked) {
        return;
    }
    _checked = checked;
    
    if (_checked) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.soundLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.soundLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

@end
