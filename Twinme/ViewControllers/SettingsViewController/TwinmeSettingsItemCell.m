/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TwinmeSettingsItemCell.h"

#import <TwinmeCommon/Design.h>

#import "PaddingLabel.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: TwinmeSettingsItemCell
//

@interface TwinmeSettingsItemCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badgeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badgeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet PaddingLabel *badgeLabel;

@end

//
// Implementation: TwinmeSettingsItemCell
//

#undef LOG_TAG
#define LOG_TAG @"TwinmeSettingsItemCell"

@implementation TwinmeSettingsItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.title.font = Design.FONT_REGULAR32;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.accessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.accessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.accessoryImageView.image = [self.accessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.notificationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.notificationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.notificationView.clipsToBounds = YES;
    self.notificationView.backgroundColor = Design.DELETE_COLOR_RED;
    self.notificationView.layer.cornerRadius = self.notificationViewHeightConstraint.constant * 0.5;
    self.notificationView.hidden = YES;
    
    self.badgeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.badgeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.badgeLabel.font = Design.FONT_MEDIUM32;
    self.badgeLabel.textColor = [UIColor whiteColor];
    
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.insets = UIEdgeInsetsMake(0, Design.TEXT_PADDING, 0, Design.TEXT_PADDING);
    
    self.badgeLabel.hidden = YES;
    self.badgeLabel.clipsToBounds = YES;
    self.badgeLabel.userInteractionEnabled = YES;
    self.badgeLabel.backgroundColor = Design.MAIN_COLOR;
    self.badgeLabel.layer.cornerRadius = self.badgeLabelHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *badgeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBadgeTapGesture:)];
    [self.badgeLabel addGestureRecognizer:badgeViewGestureRecognizer];
}

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color {
    DDLogVerbose(@"%@ bindWithTitle: %@ hiddenAccessory: %d disableSetting: %d", LOG_TAG, title, hiddenAccessory, disableSetting);
    
    self.title.text = title;
    self.title.textColor = color;
    self.accessoryImageView.hidden = hiddenAccessory;
    self.notificationView.hidden = YES;
    
    if (disableSetting) {
        self.title.alpha = 0.5;
        self.accessoryImageView.alpha = 0.5;
    } else {
        self.title.alpha = 1.0;
        self.accessoryImageView.alpha = 1.0;
    }
    
    self.badgeLabel.hidden = YES;
    
    [self updateFont];
    [self updateColor];
}

- (void)bindWithTitle:(nonnull NSString *)title subTitle:(nullable NSString *)subTitle hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color {
    DDLogVerbose(@"%@ bindWithTitle: %@ subTitle: %@ hiddenAccessory: %d disableSetting: %d", LOG_TAG, title, subTitle, hiddenAccessory, disableSetting);
    
    [self bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:disableSetting color:color];
    
    if (subTitle && subTitle.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        
        self.title.attributedText = attributedString;
    }
}

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting updateAvailable:(BOOL)updateAvailable color:(nonnull UIColor *)color {
    
    [self bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:disableSetting color:color];
    
    self.notificationView.hidden = !updateAvailable;
}

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color badgeTitle:(nullable NSString *)badgeTitle showNotification:(BOOL)showNotification {
    
    [self bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:disableSetting color:color];
        
    if (badgeTitle && badgeTitle.length > 0) {
        self.badgeLabel.text = badgeTitle;
        self.badgeLabel.hidden = NO;
    } else {
        self.badgeLabel.hidden = YES;
    }
    
    self.notificationView.hidden = !showNotification;
}

- (void)handleBadgeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.self.delegate && [self.delegate respondsToSelector:@selector(didTapSettingsBadge)]) {
            [self.delegate didTapSettingsBadge];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
