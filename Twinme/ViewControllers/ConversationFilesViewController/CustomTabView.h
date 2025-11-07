/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UICustomTab;

//
// Protocol: CustomTabViewDelegate
//

@protocol CustomTabViewDelegate <NSObject>

- (void)didSelectTab:(nonnull UICustomTab *)uiCustomTab;

@end

//
// Interface: CustomTabView
//

@interface CustomTabView : UIView

- (nonnull instancetype)initWithCustomTab:(nonnull NSArray<UICustomTab *> *)customTabs;

@property (weak, nonatomic, nullable) id<CustomTabViewDelegate> customTabViewDelegate;

- (void)initViews;

- (void)updateColor:(nullable UIColor *)backgroundColor mainColor:(nullable UIColor *)mainColor textSelectedColor:(nullable UIColor *)textSelectedColor borderColor:(nullable UIColor *)borderColor;

@end
