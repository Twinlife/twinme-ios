/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "FAQCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIFAQArticle.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: FAQCell
//

@interface FAQCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: FAQCell
//

#undef LOG_TAG
#define LOG_TAG @"FAQCell"

@implementation FAQCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.questionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.questionLabel.font = Design.FONT_REGULAR32;
    self.questionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithArticle:(UIFAQArticle *)uiFAQArticle hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithArticle: %@ hideSeparator: %@", LOG_TAG, uiFAQArticle, hideSeparator ? @"YES" : @"NO");
    
    self.questionLabel.text = uiFAQArticle.question;
    self.separatorView.hidden = hideSeparator;

    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.questionLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.questionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
