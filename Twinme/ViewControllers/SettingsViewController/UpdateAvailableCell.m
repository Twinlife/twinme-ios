/*
 *  Copyright (c) 2022-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AboutViewController.h"
#import "UpdateAvailableCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: UpdateAvailableCell
//

@interface UpdateAvailableCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *updateAvailableLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *updateAvailableImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: UpdateAvailableCell
//

#undef LOG_TAG
#define LOG_TAG @"UpdateAvailableCell"

@implementation UpdateAvailableCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.notificationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.notificationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.notificationView.clipsToBounds = YES;
    self.notificationView.backgroundColor = Design.DELETE_COLOR_RED;
    self.notificationView.layer.cornerRadius = self.notificationViewHeightConstraint.constant * 0.5;
    
    self.updateAvailableLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.updateAvailableLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.updateAvailableLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.updateAvailableLabel.font = Design.FONT_REGULAR34;
    
    self.updateAvailableImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.updateAvailableImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.updateAvailableImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)bind:(NSString *)version {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"update_app_view_update_available", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:version attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.updateAvailableLabel.attributedText = attributedString;
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.updateAvailableImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
