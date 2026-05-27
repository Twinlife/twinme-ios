/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  GIF feature contribution.
 *
 *  GifItem: provider-agnostic representation of a single GIF returned by a
 *  GIF provider (Tenor, Giphy, ...). It only keeps what the UI and the send
 *  path need: a small animated preview URL, a full URL to download and send,
 *  and the natural pixel size (used to lay out the waterfall grid).
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface GifItem : NSObject

/// Stable identifier provided by the source (used for de-duplicating recents).
@property (nonatomic, copy, readonly) NSString *identifier;

/// Small, lightweight animated preview shown in the picker grid.
@property (nonatomic, copy, readonly) NSURL *previewURL;

/// Full GIF that is downloaded then sent into the conversation.
@property (nonatomic, copy, readonly) NSURL *contentURL;

/// Natural size of the preview in pixels (width/height ratio drives layout).
@property (nonatomic, readonly) CGSize pixelSize;

/// Optional human description (used for accessibility / alt text).
@property (nonatomic, copy, readonly, nullable) NSString *contentDescription;

- (instancetype)initWithIdentifier:(NSString *)identifier
                        previewURL:(NSURL *)previewURL
                        contentURL:(NSURL *)contentURL
                         pixelSize:(CGSize)pixelSize
                contentDescription:(nullable NSString *)contentDescription NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Serialise to / from a dictionary so recents can be stored in NSUserDefaults.
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;
+ (nullable GifItem *)gifItemWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end

NS_ASSUME_NONNULL_END
