/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AudioTrackView
//

@class AudioTrack;

@protocol AudioTrackViewDelegate;

@interface AudioTrackView : UIView

@property (nonatomic) BOOL isTouch;
@property (nullable, weak, nonatomic) id<AudioTrackViewDelegate> audioTrackViewDelegate;

- (void)drawTrack:(nonnull AudioTrack *)audioTrack lineColor:(nonnull UIColor *)lineColor progressColor:(nonnull UIColor *)progressColor;

- (void)updateProgressView:(float)progress;

@end
