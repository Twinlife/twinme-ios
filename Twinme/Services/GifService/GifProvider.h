/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  GifProvider: abstraction over a remote GIF catalog (Tenor, Giphy, ...).
 *  Each provider knows how to fetch trending GIFs and to search by keyword,
 *  and maps the remote JSON onto the provider-agnostic GifItem model.
 *
 *  Pagination is opaque: callers pass back the `nextPosition` they received to
 *  load the following page (Tenor uses a cursor string, Giphy an offset; both
 *  are hidden behind an NSString here).
 */

#import <Foundation/Foundation.h>

@class GifItem;

NS_ASSUME_NONNULL_BEGIN

/// Attribution / branding shown in the picker, as required by the providers' ToS.
typedef NS_ENUM(NSInteger, GifProviderKind) {
    GifProviderKindTenor = 0,
    GifProviderKindGiphy = 1
};

/// items: the page of results. nextPosition: opaque cursor for the next page
/// (nil when there are no more results). error: non-nil on failure.
typedef void (^GifProviderCompletion)(NSArray<GifItem *> * _Nullable items,
                                      NSString * _Nullable nextPosition,
                                      NSError * _Nullable error);

@protocol GifProvider <NSObject>

@property (nonatomic, readonly) GifProviderKind kind;

/// Display name used for the attribution label ("Tenor", "GIPHY").
@property (nonatomic, readonly) NSString *displayName;

/// YES when an API key is available and the provider can be queried.
@property (nonatomic, readonly) BOOL isConfigured;

/// Featured / trending GIFs.
- (void)fetchTrendingWithLimit:(NSInteger)limit
                      position:(nullable NSString *)position
                    completion:(GifProviderCompletion)completion;

/// Keyword search.
- (void)searchWithQuery:(NSString *)query
                  limit:(NSInteger)limit
               position:(nullable NSString *)position
             completion:(GifProviderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
