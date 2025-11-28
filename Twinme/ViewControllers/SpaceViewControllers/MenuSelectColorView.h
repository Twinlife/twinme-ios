/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Interface: MenuSelectColorView
//

@class MenuSelectColorView;

@protocol MenuSelectColorDelegate <NSObject>

- (void)cancelMenuSelectColor:(MenuSelectColorView *)menuSelectColorView;

- (void)selectColor:(MenuSelectColorView *)menuSelectColorView color:(NSString *)color;

- (void)resetColor:(MenuSelectColorView *)menuSelectColorView;

@end

//
// Interface: MenuSelectColorView
//

@class TLSpaceSettings;

@interface MenuSelectColorView : AbstractMenuView

@property (weak, nonatomic) id<MenuSelectColorDelegate> menuSelectColorDelegate;
@property (nonatomic) NSMutableArray *colors;

- (void)initViews;

- (void)openMenu:(UIColor *)color title:(NSString *)title defaultColor:(NSString *)defaultColor spaceSettings:(TLSpaceSettings *)spaceSettings;

- (void)updateKeyboard:(CGFloat)sizeKeyboard;

@end
