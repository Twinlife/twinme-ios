/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UICustomTab
//

@interface UICustomTab : NSObject

@property (nonatomic, nonnull) NSString *title;
@property (nonatomic) int tag;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title tag:(int)tag isSelected:(BOOL)isSelected;

@end
