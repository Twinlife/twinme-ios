/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlifeContext.h>

#import "ConnexionStatusCell.h"

#import <TwinmeCommon/Design.h>

#import "UIAppInfo.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ConnexionStatusCell
//

@interface ConnexionStatusCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: ConnexionStatusCell
//

#undef LOG_TAG
#define LOG_TAG @"ConnexionStatusCell"

@implementation ConnexionStatusCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bind:(UIAppInfo *)uiAppInfo proxy:(NSString *)proxy {
    DDLogVerbose(@"%@ bind: %@ proxy: %@", LOG_TAG, uiAppInfo, proxy);
    
    if (uiAppInfo) {
    
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[uiAppInfo getAppInfoTitle] attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        if (proxy) {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:proxy attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        
        self.nameLabel.attributedText = attributedString;
        
        self.iconView.image = [uiAppInfo getAppInfoImage];
    }
        
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
