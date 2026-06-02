/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIConfigExternalCall.h"

#import <Twinme/TLSchedule.h>

#import <Utils/NSString+Utils.h>

#import "UIScheduleDay.h"
#import "UITemplateExternalCall.h"
#import "UIConfigExternalCallItem.h"

//
// Interface: UIConfigExternalCall
//

@interface UIConfigExternalCall ()

@property (nonatomic) BOOL createExternalCallMode;

@end

//
// Implementation : UIConfigExternalCall
//

@implementation UIConfigExternalCall

- (nonnull instancetype)initWithCreateExternalCallMode:(BOOL)createExternalCallMode {
    
    self = [super init];
    
    if (self) {
        _createExternalCallMode = createExternalCallMode;
        _allowVoiceCall = YES;
        _allowVideoCall = YES;
        _allowGroupCall = NO;
        _notificationCallSetting = YES;
        _deleteLinkSetting = YES;
        _configTypeCall = ConfigExternalCallTypeCallDirect;
        _linkValidity = TLLinkValidityPermanent;
        _configItems = [[NSMutableArray alloc]init];
        [self setupDays];
    }
    
    return self;
}

- (void)initWithTemplate:(nonnull UITemplateExternalCall *)templateExternalCall {
    
    self.allowVoiceCall = [templateExternalCall voiceCallAllowed];
    self.allowVideoCall = [templateExternalCall videoCallAllowed];
    self.allowGroupCall = [templateExternalCall groupCallAllowed];
    self.linkValidity = [templateExternalCall validity];
    self.configTypeCall = [templateExternalCall configTypeCall];
    
    if (self.linkValidity == TLLinkValiditySingleUse && self.scheduleStartDate == nil) {
        [self initSchedule];
    } else if (self.linkValidity == TLLinkValidityPeriodic) {
        self.scheduleStartTime = [templateExternalCall getScheduleStartTime];
        self.scheduleEndTime = [templateExternalCall getScheduleEndTime];
        
        if ([templateExternalCall getScheduleRecurrentDays]) {
            for (NSNumber *days in [templateExternalCall getScheduleRecurrentDays]) {
                for (UIScheduleDay *scheduleDay in self.scheduleRecurrentDays) {
                    if (scheduleDay.dayOfWeek == days.integerValue) {
                        scheduleDay.isSelected = YES;
                        break;
                    }
                }
            }
        }
    }
    
    [self updateConfigItems];
}

- (void)updateWithCapabilities:(TLCapabilities *)capabilities isConferenceCall:(BOOL)isConferenceCall {
    
    self.configTypeCall = isConferenceCall ? ConfigExternalCallTypeCallConference : ConfigExternalCallTypeCallDirect;
    self.allowVoiceCall = [capabilities hasAudio];
    self.allowVideoCall = [capabilities hasVideo];
    self.allowGroupCall = [capabilities hasGroupCall];
    self.linkValidity = [capabilities linkValidity];
    self.notificationCallSetting = [capabilities hasNotifyJoin];
    
    if (capabilities.schedule) {
        TLSchedule *schedule = capabilities.schedule;
        
        if (capabilities.schedule.timeRanges.count > 0) {
            if ([schedule.timeRanges[0] isKindOfClass:[TLDateTimeRange class]]) {
                TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[capabilities.schedule.timeRanges objectAtIndex:0];
                self.scheduleStartDate = dateTimeRange.start.date;
                self.scheduleStartTime = dateTimeRange.start.time;
                self.scheduleEndDate = dateTimeRange.end.date;
                self.scheduleEndTime = dateTimeRange.end.time;
                
                if (schedule.enabled) {
                    self.linkValidity = TLLinkValiditySingleUse;
                } else {
                    self.linkValidity = TLLinkValidityPermanent;
                }
            } else if ([schedule.timeRanges[0] isKindOfClass:[TLWeeklyTimeRange class]]) {
                TLWeeklyTimeRange *weeklyTimeRange = (TLWeeklyTimeRange *)[capabilities.schedule.timeRanges objectAtIndex:0];
                self.scheduleStartTime = weeklyTimeRange.start;
                self.scheduleEndTime = weeklyTimeRange.end;
                for (NSNumber *dayOfWeek in weeklyTimeRange.days) {
                    [self updateDaySelected:(TLDayOfWeek)dayOfWeek.integerValue selected:YES];
                }
                
                if (schedule.enabled) {
                    self.linkValidity = TLLinkValidityPeriodic;
                } else {
                    self.linkValidity = TLLinkValidityPermanent;
                }
            }
        }
    }
        
    [self updateConfigItems];
}

