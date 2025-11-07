/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CustomTabCell.h"

#import <TwinmeCommon/Design.h>
#import "UICustomTab.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CustomTabCell ()
//

@interface CustomTabCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tabLabel;

@end

//
// Implementation: CustomTabCell
//

#undef LOG_TAG
#define LOG_TAG @"CustomTabCell"

@implementation CustomTabCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.isAccessibilityElement = YES;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.tabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.tabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tabViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.tabViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.tabView.clipsToBounds = YES;
    self.tabView.layer.cornerRadius = self.tabViewHeightConstraint.constant * 0.5f;
    self.tabView.backgroundColor = [UIColor clearColor];
    
    self.tabLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tabLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.tabLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.tabLabel.font = Design.FONT_REGULAR34;
    self.tabLabel.lineBreakMode = NSLineBreakByClipping;
}

- (void)bindWithCustomTab:(UICustomTab *)uiCustomTab mainColor:(UIColor *)mainColor textSelectedColor:(UIColor *)textSelectedColor {
    DDLogVerbose(@"%@ bindWithCustomTab: %@", LOG_TAG, uiCustomTab);
    
    self.tabLabel.layer.cornerRadius = self.frame.size.height * 0.5;
    self.tabLabel.text = uiCustomTab.title;
        
    if (uiCustomTab.isSelected) {
        self.tabView.backgroundColor = mainColor;
        self.tabLabel.textColor = textSelectedColor;
    } else {
        self.tabView.backgroundColor = [UIColor clearColor];
        self.tabLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.tabLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
