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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleInfoLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateBubbleViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateBubbleViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *stateBubbleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
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
    
    self.titleInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleInfoLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleInfoLabel.font = Design.FONT_REGULAR32;
    
    self.dateInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.font = Design.FONT_REGULAR32;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.stateImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageView.layer.cornerRadius = self.stateImageViewHeightConstraint.constant * 0.5;
    self.stateImageView.clipsToBounds = YES;
    
    self.stateBubbleViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateBubbleViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateBubbleView.backgroundColor = Design.BLUE_NORMAL;
    self.stateBubbleView.alpha = 0.32;
    self.stateBubbleView.layer.cornerRadius = self.stateBubbleViewHeightConstraint.constant * 0.5;
    self.stateBubbleView.clipsToBounds = YES;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithItem:(Item *)item infoItemType:(InfoItemType)infoItemType conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ infoItemType: %d conversationViewController: %@", LOG_TAG, item, infoItemType, conversationViewController);
    
    self.stateBubbleView.hidden = NO;
    self.stateImageView.hidden = YES;
    
    self.dateInfoLabel.text = @"";
    
    switch (infoItemType) {
        case InfoItemTypeSent:
            self.titleInfoLabel.text = TwinmeLocalizedString(@"info_item_view_controller_sent",nil);
            
            if (item.createdTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.createdTimestamp / 1000];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [UIImage imageNamed:@"ItemStateSending"];
            }
            break;
            
        case InfoItemTypeReceived:
            self.titleInfoLabel.text = TwinmeLocalizedString(@"info_item_view_controller_received",nil);
            
            if (item.receivedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.receivedTimestamp / 1000];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [UIImage imageNamed:@"ItemStateReceived"];
            }
            break;
            
        case InfoItemTypeSeen:
            self.titleInfoLabel.text = TwinmeLocalizedString(@"info_item_view_controller_seen",nil);
            
            if (item.readTimestamp > item.updatedTimestamp) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.readTimestamp / 1000];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[item peerTwincodeOutboundId]];
            }
            break;
            
        case InfoItemTypeUpdated:
            self.titleInfoLabel.text = [NSString stringWithFormat:@"%@ :",TwinmeLocalizedString(@"info_item_view_controller_updated",nil)];
            
            if (item.updatedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.updatedTimestamp / 1000];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [UIImage imageNamed:@"EditStyle"];
            }
            break;
            
        case InfoItemTypeDeleted:
            self.titleInfoLabel.text = TwinmeLocalizedString(@"info_item_view_controller_deleted",nil);
            
            if (item.peerDeletedTimestamp > 0) {
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:item.peerDeletedTimestamp / 1000];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            }
            break;
            
        case InfoItemTypeEphemeral:
            self.titleInfoLabel.text = TwinmeLocalizedString(@"application_timeout",nil);
            
            if (item.receivedTimestamp > 0) {
                int64_t timeInterval = (item.readTimestamp + item.expireTimeout) / 1000;
                self.dateInfoLabel.text = [NSString formatItemTimeInterval:timeInterval];
                
                self.stateBubbleView.hidden = YES;
                self.stateImageView.hidden = NO;
                self.stateImageView.image = [UIImage imageNamed:@"EphemeralIcon"];
                self.stateImageView.tintColor = Design.BLACK_COLOR;
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
    
    self.titleInfoLabel.font = Design.FONT_REGULAR32;
    self.dateInfoLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.titleInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
