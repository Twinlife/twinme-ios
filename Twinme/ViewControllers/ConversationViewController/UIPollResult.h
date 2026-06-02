/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIPollResult
//

@class TLChoice;

@interface UIPollResult : NSObject

@property (nonatomic, nonnull) TLChoice *choice;
@property (nonatomic) int count;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, nullable) NSMutableArray *voters;

- (nonnull instancetype)initWithChoice:(nonnull TLChoice *)choice;

- (nonnull NSString *)getChoiceLabel;

@end
