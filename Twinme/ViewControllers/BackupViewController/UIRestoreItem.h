/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    UIRestoreItemTypeHeader,
    UIRestoreItemTypeWords,
    UIRestoreItemTypeState,
    UIRestoreItemTypeSection,
    UIRestoreItemTypeContent,
    UIRestoreItemTypeInfo,
    UIRestoreItemTypeFooter,
    UIRestoreItemTypeUnknown
} UIRestoreItemType;

//
// Interface: UIRestoreItem
//

@interface UIRestoreItem : NSObject

- (instancetype)initWithType:(UIRestoreItemType)type text:(nullable NSString *)text icon:(nullable UIImage *)icon value:(int)value color:(nullable UIColor *)color;

- (UIRestoreItemType)getRestoreItemType;

- (nullable NSString *)getText;
    
- (nullable UIImage *)getIcon;

- (int)getValue;

- (nullable UIColor *)getColor;

@end
