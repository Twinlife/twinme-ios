/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    TemplateTypeBusiness1,
    TemplateTypeBusiness2,
    TemplateTypeFamily1,
    TemplateTypeFamily2,
    TemplateTypeFriends1,
    TemplateTypeFriends2,
    TemplateTypeOther
} TemplateType;

@interface UITemplateSpace : NSObject

@property (nonatomic) TemplateType templateType;

- (nonnull instancetype)initWithTemplateType:(TemplateType)templateType;

- (nonnull NSString *)getSpace;

- (nullable NSString *)getProfile;

- (nonnull NSString *)getProfilePlaceholder;

- (nullable UIImage *)getImage;

- (nullable NSString *)getImageUrl;

- (nullable NSString *)getColor;

@end

