/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIAccountMigrationItem.h"

//
// Interface: AccountMigrationViewController ()
//

@interface UIAccountMigrationItem ()

@property (nonatomic) int position;
@property (nonatomic, nullable) NSString *text;

@end

//
// Implementation: UIAccountMigrationItem
//

@implementation UIAccountMigrationItem

- (nonnull instancetype)initWithPosition:(int)position text:(nonnull NSString *)text {
    self = [super init];
    
    if (self) {
        _position = position;
        _text = text;
    }
    
    return self;
}

- (int)getPosition {
    
    return self.position;
}

- (nonnull NSString *)getText {
    
    return self.text;
}


@end
