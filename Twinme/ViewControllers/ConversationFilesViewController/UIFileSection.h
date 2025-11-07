/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIFileSection
//

@class Item;

@interface UIFileSection : NSObject

@property (nonatomic, nonnull) NSString *period;

- (nonnull instancetype)initWithPeriod:(nonnull NSString *)period;

- (nonnull NSString *)getTitle;

- (NSUInteger)count;

- (nonnull NSMutableArray *)getItems;

- (void)addItem:(nonnull Item *)item;

@end
