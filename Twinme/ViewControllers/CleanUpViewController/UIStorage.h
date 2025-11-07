/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    StorageTypeTotal,
    StorageTypeUsed,
    StorageTypeFree,
    StorageTypeApp,
    StorageTypeConversation
} StorageType;


//
// Interface: UIStorage
//

@interface UIStorage : NSObject

@property (nonatomic) StorageType storageType;
@property (nonatomic) int64_t size;
@property (nonatomic, nullable) NSString *conversationName;

- (nonnull instancetype)initWithStorageType:(StorageType)storageType size:(int64_t)size name:(nullable NSString *)name;

- (nonnull NSString *)getTitle;

- (nonnull NSString *)getSize;

- (void)setStorageSize:(int64_t)size;

- (nullable UIColor *)getBackgroundColor;

- (nullable UIColor *)getBorderColor;

@end
