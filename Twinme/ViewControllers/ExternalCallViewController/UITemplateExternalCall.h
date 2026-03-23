/*
 *  Copyright (c) 2023-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIConfigExternalCall.h"
#import <Twinme/TLCapabilities.h>

typedef enum {
    TemplateExternalCallTypeClassifiedAd,
    TemplateExternalCallTypeHelp,
    TemplateExternalCallTypeJob,
    TemplateExternalCallTypeMeeting,
    TemplateExternalCallTypeVideoBell,
    TemplateExternalCallTypeProfile,
    TemplateExternalCallTypeOther
} TemplateExternalCallType;

//
// Interface: UITemplateExternalCall
//

@interface UITemplateExternalCall : NSObject

@property (nonatomic) TemplateExternalCallType templateType;

- (nonnull instancetype)initWithTemplateType:(TemplateExternalCallType)templateType;

- (void)updateName:(nonnull NSString *)name image:(nonnull UIImage *)image;

- (nonnull NSString *)getName;

- (nullable NSString *)getMessage;

- (nonnull NSString *)getPlaceholder;

- (nullable UIImage *)getImage;

- (nullable NSString *)getImageUrl;

- (BOOL)voiceCallAllowed;

- (BOOL)videoCallAllowed;

- (BOOL)groupCallAllowed;

- (TLLinkValidity)validity;

- (ConfigExternalCallTypeCall)configTypeCall;

- (nullable NSArray *)getScheduleRecurrentDays;

- (nonnull TLTime *)getScheduleStartTime;

- (nonnull TLTime *)getScheduleEndTime;

@end

