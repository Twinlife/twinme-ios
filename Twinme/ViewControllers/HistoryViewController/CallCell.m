/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "CallCell.h"

#import <TwinmeCommon/Design.h>
#import "UIContact.h"
#import "UICall.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallCell ()
//

@interface CallCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) TLCallDescriptor *callDescriptor;

@end

//
// Implementation: CallCell
//

#undef LOG_TAG
#define LOG_TAG @"CallCell"

@implementation CallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.typeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.typeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.typeViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.typeView.tintColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    
    self.typeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.typeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.typeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.typeLabel.font = Design.FONT_MEDIUM28;
    self.typeLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    
    self.dateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.dateLabel.font = Design.FONT_MEDIUM26;
    self.dateLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithCall:(UICall *)uiCall hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithCall: %@", LOG_TAG, uiCall);
    
    self.callDescriptor = [uiCall getLastCallDescriptor];
    self.certifiedRelationImageView.hidden = YES;
    self.nameLabelTrailingConstraint.constant = Design.NAME_TRAILING;
    
    if (uiCall.uiContact) {
        if ([uiCall getCount] > 1) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@ (%lu)", uiCall.uiContact.name, (unsigned long)[uiCall getCount]];
        } else {
            self.nameLabel.text = uiCall.uiContact.name;
        }
        
        if ([uiCall.uiContact.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
            self.avatarView.backgroundColor = Design.GREY_ITEM;
        } else {
            self.avatarView.backgroundColor = [UIColor clearColor];
        }
        
        self.avatarView.image = uiCall.uiContact.avatar;
        
        if (uiCall.uiContact.isCertified) {
            self.certifiedRelationImageView.hidden = NO;
            self.nameLabelTrailingConstraint.constant = (Design.NAME_TRAILING * 2) + self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
        }
    }
    
    if (self.callDescriptor.isVideo) {
        self.typeView.image = [UIImage imageNamed:@"HistoryVideoCall"];
    } else {
        self.typeView.image = [UIImage imageNamed:@"HistoryAudioCall"];
    }
    
    if (self.callDescriptor.isIncoming) {
        if([(NSObject *)uiCall.uiContact.contact class] != [TLCallReceiver class]){
            self.typeLabel.text = TwinmeLocalizedString(@"history_view_controller_incoming_call", nil);
        } else {
            self.typeLabel.text = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
        }
    } else {
        self.typeLabel.text = TwinmeLocalizedString(@"history_view_controller_outgoing_call", nil);
    }
    
    if (!self.callDescriptor.isAccepted && self.callDescriptor.isIncoming) {
        self.typeLabel.text = TwinmeLocalizedString(@"history_view_controller_missed_call", nil);
        self.nameLabel.textColor = Design.DELETE_COLOR_RED;
    } else {
        self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    self.dateLabel.text = [NSString formatCallTimeInterval:self.callDescriptor.createdTimestamp / 1000];
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    
    self.typeLabel.font = Design.FONT_MEDIUM28;
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.dateLabel.font = Design.FONT_MEDIUM26;
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    if (self.callDescriptor && !self.callDescriptor.isAccepted && self.callDescriptor.isIncoming) {
        self.nameLabel.textColor = Design.DELETE_COLOR_RED;
    } else {
        self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

@end
