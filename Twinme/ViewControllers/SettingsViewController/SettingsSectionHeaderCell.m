/*
 *  Copyright (c) 2019-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SettingsSectionHeaderCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "PaddingLabel.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SettingsSectionHeaderCell
//

@interface SettingsSectionHeaderCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsNewLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsNewLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet PaddingLabel *settingsNewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SettingsSectionHeaderCell
//

#undef LOG_TAG
#define LOG_TAG @"SettingsSectionHeaderCell"

@implementation SettingsSectionHeaderCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.title.font = Design.FONT_BOLD26;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.settingsNewLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsNewLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsNewLabel.font = Design.FONT_MEDIUM32;
    self.settingsNewLabel.textColor = [UIColor whiteColor];
    
    self.settingsNewLabel.textAlignment = NSTextAlignmentCenter;
    self.settingsNewLabel.insets = UIEdgeInsetsMake(0, Design.TEXT_PADDING, 0, Design.TEXT_PADDING);
    self.settingsNewLabel.text = TwinmeLocalizedString(@"application_new", nil);
    
    self.settingsNewLabel.clipsToBounds = YES;
    self.settingsNewLabel.userInteractionEnabled = YES;
    self.settingsNewLabel.backgroundColor = Design.MAIN_COLOR;
    self.settingsNewLabel.layer.cornerRadius = self.settingsNewLabelHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *settingsNewFeatureViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsNewFeatureTapGesture:)];
    [self.settingsNewLabel addGestureRecognizer:settingsNewFeatureViewGestureRecognizer];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString {
    DDLogVerbose(@"%@ bindWithTitle: %@ backgroundColor: %@", LOG_TAG, title, backgroundColor);
    
    [self updateViews:title backgroundColor:backgroundColor hideSeparator:hideSeparator uppercaseString:uppercaseString showNewFeature:NO];
}

- (void)bindWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString showNewFeature:(BOOL)showNewFeature {
    DDLogVerbose(@"%@ bindWithTitle: %@ backgroundColor: %@", LOG_TAG, title, backgroundColor);
 
    [self updateViews:title backgroundColor:backgroundColor hideSeparator:hideSeparator uppercaseString:uppercaseString showNewFeature:showNewFeature];
}

- (void)updateViews:(NSString *)title backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString showNewFeature:(BOOL)showNewFeature {
    
    if (uppercaseString) {
        self.title.text = title.uppercaseString;
    } else {
        self.title.text = title;
    }
    
    self.settingsNewLabel.hidden = !showNewFeature;
    
    self.contentView.backgroundColor = backgroundColor;
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)handleSettingsNewFeatureTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didTapNewFeature)]) {
            [self.delegate didTapNewFeature];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_BOLD26;
    self.settingsNewLabel.font = Design.FONT_MEDIUM32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.settingsNewLabel.backgroundColor = Design.MAIN_COLOR;
}

@end
