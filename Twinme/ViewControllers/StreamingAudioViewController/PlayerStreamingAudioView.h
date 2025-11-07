/*
 *  Copyright (c) 2022-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class PlayerStreamingAudioView;

//
// Protocol: PlayerStreamingAudioView
//

@protocol PlayerStreamingAudioViewDelegate <NSObject>

- (void)onStreamingPlayPause:(nonnull PlayerStreamingAudioView *)playerStreamingAudioView;

- (void)onStreamingStop:(nonnull PlayerStreamingAudioView *)playerStreamingAudioView;

@end

@interface PlayerStreamingAudioView : UIView

@property (weak, nonatomic, nullable) id<PlayerStreamingAudioViewDelegate> playerStreamingAudioViewDelegate;

- (void)setSound:(nonnull NSString *)title artwork:(nullable UIImage *)artwork;

- (void)resumeStreaming;

- (void)pauseStreaming;

- (void)stopStreaming;

@end
