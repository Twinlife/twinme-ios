/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@protocol CallQualityViewDelegate <NSObject>

- (void)closeCallQuality;

- (void)sendCallQuality:(int)quality;

@end

//
// Interface: CallQualityView
//

@interface CallQualityView : UIViewController

- (instancetype)initWithDelegate:(id<CallQualityViewDelegate>)callQualityViewDelegate;

- (void)showInView:(UIViewController *)view;

@end
