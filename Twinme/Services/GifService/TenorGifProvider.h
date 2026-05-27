/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Tenor (Google) GIF provider. Uses the Tenor v2 REST API.
 *  Docs: https://developers.google.com/tenor/guides/quickstart
 */

#import <Foundation/Foundation.h>
#import "GifProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TenorGifProvider : NSObject <GifProvider>

/// apiKey: a Tenor (Google Cloud) API key. clientKey: a short app identifier
/// used by Tenor for per-app analytics (any stable string, e.g. "twinme-ios").
- (instancetype)initWithApiKey:(nullable NSString *)apiKey
                     clientKey:(NSString *)clientKey
                       session:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
