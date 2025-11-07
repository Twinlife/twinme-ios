/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: FullScreenVideoCell
//

@class Item;
@class UIPreviewMedia;
@class AudioSessionManager;

@protocol FullScreenMediaDelegate;

@interface FullScreenVideoCell : UICollectionViewCell

@property (weak, nullable, nonatomic) id<FullScreenMediaDelegate> fullScreenMediaDelegate;

- (void)bindWithItem:(nonnull Item *)item;

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia;

- (void)playVideoWithAudioSession:(nonnull AudioSessionManager *)audioSession;

- (void)stopVideo;

- (BOOL)isVideoFormatSupported;

@end
