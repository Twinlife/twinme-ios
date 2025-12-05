/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

@protocol CallQualityViewDelegate <NSObject>

- (void)didSendCallQuality:(nonnull AbstractConfirmView *)abstractConfirmView quality:(int)quality;

@end

//
// Interface: CallQualityView
//

@interface CallQualityView : AbstractConfirmView

@property (weak, nonatomic) id<CallQualityViewDelegate> callQualityViewDelegate;

@end
