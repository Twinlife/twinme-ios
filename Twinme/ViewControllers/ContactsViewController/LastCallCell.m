/*
 *  Copyright (c) 2026 twinlife SA.
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

#import "LastCallCell.h"

#import <TwinmeCommon/Design.h>
#import "UIContact.h"
#import "UICall.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: LastCallCell ()
//

@interface LastCallCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) TLCallDescriptor *callDescriptor;

@end

//
// Implementation: LastCallCell
//

#undef LOG_TAG
#define LOG_TAG @"LastCallCell"

@implementation LastCallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.typeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.typeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.typeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.typeViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.typeView.tintColor = Design.BLACK_COLOR;
    
    self.typeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.typeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.typeLabel.font = Design.FONT_MEDIUM28;
    self.typeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.durationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.durationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.durationLabel.font = Design.FONT_MEDIUM28;
    self.durationLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    
    self.dateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.dateLabel.font = Design.FONT_MEDIUM26;
    self.dateLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    
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
    
    if (self.callDescriptor.isVideo) {
        self.typeView.image = [UIImage imageNamed:@"HistoryVideoCall"];
    } else {
        self.typeView.image = [UIImage imageNamed:@"HistoryAudioCall"];
    }
    
    NSString *callDuration = @"";
    if (self.callDescriptor.isTerminated && self.callDescriptor.duration > 0) {
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
        dateComponentsFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        callDuration = [dateComponentsFormatter stringFromTimeInterval:self.callDescriptor.duration / 1000];
    }
    
    NSString *callType = @"";
    if (self.callDescriptor.isIncoming) {
        if([(NSObject *)uiCall.uiContact.contact class] != [TLCallReceiver class]){
            callType = TwinmeLocalizedString(@"calls_view_incoming_call", nil);
        } else {
            callType = TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil);
        }
    } else {
        callType = TwinmeLocalizedString(@"calls_view_outgoing_call", nil);
    }
    
    self.typeLabel.text = callType;
    self.durationLabel.text = callDuration;
    
    if (!self.callDescriptor.isAccepted && self.callDescriptor.isIncoming) {
        self.durationLabel.text = TwinmeLocalizedString(@"calls_view_missed_call", nil);
        self.durationLabel.textColor = Design.DELETE_COLOR_RED;
    } else {
        self.durationLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    }
    
    self.dateLabel.text = [NSString formatCallTimeInterval:self.callDescriptor.createdTimestamp / 1000];
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    
    self.typeLabel.font = Design.FONT_MEDIUM34;
    self.durationLabel.font = Design.FONT_MEDIUM28;
    self.dateLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.typeView.tintColor = Design.BLACK_COLOR;
    
    if (self.callDescriptor && !self.callDescriptor.isAccepted && self.callDescriptor.isIncoming) {
        self.durationLabel.textColor = Design.DELETE_COLOR_RED;
    } else {
        self.durationLabel.textColor = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    }
}

@end
