/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

typedef enum {
    InfoItemTypeSent,
    InfoItemTypeReceived,
    InfoItemTypeSeen,
    InfoItemTypeDeleted,
    InfoItemTypeEphemeral,
    InfoItemTypeUpdated,
} InfoItemType;

//
// Interface: InfoDateItem
//

@interface InfoDateItem : Item

@property (nonatomic) InfoItemType infoItemType;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;

- (nonnull instancetype)initWithType:(InfoItemType)infoItemType name:(nonnull NSString *)name image:(nonnull UIImage *)avatar;

@end
