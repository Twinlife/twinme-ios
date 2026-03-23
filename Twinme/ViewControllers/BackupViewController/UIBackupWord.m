/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIBackupWord.h"

//
// Interface: UIBackupWord ()
//

@interface UIBackupWord ()

@property (nonatomic) NSString *word;
@property (nonatomic) int position;

@end

//
// Implementation: UIBackupWord
//

@implementation UIBackupWord

- (nonnull instancetype)initWithWord:(nullable NSString *)word position:(int)position {
    
    self = [super init];
    
    if (self) {
        _word = word;
        _position = position;
    }
    return self;
}

- (nullable NSString *)getWord {
    
    if (!self.word) {
        return nil;
    }
    return [self.word uppercaseString];
}

- (void)updateWord:(nullable NSString *)word {
    
    self.word = word;
}

- (int)getPosition {
    
    return self.position;
}

@end
