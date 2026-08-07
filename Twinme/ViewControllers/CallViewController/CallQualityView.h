/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractBottomSheetView.h>

@protocol CallQualityViewDelegate <NSObject>

- (void)didSendCallQuality:(nonnull AbstractBottomSheetView *)abstractBottomSheetView quality:(int)quality;

@end

//
// Interface: CallQualityView
//

@interface CallQualityView : AbstractBottomSheetView

@property (weak, nonatomic) id<CallQualityViewDelegate> callQualityViewDelegate;

@end
