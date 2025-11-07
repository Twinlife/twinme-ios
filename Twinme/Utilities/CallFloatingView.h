/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

typedef enum {
    CallFloatingViewPositionTopLeft,
    CallFloatingViewPositionTopRight,
    CallFloatingViewPositionBottomLeft,
    CallFloatingViewPositionBottomRight
} CallFloatingViewPosition;

//
// Interface: CallFloatingView
//

@class CallParticipant;

@interface CallFloatingView : UIView

- (void)initWithCallParticipant:(nonnull CallParticipant *)participant;

- (void)dispose;

@end
