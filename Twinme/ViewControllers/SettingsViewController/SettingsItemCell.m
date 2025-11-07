/*
 *  Copyright (c) 2018-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SettingsItemCell.h"

#import "MessageSettingsViewController.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SettingsItemCell
//

@interface SettingsItemCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet SwitchView *choiceSwitch;

@property (nonatomic) UITapGestureRecognizer *tapGesture;

@end


//
// Implementation: SettingsItemCell
//

#undef LOG_TAG
#define LOG_TAG @"SettingsItemCell"

@implementation SettingsItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.forceDarkMode = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInsideContent:)];
    self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
    
    self.titleWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.title.font = Design.FONT_REGULAR32;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.iconView.tintColor = Design.BLACK_COLOR;
    
    CGSize switchSize = [Design switchSize];
    self.choiceSwitch.userInteractionEnabled = NO;
    self.choiceSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.choiceSwitchWidthConstraint.constant = switchSize.width;
    self.choiceSwitchHeightConstraint.constant = switchSize.height;
    [self.choiceSwitch setOn:YES];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.choiceSwitch resetSwitch];
}

- (void)bindWithTitle:(NSString *)title icon:(UIImage *)icon stateSwitch:(BOOL)switchState tagSwitch:(int)tagSwitch hiddenSwitch:(BOOL)hiddenSwitch disableSwitch:(BOOL)disableSwitch backgroundColor:(UIColor *)backgroundColor hiddenSeparator:(BOOL)hiddenSeparator {
    DDLogVerbose(@"%@ bindWithTitle: %@ icon: %@ stateSwitch: %d tagSwitch: %d hiddenSwitch: %d disableSwitch: %d hiddenSeparator: %d", LOG_TAG, title, icon, switchState, tagSwitch, hiddenSwitch, disableSwitch, hiddenSeparator);
    
    self.title.text = title;
    
    self.choiceSwitch.hidden = hiddenSwitch;
    self.tapGesture.enabled = !hiddenSwitch;
    self.choiceSwitch.tag = tagSwitch;
    
    [self.choiceSwitch setOn:switchState];
    [self.choiceSwitch setEnabled:!disableSwitch];
    
    self.separatorView.hidden = hiddenSeparator;
    
    if (icon) {
        if (self.forceDarkMode) {
            self.contentView.backgroundColor = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
        } else {
            self.contentView.backgroundColor = backgroundColor;
        }
        
        self.iconView.hidden = NO;
        self.iconView.image = icon;
        self.titleLeadingConstraint.constant = self.iconViewLeadingConstraint.constant * 2 + self.iconViewHeightConstraint.constant;
    } else {
        if (self.forceDarkMode) {
            self.contentView.backgroundColor = [UIColor blackColor];
        } else {
            self.contentView.backgroundColor = backgroundColor;
        }
        
        self.iconView.hidden = YES;
        self.titleLeadingConstraint.constant = self.iconViewLeadingConstraint.constant;
    }
        
    [self updateFont];
    [self updateColor];
}

- (void)onTapInsideContent:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTapInsideContent: %@", LOG_TAG, tapGesture);
    
    if ([(id)self.settingsActionDelegate respondsToSelector:@selector(switchChangeValue:)]) {
        if (self.choiceSwitch.isEnabled) {
            [self.choiceSwitch setOn:!self.choiceSwitch.isOn];
        }
        
        [self.settingsActionDelegate switchChangeValue:self.choiceSwitch];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    if (self.forceDarkMode) {
        self.title.textColor = [UIColor whiteColor];
        self.separatorView.backgroundColor = [UIColor colorWithRed:199./255. green:199./255. blue:255./255. alpha:0.3];
        self.iconView.tintColor = [UIColor whiteColor];
    } else {
        self.title.textColor = Design.FONT_COLOR_DEFAULT;
        self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
        self.iconView.tintColor = Design.BLACK_COLOR;
    }
    
    [self.choiceSwitch resetSwitch];
}

@end
