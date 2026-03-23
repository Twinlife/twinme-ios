/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIRestoreItem.h"

//
// Interface: UIRestoreItem ()
//

@interface UIRestoreItem ()

@property (nonatomic) UIRestoreItemType restoreItemType;
@property (nonatomic, nullable) NSString *text;
@property (nonatomic, nullable) UIImage *icon;
@property (nonatomic) int value;
@property (nonatomic, nullable) UIColor *color;

@end

//
// Implementation: UIBackupInfo
//

@implementation UIRestoreItem

- (instancetype)initWithType:(UIRestoreItemType)type text:(nullable NSString *)text icon:(nullable UIImage *)icon value:(int)value color:(nullable UIColor *)color {
    
    self = [super init];
    
    if (self) {
        _restoreItemType = type;
        _text  = text;
        _icon = icon;
        _value = value;
        _color = color;
    }
    return self;
}

- (UIRestoreItemType)getRestoreItemType {
    
    return self.restoreItemType;
}

- (nullable NSString *)getText {
    
    return self.text;
}
    
- (nullable UIImage *)getIcon {
 
    return self.icon;
}

- (int)getValue {
 
    return self.value;
}

- (nullable UIColor *)getColor {
 
    return self.color;
}

@end
