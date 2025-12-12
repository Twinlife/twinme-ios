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

#define AUDIO_TRACK_LINE_SPACE 8.f
#define AUDIO_TRACK_LINE_WIDTH 4.f

@class AudioTrack;

@protocol AudioTrackViewDelegate;

@interface AudioTrackView : UIView

@property (nonatomic) BOOL isTouch;
@property (nullable, weak, nonatomic) id<AudioTrackViewDelegate> audioTrackViewDelegate;

- (void)drawTrack:(nonnull AudioTrack *)audioTrack lineColor:(nonnull UIColor *)lineColor progressColor:(nonnull UIColor *)progressColor;

- (void)updateProgressView:(float)progress;

@end
