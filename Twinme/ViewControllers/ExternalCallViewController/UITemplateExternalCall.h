/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    TemplateExternalCallTypeClassifiedAd,
    TemplateExternalCallTypeHelp,
    TemplateExternalCallTypeMeeting,
    TemplateExternalCallTypeVideoBell,
    TemplateExternalCallTypeOther
} TemplateExternalCallType;

@interface UITemplateExternalCall : NSObject

@property (nonatomic) TemplateExternalCallType templateType;

- (nonnull instancetype)initWithTemplateType:(TemplateExternalCallType)templateType;

- (nonnull NSString *)getName;

- (nonnull NSString *)getPlaceholder;

- (nullable UIImage *)getImage;

- (nullable NSString *)getImageUrl;

- (BOOL)voiceCallAllowed;

- (BOOL)videoCallAllowed;

- (BOOL)groupCallAllowed;

- (BOOL)hasSchedule;

@end

