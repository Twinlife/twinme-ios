/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class CallHoldView;

//
// Protocol: CallHoldDelegate
//

@protocol CallHoldDelegate <NSObject>

- (void)onHangupHoldCall:(CallHoldView *)callHoldView;

- (void)onAddHoldCall:(CallHoldView *)callHoldView;

- (void)onSwapHoldCall:(CallHoldView *)callHoldView;

@end

//
// Interface: CallHoldView
//

@interface CallHoldView : UIView

@property (weak, nonatomic) id<CallHoldDelegate> callHoldDelegate;

- (void)setCallInfo:(NSString *)name avatar:(UIImage *)avatar;

@end
