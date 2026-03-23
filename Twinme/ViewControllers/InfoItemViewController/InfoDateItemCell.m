/*
 *  Copyright (c) 2019-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "InfoDateItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InfoDateItemCell ()
//

@interface InfoDateItemCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: InfoDateItemCell
//

#undef LOG_TAG
#define LOG_TAG @"InfoDateItemCell"

@implementation InfoDateItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR30;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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

- (void)bindWithItem:(Item *)item infoDateItem:(InfoDateItem *)infoDateItem conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ infoDateItem: %@ conversationViewController: %@", LOG_TAG, item, infoDateItem, conversationViewController);
   
    self.dateInfoLabel.text = @"";
    self.nameLabel.text = infoDateItem.name;
    self.avatarView.image = infoDateItem.avatar;
    
    switch (infoDateItem.infoItemType) {
        case InfoItemTypeSent:
            if (item.createdTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.createdTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeReceived:
            if (item.receivedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.receivedTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeSeen:
            if (item.readTimestamp > item.updatedTimestamp) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.readTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeUpdated:
            if (item.updatedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.updatedTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeDeleted:
            if (item.peerDeletedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.peerDeletedTimestamp / 1000];
            }
            break;
            
        case InfoItemTypeEphemeral:
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
    
    self.nameLabel.font = Design.FONT_REGULAR30;
    self.dateInfoLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
