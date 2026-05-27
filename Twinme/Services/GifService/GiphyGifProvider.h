/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Giphy GIF provider. Uses the Giphy v1 REST API.
 *  Docs: https://developers.giphy.com/docs/api/endpoint
 */

#import <Foundation/Foundation.h>
#import "GifProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface GiphyGifProvider : NSObject <GifProvider>

- (instancetype)initWithApiKey:(nullable NSString *)apiKey
                       session:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
