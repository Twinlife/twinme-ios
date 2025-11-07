/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ShareSectionHeaderCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ShareSectionHeaderCell
//

@interface ShareSectionHeaderCell()

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;

@end

//
// Implementation: ShareSectionHeaderCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareSectionHeaderCell"

@implementation ShareSectionHeaderCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabel.font = Design.FONT_BOLD26;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)prepareForReuse {

    [super prepareForReuse];

    self.titleLabel.text = nil;
}

- (void)bindWithTitle:(NSString *)title {
    DDLogVerbose(@"%@ bindWithTitle: %@", LOG_TAG, title);
    
    self.titleLabel.text = title.uppercaseString;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
