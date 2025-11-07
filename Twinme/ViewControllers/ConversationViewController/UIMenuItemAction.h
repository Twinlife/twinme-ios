/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIMenuItem
//

#import "MenuItemView.h"

@interface UIMenuItemAction : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *image;
@property (nonatomic) ActionType actionType;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image actionType:(ActionType)actionType;

@end
