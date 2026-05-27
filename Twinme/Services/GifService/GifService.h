/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  GifService: single entry point for the GIF feature.
 *
 *  - Reads the Tenor / Giphy API keys from the app Info.plist
 *    (keys: "TenorAPIKey" and "GiphyAPIKey"). Either or both may be set;
 *    the picker simply uses whichever providers are configured.
 *  - Exposes the configured providers and the currently active one.
 *  - Downloads a chosen GIF to a temporary .gif file ready to be sent.
 *  - Stores a small list of recently sent GIFs (in NSUserDefaults).
 */

#import <Foundation/Foundation.h>
#import "GifProvider.h"

@class GifItem;

NS_ASSUME_NONNULL_BEGIN

typedef void (^GifDownloadCompletion)(NSString * _Nullable localPath, NSError * _Nullable error);

@interface GifService : NSObject

@property (class, nonatomic, readonly) GifService *sharedService;

/// Every provider that has an API key configured (may be empty).
@property (nonatomic, readonly) NSArray<id<GifProvider>> *availableProviders;

/// The provider currently used by the picker. Defaults to the first available
/// (Tenor preferred). Setting it persists the choice across launches.
@property (nonatomic, strong, nullable) id<GifProvider> activeProvider;

/// YES when at least one provider is configured.
@property (nonatomic, readonly) BOOL isConfigured;

/// Recently sent GIFs, newest first.
@property (nonatomic, readonly) NSArray<GifItem *> *recentGifs;

/// Download the full GIF of `item` to NSTemporaryDirectory and call back on the
/// main queue with the local file path (or an error).
- (void)downloadGif:(GifItem *)item completion:(GifDownloadCompletion)completion;

/// Record a GIF as recently sent (called by the conversation once sent).
- (void)addRecentGif:(GifItem *)item;

@end

NS_ASSUME_NONNULL_END
