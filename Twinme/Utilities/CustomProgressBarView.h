/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class CustomProgressBarView;

@protocol CustomProgressBarDelegate <NSObject>

@optional - (void)customProgressBarEndAnimation:(CustomProgressBarView *)customProgressBarView;

@end

//
// Interface: CustomProgressBarView
//

@interface CustomProgressBarView : UIView

@property(nonatomic, weak) id<CustomProgressBarDelegate> customProgressBarDelegate;
@property(nonatomic) BOOL isDarkMode;

- (void)startAnimation;

- (void)stopAnimation;

- (void)resetAnimation;

@end
