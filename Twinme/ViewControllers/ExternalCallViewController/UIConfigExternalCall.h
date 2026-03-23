/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinme/TLCapabilities.h>
#import <Twinme/TLTimeRange.h>

#define PROPERTY_CALL_RECEIVER_UPDATE_COUNTER @"CallReceiverUpdateCounter"

typedef enum {
    ConfigExternalCallSettingsCallType,
    ConfigExternalCallSettingsPermissions,
    ConfigExternalCallSettingsExpiration,
    ConfigExternalCallSettingsScheduleStart,
    ConfigExternalCallSettingsScheduleEnd,
    ConfigExternalCallSettingsScheduleRecurrent,
    ConfigExternalCallSettingsDelete,
    ConfigExternalCallSettingsNotification
} ConfigExternalCallSettings;

typedef enum {
    ConfigExternalCallTypeCallDirect,
    ConfigExternalCallTypeCallConference
} ConfigExternalCallTypeCall;

@class TLDate;
@class TLTime;
@class UITemplateExternalCall;
@class TLCapabilities;

//
// Interface: UIConfigExternalCall
//

@interface UIConfigExternalCall : NSObject

@property (nonatomic) ConfigExternalCallSettings configExternalCallSettings;
@property (nonatomic) ConfigExternalCallTypeCall configTypeCall;
@property (nonatomic) TLLinkValidity linkValidity;
@property (nonatomic, nonnull) NSMutableArray *configItems;
@property (nonatomic, nullable) TLDate *scheduleStartDate;
@property (nonatomic, nullable) TLTime *scheduleStartTime;
@property (nonatomic, nullable) TLDate *scheduleEndDate;
@property (nonatomic, nullable) TLTime *scheduleEndTime;
@property (nonatomic, nonnull) NSMutableArray *scheduleRecurrentDays;
@property (nonatomic) BOOL allowVoiceCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) BOOL allowGroupCall;
@property (nonatomic) BOOL deleteLinkSetting;
@property (nonatomic) BOOL notificationCallSetting;

- (nonnull instancetype)initWithCreateExternalCallMode:(BOOL)createExternalCallMode;

- (void)initWithTemplate:(nonnull UITemplateExternalCall *)templateExternalCall;

- (void)updateWithCapabilities:(nonnull TLCapabilities *)capabilities isConferenceCall:(BOOL)isConferenceCall;

- (void)setCallType:(ConfigExternalCallTypeCall)callType;

- (void)setValidity:(TLLinkValidity)validity;
    
+ (nonnull NSString *)getCallCapabilities:(BOOL)allowVoiceCall allowVideo:(BOOL)allowVideoCall allowGroup:(BOOL)allowGroupCall ;

+ (nonnull NSString *)getCallType:(ConfigExternalCallTypeCall)callType;

+ (nonnull NSString *)getValidity:(TLLinkValidity)validity;

- (void)updateConfigItems;

- (nonnull NSMutableArray *)getSelectedDaysOfWeek;

- (void)updateDaySelected:(TLDayOfWeek)dayOfWeek selected:(BOOL)selected;

@end
