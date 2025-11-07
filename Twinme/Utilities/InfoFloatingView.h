/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    InfoFloatingViewStateDefault,
    InfoFloatingViewStateExtend
} InfoFloatingViewState;

@class connectionStatus;

//
// Interface: InfoFloatingView
//

@interface InfoFloatingView : UIView

- (void)setConnectionStatus:(TLConnectionStatus)connectionStatus;

- (void)tapAction;

@end
