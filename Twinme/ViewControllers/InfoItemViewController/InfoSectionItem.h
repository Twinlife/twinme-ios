/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: InfoSectionItem
//

@interface InfoSectionItem : Item

@property (nonatomic, nonnull) NSString *title;

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title;
    
@end
