/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIPollChoice
//

@interface UIPollChoice : NSObject

@property (nonatomic) int position;
@property (nonatomic, nonnull) NSString *choice;
@property (nonatomic) int count;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, nullable) NSMutableArray *avatars;

- (nonnull instancetype)initWithPosition:(int)position choice:(nonnull NSString *)choice;

- (nonnull NSString *)getChoicePosition;

@end
