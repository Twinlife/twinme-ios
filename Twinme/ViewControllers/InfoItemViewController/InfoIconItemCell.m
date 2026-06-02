/*
 *  Copyright (c) 2019-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "InfoIconItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InfoIconItemCell ()
//

@interface InfoIconItemCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: InfoIconItemCell
//

#undef LOG_TAG
#define LOG_TAG @"InfoIconItemCell"

@implementation InfoIconItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_REGULAR30;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.dateInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.font = Design.FONT_MEDIUM28;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithItem:(Item *)item infoItemType:(InfoItemType)infoItemType conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ infoItemType: %d conversationViewController: %@", LOG_TAG, item, infoItemType, conversationViewController);
   
    self.dateInfoLabel.text = @"";
    
    switch (infoItemType) {
        case InfoItemTypeDeleted:
            self.iconView.image = [UIImage imageNamed:@"ToolbarTrash"];
            self.iconView.tintColor = Design.DELETE_COLOR_RED;
            self.titleLabel.text = TwinmeLocalizedString(@"info_item_view_deleted", nil);
            if (item.peerDeletedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.peerDeletedTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeEphemeral:
            self.iconView.image = [UIImage imageNamed:@"EphemeralIcon"];
            self.iconView.tintColor = Design.BLACK_COLOR;
            self.titleLabel.text = TwinmeLocalizedString(@"application_timeout", nil);
            if (item.receivedTimestamp > 0) {
                int64_t timeInterval = (item.readTimestamp + item.expireTimeout) / 1000;
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:timeInterval];
            }
            
            break;
            
        default:
            break;
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_REGULAR30;
    self.dateInfoLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
