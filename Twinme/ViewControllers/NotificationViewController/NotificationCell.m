/*
 *  Copyright (c) 2017-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Utils/NSString+Utils.h>

#import "NotificationCell.h"
#import "UINotification.h"
#import "UIReaction.h"

#import <TwinmeCommon/Design.h>
#import "NotificationViewController.h"

#import "UIColor+Hex.h"

static UIColor *DESIGN_TIME_COLOR;

//
// Interface: NotificationCell ()
//

@interface NotificationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redMarkHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redMarkLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *redMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) CGFloat contentViewX;

@end

//
// Implementation: NotificationCell
//

@implementation NotificationCell

+ (void)initialize {
    
    DESIGN_TIME_COLOR = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1];
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = Design.WHITE_COLOR;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_MEDIUM34;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.timeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.timeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.timeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.timeLabel.font = Design.FONT_MEDIUM26;
    self.timeLabel.textColor = DESIGN_TIME_COLOR;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.typeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.typeViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.subtitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.subtitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.subtitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.subtitleLabel.font = Design.FONT_MEDIUM28;
    self.subtitleLabel.textColor = DESIGN_TIME_COLOR;
    
    self.redMarkHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.redMarkLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.redMarkView.backgroundColor = Design.MAIN_COLOR;
    self.redMarkView.layer.cornerRadius = self.redMarkHeightConstraint.constant * 0.5;
    self.redMarkView.layer.masksToBounds = YES;
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
    
    self.contentViewX = 0;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.contentViewX = 0;
}

- (void)bindNotification:(UINotification *)uiNotification hideSeparator:(BOOL)hideSeparator {
        
    TLNotification *notification = [uiNotification getLastNotification];
    
    [self setAcknowledged:notification.acknowledged];
        
    TLGroupMember *groupMember = uiNotification.groupMember;
    if (groupMember) {
        
        NSString *notificationName = groupMember.name;
        UIImage *notificationAvatar = uiNotification.avatar;
        
        if (notification.notificationType == TLNotificationTypeUpdatedAnnotation) {
            notificationName = notification.user.name;
            notificationAvatar = uiNotification.annotationAvatar;
        }
        
        NSString *title;
        if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
            title = [NSString stringWithFormat:@"%@ - %@", notificationName, groupMember.group.name];
        } else {
            title = [NSString stringWithFormat:@"%@ - %@", groupMember.group.name, notificationName];
        }
        
        self.titleLabel.text = title;
        self.avatarView.image = notificationAvatar;
    } else {
        id<TLRepositoryObject> subject = notification.subject;
        if ([subject isKindOfClass:[TLContact class]] && ![(TLContact *)subject hasPeer]) {
            self.avatarView.image = [TLContact ANONYMOUS_AVATAR];
            self.titleLabel.text = subject.name;
        } else {
            self.avatarView.image = uiNotification.avatar;
            self.titleLabel.text = subject.name;
        }
    }
    
    if ([self.avatarView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
    
    if (uiNotification.isCertifiedContact) {
        self.certifiedRelationImageView.hidden = NO;
        self.timeLabelLeadingConstraint.constant = Design.NAME_TRAILING + self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
    } else {
        self.certifiedRelationImageView.hidden = YES;
        self.timeLabelLeadingConstraint.constant = Design.NAME_TRAILING;
    }
    
    self.typeView.tintColor = [UIColor clearColor];
    
    NSString *messageType = @"";
    switch (notification.notificationType) {
        case TLNotificationTypeNewContact:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_new_contact", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationNewContact"];
            break;
            
        case TLNotificationTypeUpdatedContact:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_updated_contact_name", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationUpdateContact"];
            break;
            
        case TLNotificationTypeUpdatedAvatarContact:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_updated_contact_avatar", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationUpdateContact"];
            break;
            
        case TLNotificationTypeDeletedContact:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_deleted_contact", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationRemoveContact"];
            self.typeView.tintColor = Design.DELETE_COLOR_RED;
            break;
            
        case TLNotificationTypeMissedAudioCall:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_audio_call", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationAudioCall"];
            break;
            
        case TLNotificationTypeMissedVideoCall:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_video_call", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationVideoCall"];
            break;
            
        case TLNotificationTypeResetConversation:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_cleanup_conversation", nil);
            self.typeView.image = [UIImage imageNamed:@"ToolbarTrash"];
            self.typeView.tintColor = Design.DELETE_COLOR_RED;
            break;
            
        case TLNotificationTypeNewTextMessage:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_text_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationTextMessage"];
            break;
            
        case TLNotificationTypeNewImageMessage:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_image_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationImageMessage"];
            break;
            
        case TLNotificationTypeNewAudioMessage:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_audio_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationAudioMessage"];
            self.typeView.tintColor = Design.BLACK_COLOR;
            break;
            
        case TLNotificationTypeNewVideoMessage:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_video_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationVideoMessage"];
            break;
            
        case TLNotificationTypeNewFileMessage:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_file_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationFileMessage"];
            self.typeView.tintColor = Design.BLACK_COLOR;
            break;
            
        case TLNotificationTypeNewGroupInvitation:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_group_invitation", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationInvitationGroup"];
            break;
            
        case TLNotificationTypeNewGroupJoined:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_join_group", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationJoinGroup"];
            break;
            
        case TLNotificationTypeNewContactInvitation:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_group_invitation", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationInvitationGroup"];
            break;
            
        case TLNotificationTypeUpdatedAnnotation:
            messageType = TwinmeLocalizedString(@"notification_center_reaction_message", nil);
            self.typeView.image = [UIReaction getNotificationImageWithReactionType:notification.annotationValue];
            self.typeView.tintColor = Design.BLACK_COLOR;
            break;
            
        case TLNotificationTypeNewGeolocation:
            messageType = TwinmeLocalizedString(@"notification_view_controller_item_geolocation_message", nil);
            self.typeView.image = [UIImage imageNamed:@"NotificationLocationMessage"];
            break;
            
        case TLNotificationTypeDeletedGroup:
        case TLNotificationTypeUnknown:
            break;
    }
    
    if ([uiNotification getCount] > 1) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"%@ (%lu)", messageType, (unsigned long)[uiNotification getCount]];
    } else {
        self.subtitleLabel.text = messageType;
    }
    
    self.timeLabel.text = [self getTimeAgo:notification.timestamp];
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)setAcknowledged:(BOOL)acknowledged {
    
    self.redMarkView.hidden = acknowledged;
}

#pragma mark - Date Util

- (NSString *)getTimeAgo:(int64_t)timestamp {
    
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc]init];
    dateComponentsFormatter.allowedUnits = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay;
    dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    dateComponentsFormatter.collapsesLargestUnit = YES;
    dateComponentsFormatter.maximumUnitCount = 1;
    
    int64_t diff = [[NSDate date] timeIntervalSince1970] * 1000 - timestamp;
    NSString *timeAgo = [dateComponentsFormatter stringFromTimeInterval:diff / 1000];
    
    if (!timeAgo) {
        return @"";
    }
    
    return timeAgo;
}

- (void)updateFont {
    
    self.titleLabel.font = Design.FONT_MEDIUM34;
    self.timeLabel.font = Design.FONT_MEDIUM26;
    self.subtitleLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
