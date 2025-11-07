/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "UICustomColor.h"
#import "AppearanceColorCell.h"

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AppearanceColorCell ()
//

@interface AppearanceColorCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: AppearanceColorCell
//

#undef LOG_TAG
#define LOG_TAG @"AppearanceColorCell"

@implementation AppearanceColorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.colorLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.colorLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.colorLabel.font = Design.FONT_REGULAR32;
    self.colorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.thumbnailImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.thumbnailImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant / 2.0;
    self.colorView.layer.borderColor = Design.ITEM_BORDER_COLOR.CGColor;
    self.colorView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)bindWithColor:(UIColor *)color nameColor:(NSString *)nameColor image:(UIImage *)image {
    DDLogVerbose(@"%@ bindWithColor: %@ nameColor: %@ image: %@", LOG_TAG, color, nameColor, image);
    
    self.colorLabel.text = nameColor;
    
    if (color) {
        self.colorView.backgroundColor = color;
        self.colorView.hidden = NO;
        self.thumbnailImageView.hidden = YES;
    } else if (image) {
        self.colorView.hidden = YES;
        self.thumbnailImageView.hidden = NO;
        self.thumbnailImageView.image = image;
    }
    
    [self updateColor];
    [self updateFont];
}

- (void)updateFont {
    
    self.colorLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.colorLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