- (BOOL)isCreateExternalCallMode {
    
    return self.createExternalCallMode;
}

- (void)setCallType:(ConfigExternalCallTypeCall)callType {
    
    self.configTypeCall = callType;
    [self updateConfigItems];
}

- (void)setValidity:(TLLinkValidity)validity {
    
    self.linkValidity = validity;
    
    if (self.linkValidity != TLLinkValidityPermanent && !self.scheduleStartDate) {
        [self initSchedule];
    }
    
    [self updateConfigItems];
}

- (void)updateConfigItems {
    
    [self.configItems removeAllObjects];
    
    if (self.createExternalCallMode) {
        [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsCallType]];
    }
    
    [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsPermissions]];
    [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsExpiration]];
    
    if (self.linkValidity != TLLinkValidityPermanent) {
        [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsScheduleStart]];
        [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsScheduleEnd]];
        
        if (self.linkValidity == TLLinkValidityPeriodic) {
            [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsScheduleRecurrent]];
        } else {
            [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsDelete]];
        }
    }
    
    if (self.configTypeCall == ConfigExternalCallTypeCallConference) {
        [self.configItems addObject:[[UIConfigExternalCallItem alloc]initWithConfigExternalCallSettings:ConfigExternalCallSettingsNotification]];
    }
}

- (nonnull NSMutableArray *)getSelectedDaysOfWeek {
    
    NSMutableArray *selectedDays = [[NSMutableArray alloc] init];
    for (UIScheduleDay *scheduleDay in self.scheduleRecurrentDays) {
        
        if (scheduleDay.isSelected) {
            [selectedDays addObject:@(scheduleDay.dayOfWeek)];
        }
    }
    
    return selectedDays;
}

- (void)setupDays {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    NSArray<NSString *> *symbols = formatter.veryShortWeekdaySymbols;
    
    self.scheduleRecurrentDays = [[NSMutableArray alloc]init];
    if (symbols.count == 7) {
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[1] dayOfWeek:MONDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[2] dayOfWeek:TUESDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[3] dayOfWeek:WEDNESDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[4] dayOfWeek:THURSDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[5] dayOfWeek:FRIDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[6] dayOfWeek:SATURDAY isSelected:NO]];
        [self.scheduleRecurrentDays addObject:[[UIScheduleDay alloc]initWithDay:symbols[0] dayOfWeek:SUNDAY isSelected:NO]];
    }
}

- (void)initSchedule {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:0];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:0];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
}

- (void)updateDaySelected:(TLDayOfWeek) dayOfWeek selected:(BOOL)selected {
    
    for (UIScheduleDay *scheduleDay in self.scheduleRecurrentDays) {
        if (scheduleDay.dayOfWeek == dayOfWeek) {
            scheduleDay.isSelected = selected;
            break;
        }
    }
}

+ (nonnull NSString *)getCallType:(ConfigExternalCallTypeCall)callType {
    
    if (callType == ConfigExternalCallTypeCallDirect) {
        return TwinmeLocalizedString(@"create_external_call_view_direct_call_short_title", nil);
    } else {
        return TwinmeLocalizedString(@"create_external_call_view_conference_call_short_title", nil);
    }
}

+ (nonnull NSString *)getValidity:(TLLinkValidity)validity {
    
    if (validity == TLLinkValidityPermanent) {
        return TwinmeLocalizedString(@"create_external_call_view_continuous_link_title", nil);
    } else if (validity == TLLinkValiditySingleUse) {
        return TwinmeLocalizedString(@"create_external_call_view_unique_link_title", nil);
    } else {
        return TwinmeLocalizedString(@"create_external_call_view_recurrent_link_title", nil);
    }
}

+ (nonnull NSString *)getCallCapabilities:(BOOL)allowVoiceCall allowVideo:(BOOL)allowVideoCall allowGroup:(BOOL)allowGroupCall {
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:@""];
    if (allowVoiceCall) {
        [message appendString:TwinmeLocalizedString(@"show_contact_view_audio", nil)];
    }
    
    if (allowVideoCall) {
        if (message.length > 0) {
            [message appendString:@", "];
        }
        [message appendString:TwinmeLocalizedString(@"show_contact_view_video", nil)];
    }
    
    if (allowGroupCall) {
        if (message.length > 0) {
            [message appendString:@", "];
        }
        [message appendString:TwinmeLocalizedString(@"show_group_view_title", nil)];
    }
        
    return message;
}

@end
