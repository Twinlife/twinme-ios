/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <UIKit/UIKit.h>

#import "ShareExtensionHeaderCell.h"

#import "DesignExtension.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ShareExtensionHeaderCell
//

@interface ShareExtensionHeaderCell()

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;

@end

//
// Implementation: ShareExtensionHeaderCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionHeaderCell"

@implementation ShareExtensionHeaderCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = DesignExtension.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.titleLabelLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.titleLabelHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    
    self.titleLabel.font = DesignExtension.FONT_BOLD26;
    self.titleLabel.textColor = DesignExtension.FONT_COLOR_DEFAULT;
}

- (void)bindWithTitle:(NSString *)title {
    DDLogVerbose(@"%@ bindWithTitle: %@", LOG_TAG, title);
    
    self.titleLabel.text = title.uppercaseString;
}

@end
