/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "CopyItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CopyItemCell ()
//

@interface CopyItemCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allowCopyLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allowCopyLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *allowCopyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allowCopyImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allowCopyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *allowCopyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: CopyItemCell
//

#undef LOG_TAG
#define LOG_TAG @"InfoItemCell"

@implementation CopyItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.allowCopyLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.allowCopyLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.allowCopyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.allowCopyLabel.font = Design.FONT_REGULAR32;
    
    self.allowCopyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.allowCopyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithItem:(Item *)item {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, item);
    
    if (([item isClearLocalItem]) || !item.copyAllowed) {
        self.allowCopyLabel.text =  TwinmeLocalizedString(@"info_item_view_controller_may_not_be_copied", nil);
        self.allowCopyImageView.image = [UIImage imageNamed:@"NotAllowedCopyIcon"];
    } else {
        self.allowCopyLabel.text =  TwinmeLocalizedString(@"info_item_view_controller_may_be_copied", nil);
        self.allowCopyImageView.image = [UIImage imageNamed:@"AllowedCopyIcon"];
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)handleSwitchTap:(UISwitch *)permissionSwitch {
    DDLogVerbose(@"%@ handleSwitchTap: %@", LOG_TAG, permissionSwitch);
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.allowCopyLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.allowCopyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
