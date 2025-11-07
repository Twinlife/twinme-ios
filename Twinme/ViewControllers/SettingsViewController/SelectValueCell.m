/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SelectValueCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SalectValueCell
//

@interface SelectValueCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SelectValueCell
//

#undef LOG_TAG
#define LOG_TAG @"SelectValueCell"

@implementation SelectValueCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.valueLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.valueLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.valueLabel.font = Design.FONT_REGULAR34;
    
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
}

- (void)bindWithTitle:(NSString *)title subTitle:(NSString *)subtitle checked:(BOOL)checked hideBorder:(BOOL)hideBorder hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithTitle: %@ subTitle: %@", LOG_TAG, title, subtitle);
        
    NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    if (![subtitle isEqualToString:@""]) {
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    self.valueLabel.attributedText = valueAttributedString;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    if (hideBorder) {
        if (checked) {
            self.checkMarkView.hidden = NO;
        } else {
            self.checkMarkView.hidden = YES;
        }
    } else {
        self.checkMarkView.hidden = NO;
        if (checked) {
            self.checkMarkImageView.hidden = NO;
        } else {
            self.checkMarkImageView.hidden = YES;
        }
    }
    
    self.separatorView.hidden = hideSeparator;
}

@end
