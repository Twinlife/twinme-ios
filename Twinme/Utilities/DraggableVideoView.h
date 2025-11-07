/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "RoundRectProgressView.h"

//
// Interface: DraggableVideoView
//

@interface DraggableVideoView : RoundRectProgressView

- (void)moveToClosestCornerAnimated:(BOOL)animated;

- (void)hideMicroMute:(BOOL)hidden;

@end
