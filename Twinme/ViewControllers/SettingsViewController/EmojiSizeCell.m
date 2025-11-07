/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "EmojiSizeCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString * EMOJI_CODE = @"\U0001F609";

//
// Interface: EmojiSizeCell
//

@interface EmojiSizeCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: EmojiSizeCell
//

#undef LOG_TAG
#define LOG_TAG @"EmojiSizeCell"

@implementation EmojiSizeCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.emojiLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.emojiLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.emojiLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.emojiLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.emojiLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.emojiLabel.text = EMOJI_CODE;
    
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.title.font = Design.FONT_REGULAR32;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
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

- (void)bindWithTitle:(NSString *)title emojiSize:(int)emojiSize checked:(BOOL)checked {
    DDLogVerbose(@"%@ bindWithTitle: %@ checked: %@", LOG_TAG, title, checked ? @"YES" : @"NO");
    
    self.title.text = title;
    
    self.emojiLabel.font = [Design getSampleEmojiFont:EmojiSizeLarge];
    self.emojiLabelWidthConstraint.constant = self.emojiLabel.intrinsicContentSize.width;
    
    self.emojiLabel.font = [Design getSampleEmojiFont:emojiSize];
    
    if (checked) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
        
    [self updateFont];
    [self updateColor];
}


- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

@end
