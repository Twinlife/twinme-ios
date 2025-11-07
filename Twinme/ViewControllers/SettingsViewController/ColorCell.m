/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "UICustomColor.h"
#import "ColorCell.h"
#import "EditSpaceViewController.h"

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_CONTENT_PROPORTIONNAL_HEIGHT = 0.75f;

//
// Interface: ColorCell ()
//

@interface ColorCell ()

@property (weak, nonatomic) IBOutlet UIView *contentColorView;
@property (weak, nonatomic) IBOutlet UIImageView *contentNoColorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (nonatomic) UICustomColor *customColor;

@end

//
// Implementation: ColorCell
//

#undef LOG_TAG
#define LOG_TAG @"ColorCell"

@implementation ColorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    tapContentGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant / 2.0;
    
    self.contentColorView.layer.cornerRadius = (self.colorViewHeightConstraint.constant * DESIGN_CONTENT_PROPORTIONNAL_HEIGHT) / 2.0;
    
    self.separatorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.separatorView.backgroundColor = [UIColor colorWithRed:35./255. green:42./255. blue:69./255. alpha:1.0];
}

- (void)bindWithColor:(UICustomColor *)customColor {
    DDLogVerbose(@"%@ bindWithColor: %@", LOG_TAG, customColor);
    
    self.customColor = customColor;
    
    if (customColor.color) {
        self.contentColorView.backgroundColor = [UIColor colorWithHexString:customColor.color alpha:1.0];
        self.contentColorView.hidden = NO;
        self.separatorView.hidden = YES;
        self.contentNoColorView.hidden = YES;
    } else {
        self.contentColorView.hidden = YES;
        self.separatorView.hidden = NO;
        self.contentNoColorView.hidden = NO;
        self.contentNoColorView.image = [UIImage imageNamed:@"NoStyleSpace"];
    }
    
    if (customColor.selectedColor) {
        self.colorView.layer.borderWidth = 1.0;
        self.colorView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    } else {
        self.colorView.layer.borderWidth = 0.0;
    }    
}

- (void)bindWithEditStyle:(BOOL)isSelected {
    DDLogVerbose(@"%@ bindWithEditStyle: %@", LOG_TAG, isSelected ? @"YES" : @"NO");
    
    self.contentColorView.hidden = YES;
    self.separatorView.hidden = YES;
    self.contentNoColorView.hidden = NO;
    self.contentNoColorView.image = [UIImage imageNamed:@"EditStyle"];
    
    if (isSelected) {
        self.colorView.layer.borderWidth = 1.0;
        self.colorView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    } else {
        self.colorView.layer.borderWidth = 0.0;
    }
    
    [self updateColor];
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if ([self.customColorDelegate respondsToSelector:@selector(didSelectCustomColor:)]) {
        [self.customColorDelegate didSelectCustomColor:self.customColor];
    }
}

- (void)updateColor {
    
    self.backgroundColor = [UIColor clearColor];
}

@end
