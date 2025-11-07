/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "StorageCell.h"

#import <TwinmeCommon/Design.h>

#import "UIStorage.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: StorageCell ()
//

@interface StorageCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageTypeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageTypeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *storageTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageValueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageValueLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *storageValueLabel;

@end

//
// Implementation: StorageCell
//

#undef LOG_TAG
#define LOG_TAG @"StorageCell"

@implementation StorageCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.colorViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.colorView.clipsToBounds = YES;
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant * 0.5f;
    
    self.storageTypeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.storageTypeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.storageTypeLabel.font = Design.FONT_MEDIUM30;
    self.storageTypeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.storageValueLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.storageValueLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.storageValueLabel.font = Design.FONT_MEDIUM30;
    self.storageValueLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.storageValueLabel.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)bindWithStorage:(UIStorage *)uiStorage {
    DDLogVerbose(@"%@ bindWithStorage: %@", LOG_TAG, uiStorage);
        
    self.storageTypeLabel.text = [uiStorage getTitle];
    self.storageValueLabel.text = [uiStorage getSize];
    
    self.colorView.backgroundColor = [uiStorage getBackgroundColor];
    
    UIColor *borderColor = [uiStorage getBorderColor];
    if (borderColor) {
        self.colorView.layer.borderWidth = 1;
        self.colorView.layer.borderColor = borderColor.CGColor;
    } else {
        self.colorView.layer.borderWidth = 0;
        self.colorView.layer.borderColor = borderColor.CGColor;
    }
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}


@end
