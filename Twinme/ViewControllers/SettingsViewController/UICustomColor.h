/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UICustomColor
//

@interface UICustomColor : NSObject

@property (nonatomic) NSString *color;
@property (nonatomic) BOOL selectedColor;

- (instancetype)initWithColor:(NSString *)color;

- (void)setSelectedColor:(BOOL)selected;

@end
