/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIStorage.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

//
// Implementation: UIStorage
//

@implementation UIStorage

- (nonnull instancetype)initWithStorageType:(StorageType)storageType size:(int64_t)size name:(nullable NSString *)name {
    
    self = [super init];
    
    if (self) {
        _storageType = storageType;
        _size = size;
        _conversationName = name;
    }
    return self;
}

- (void)setStorageSize:(int64_t)size {
    
    self.size = size;
}

- (nonnull NSString *)getTitle {
    
    NSString *title = @"";
    
    switch (self.storageType) {
        case StorageTypeTotal:
            title = TwinmeLocalizedString(@"cleanup_view_controller_total", nil);
            break;
            
        case StorageTypeUsed:
            title = TwinmeLocalizedString(@"cleanup_view_controller_used", nil);
            break;
            
        case StorageTypeFree:
            title = TwinmeLocalizedString(@"cleanup_view_controller_free", nil);
            break;
            
        case StorageTypeApp:
            title = TwinmeLocalizedString(@"application_name", nil);
            break;
            
        case StorageTypeConversation:
            if (self.conversationName) {
                title = _conversationName;
            } else {
                title = TwinmeLocalizedString(@"conversations_view_controller_title", nil);
            }
            break;
            
        default:
            break;
    }
    
    return title;
}

- (nonnull NSString *)getSize {
    
    NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
    byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    return [byteCountFormatter stringFromByteCount:self.size];
}

- (nullable UIColor *)getBackgroundColor {
    
    UIColor *backgroundColor;
    switch (self.storageType) {
        case StorageTypeUsed:
            backgroundColor = [UIColor colorWithRed:0 green:174./255. blue:1.0 alpha:1.0];
            break;
            
        case StorageTypeTotal:
        case StorageTypeFree:
            backgroundColor = [UIColor colorWithRed:222./255 green:232./255. blue:255./255. alpha:1.0];
            break;
            
        case StorageTypeApp:
            backgroundColor = [UIColor colorWithRed:253./255 green:96./255. blue:93./255. alpha:1.0];
            break;
            
        case StorageTypeConversation:
            backgroundColor = Design.WHITE_COLOR;
            break;
            
        default:
            backgroundColor = [UIColor clearColor];
            break;
    }
    
    return backgroundColor;
}

- (nullable UIColor *)getBorderColor {
    
    if (self.storageType == StorageTypeConversation) {
        return [UIColor colorWithRed:151./255. green:151./255. blue:151./255. alpha:1.0];
    }
    return nil;
    
}

@end
