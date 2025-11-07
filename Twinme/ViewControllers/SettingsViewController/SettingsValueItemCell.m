/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SettingsValueItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_TITLE_WIDTH = 420;
static CGFloat DESIGN_TITLE_LARGE_WIDTH = 620;

//
// Interface: SettingsValueItemCell
//

@interface SettingsValueItemCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SettingsValueItemCell
//

#undef LOG_TAG
#define LOG_TAG @"SettingsValueItemCell"

@implementation SettingsValueItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.forceDarkMode = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_REGULAR32;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.valueLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.valueLabel.font = Design.FONT_REGULAR32;
    self.valueLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.accessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.accessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.accessoryImageView.image = [self.accessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    self.accessoryImageView.hidden = YES;
    
    self.selectImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.selectImageViewTrailingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.selectImageView.tintColor = Design.ACCESSORY_COLOR;
    self.selectImageView.hidden = YES;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithTitle:(NSString *)title value:(NSString *)value hiddenAccessory:(BOOL)hiddenAccessory {
    DDLogVerbose(@"%@ bindWithTitle: %@ value: %@ hiddenAccessory: %d ", LOG_TAG, title, value, hiddenAccessory);
    
    self.titleLabel.text = title;
    self.valueLabel.text = value;
    self.valueLabel.hidden = NO;
    self.selectImageView.hidden = YES;
    self.accessoryImageView.hidden = hiddenAccessory;
    self.titleLabelWidthConstraint.constant = DESIGN_TITLE_WIDTH * Design.WIDTH_RATIO;
    
    if (hiddenAccessory) {
        self.valueLabelTrailingConstraint.constant = self.accessoryImageViewTrailingConstraint.constant;
    } else {
        self.valueLabelTrailingConstraint.constant = self.accessoryImageView.frame.size.width +  (self.accessoryImageViewTrailingConstraint.constant * 2);
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)bindWithTitle:(nullable NSString *)title value:(nonnull NSString *)value backgroundColor:(nonnull UIColor *)backgroundColor {
    DDLogVerbose(@"%@ bindWithTitle: %@ value: %@ backgroundColor: %@", LOG_TAG, title, value, backgroundColor);
    
    self.contentView.backgroundColor = backgroundColor;
  
    self.valueLabel.hidden = YES;
    self.selectImageView.hidden = NO;
    self.titleLabelWidthConstraint.constant = DESIGN_TITLE_LARGE_WIDTH * Design.WIDTH_RATIO;
    
    UIColor *titleColor = Design.FONT_COLOR_DEFAULT;
    if (self.forceDarkMode) {
        titleColor = [UIColor whiteColor];
    }
    
    if (title) {
        NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, titleColor, NSForegroundColorAttributeName, nil]];
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:value attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        self.titleLabel.attributedText = valueAttributedString;
    } else {
        NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:value attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, titleColor, NSForegroundColorAttributeName, nil]];
        self.titleLabel.attributedText = valueAttributedString;
    }
    
    [self updateFont];
    [self updateColor];
}


- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    if (self.forceDarkMode) {
        self.contentView.backgroundColor = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
        self.separatorView.backgroundColor = [UIColor colorWithRed:199./255. green:199./255. blue:255./255. alpha:0.3];
        self.valueLabel.textColor = [UIColor whiteColor];
        
        if (self.selectImageView.hidden) {
            self.titleLabel.textColor = [UIColor whiteColor];
        }
    } else {
        self.contentView.backgroundColor = Design.WHITE_COLOR;
        self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
        self.valueLabel.textColor = Design.FONT_COLOR_DEFAULT;
        
        if (self.selectImageView.hidden) {
            self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
        }
    }
    
}

@end
