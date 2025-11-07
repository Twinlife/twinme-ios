/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "StorageChartCell.h"

#import <TwinmeCommon/Design.h>

#import "UIStorage.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: StorageChartCell ()
//

@interface StorageChartCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *storageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageUsedViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *storageUsedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageAppViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *storageAppView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageTypeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageTypeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageTypeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *storageTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageValueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storageValueLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *storageValueLabel;

@end

//
// Implementation: StorageChartCell
//

#undef LOG_TAG
#define LOG_TAG @"StorageChartCell"

@implementation StorageChartCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.storageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.storageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.storageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.storageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.storageView.clipsToBounds = YES;
    self.storageView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.storageUsedViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.storageAppViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.storageTypeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
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

- (void)bindWithStorage:(NSArray *)storage {
    DDLogVerbose(@"%@ bindWithStorage: %@", LOG_TAG, storage);
        
    UIStorage *totalStorage = [storage lastObject];
    if (totalStorage) {
        self.storageTypeLabel.text = [totalStorage getTitle];
        self.storageValueLabel.text = [totalStorage getSize];
        
        self.storageView.backgroundColor = [totalStorage getBackgroundColor];
    }
    
    UIStorage *usedStorage;
    UIStorage *appStorage;
    
    for (UIStorage *uiStorage in storage) {
        if (uiStorage.storageType == StorageTypeUsed) {
            usedStorage = uiStorage;
        } else if (uiStorage.storageType == StorageTypeApp) {
            appStorage = uiStorage;
        }
    }
    
    if (usedStorage && appStorage) {
        float storageViewWidth = Design.DISPLAY_WIDTH - (self.storageViewLeadingConstraint.constant * 2);
        float storageUsedViewWidth = 0;
        float storageAppViewWidth = 0;
        if (usedStorage.size > 0) {
            storageUsedViewWidth = storageViewWidth * ((float) usedStorage.size / (float) totalStorage.size);
        }
        
        if (appStorage.size > 0) {
            storageAppViewWidth = storageViewWidth * ((float) appStorage.size / (float) totalStorage.size);
        }
        
        self.storageUsedViewWidthConstraint.constant = storageUsedViewWidth;
        self.storageAppViewWidthConstraint.constant = storageAppViewWidth;
        
        self.storageUsedView.backgroundColor = [usedStorage getBackgroundColor];
        self.storageAppView.backgroundColor = [appStorage getBackgroundColor];
    }
        
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}


@end
