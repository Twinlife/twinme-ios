/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "GiphyGifProvider.h"
#import "GifItem.h"

static NSString * const kGiphyBaseURL = @"https://api.giphy.com/v1/gifs";
// "g" = the safest content rating offered by Giphy.
static NSString * const kGiphyRating = @"g";
static NSInteger const kGiphyDefaultLimit = 25;

@interface GiphyGifProvider ()
@property (nonatomic, copy, nullable) NSString *apiKey;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation GiphyGifProvider

- (instancetype)initWithApiKey:(NSString *)apiKey session:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _apiKey = [apiKey copy];
        _session = session;
    }
    return self;
}

- (GifProviderKind)kind { return GifProviderKindGiphy; }
- (NSString *)displayName { return @"GIPHY"; }
- (BOOL)isConfigured { return self.apiKey.length > 0; }

#pragma mark - Requests

- (void)fetchTrendingWithLimit:(NSInteger)limit
                      position:(NSString *)position
                    completion:(GifProviderCompletion)completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:[kGiphyBaseURL stringByAppendingString:@"/trending"]];
    components.queryItems = [self commonQueryItemsWithLimit:limit position:position extra:nil];
    [self runRequestWithComponents:components limit:limit position:position completion:completion];
}

- (void)searchWithQuery:(NSString *)query
                  limit:(NSInteger)limit
               position:(NSString *)position
             completion:(GifProviderCompletion)completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:[kGiphyBaseURL stringByAppendingString:@"/search"]];
    NSURLQueryItem *q = [NSURLQueryItem queryItemWithName:@"q" value:query ?: @""];
    components.queryItems = [self commonQueryItemsWithLimit:limit position:position extra:@[q]];
    [self runRequestWithComponents:components limit:limit position:position completion:completion];
}

- (NSArray<NSURLQueryItem *> *)commonQueryItemsWithLimit:(NSInteger)limit
                                               position:(NSString *)position
                                                  extra:(NSArray<NSURLQueryItem *> *)extra {
    NSInteger offset = position.integerValue; // nil/"" -> 0
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
    [items addObject:[NSURLQueryItem queryItemWithName:@"api_key" value:self.apiKey ?: @""]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"limit" value:[@(limit > 0 ? limit : kGiphyDefaultLimit) stringValue]]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"offset" value:[@(offset) stringValue]]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"rating" value:kGiphyRating]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"bundle" value:@"messaging_non_clips"]];
    if (extra) {
        [items addObjectsFromArray:extra];
    }
    return items;
}

- (void)runRequestWithComponents:(NSURLComponents *)components
                          limit:(NSInteger)limit
                       position:(NSString *)position
                     completion:(GifProviderCompletion)completion {
    if (!self.isConfigured) {
        completion(nil, nil, [self configurationError]);
        return;
    }
    NSURL *url = components.URL;
    if (!url) {
        completion(nil, nil, [self genericErrorWithMessage:@"Invalid Giphy URL"]);
        return;
    }
    NSInteger requestOffset = position.integerValue;
    NSInteger requestLimit = limit > 0 ? limit : kGiphyDefaultLimit;
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data ?: [NSData data] options:0 error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            completion(nil, nil, jsonError ?: [self genericErrorWithMessage:@"Invalid Giphy response"]);
            return;
        }
        NSArray *results = json[@"data"];
        NSMutableArray<GifItem *> *items = [NSMutableArray array];
        if ([results isKindOfClass:[NSArray class]]) {
            for (NSDictionary *result in results) {
                GifItem *item = [self gifItemFromResult:result];
                if (item) {
                    [items addObject:item];
                }
            }
        }
        // Compute the next offset; nil when the page came back short (end reached).
        NSString *next = nil;
        if (items.count >= (NSUInteger)requestLimit) {
            next = [@(requestOffset + requestLimit) stringValue];
        }
        completion(items, next, nil);
    }];
    [task resume];
}

#pragma mark - Mapping

- (GifItem *)gifItemFromResult:(NSDictionary *)result {
    if (![result isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *images = result[@"images"];
    if (![images isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *preview = images[@"fixed_width"] ?: images[@"preview_gif"] ?: images[@"downsized"];
    NSDictionary *content = images[@"downsized_medium"] ?: images[@"downsized"] ?: images[@"original"];
    NSString *previewString = [preview isKindOfClass:[NSDictionary class]] ? preview[@"url"] : nil;
    NSString *contentString = [content isKindOfClass:[NSDictionary class]] ? content[@"url"] : nil;
    NSURL *previewURL = previewString.length ? [NSURL URLWithString:previewString] : nil;
    NSURL *contentURL = contentString.length ? [NSURL URLWithString:contentString] : nil;
    if (!previewURL || !contentURL) {
        return nil;
    }
    CGSize size = CGSizeZero;
    if ([preview isKindOfClass:[NSDictionary class]]) {
        size = CGSizeMake([preview[@"width"] doubleValue], [preview[@"height"] doubleValue]);
    }
    NSString *identifier = [result[@"id"] isKindOfClass:[NSString class]] ? result[@"id"] : contentString;
    NSString *desc = [result[@"title"] isKindOfClass:[NSString class]] ? result[@"title"] : nil;
    return [[GifItem alloc] initWithIdentifier:identifier
                                    previewURL:previewURL
                                    contentURL:contentURL
                                     pixelSize:size
                            contentDescription:desc];
}

#pragma mark - Errors

- (NSError *)configurationError {
    return [NSError errorWithDomain:@"GifProvider.Giphy" code:401
                           userInfo:@{NSLocalizedDescriptionKey: @"Missing Giphy API key"}];
}

- (NSError *)genericErrorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"GifProvider.Giphy" code:500
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
