/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "TenorGifProvider.h"
#import "GifItem.h"

static NSString * const kTenorBaseURL = @"https://tenor.googleapis.com/v2";
// "high" filters out adult/violent content; the strictest level Tenor offers.
static NSString * const kTenorContentFilter = @"high";
// Smallest animated preview, plus a medium gif to actually send.
static NSString * const kTenorMediaFilter = @"tinygif,gif,nanogif";

@interface TenorGifProvider ()
@property (nonatomic, copy, nullable) NSString *apiKey;
@property (nonatomic, copy) NSString *clientKey;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation TenorGifProvider

- (instancetype)initWithApiKey:(NSString *)apiKey
                     clientKey:(NSString *)clientKey
                       session:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _apiKey = [apiKey copy];
        _clientKey = [clientKey copy] ?: @"twinme-ios";
        _session = session;
    }
    return self;
}

- (GifProviderKind)kind { return GifProviderKindTenor; }
- (NSString *)displayName { return @"Tenor"; }
- (BOOL)isConfigured { return self.apiKey.length > 0; }

#pragma mark - Requests

- (void)fetchTrendingWithLimit:(NSInteger)limit
                      position:(NSString *)position
                    completion:(GifProviderCompletion)completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:[kTenorBaseURL stringByAppendingString:@"/featured"]];
    components.queryItems = [self commonQueryItemsWithLimit:limit position:position];
    [self runRequestWithComponents:components completion:completion];
}

- (void)searchWithQuery:(NSString *)query
                  limit:(NSInteger)limit
               position:(NSString *)position
             completion:(GifProviderCompletion)completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:[kTenorBaseURL stringByAppendingString:@"/search"]];
    NSMutableArray<NSURLQueryItem *> *items = [[self commonQueryItemsWithLimit:limit position:position] mutableCopy];
    [items addObject:[NSURLQueryItem queryItemWithName:@"q" value:query ?: @""]];
    components.queryItems = items;
    [self runRequestWithComponents:components completion:completion];
}

- (NSArray<NSURLQueryItem *> *)commonQueryItemsWithLimit:(NSInteger)limit position:(NSString *)position {
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
    [items addObject:[NSURLQueryItem queryItemWithName:@"key" value:self.apiKey ?: @""]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"client_key" value:self.clientKey]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"limit" value:[@(limit) stringValue]]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"media_filter" value:kTenorMediaFilter]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"contentfilter" value:kTenorContentFilter]];
    if (position.length) {
        [items addObject:[NSURLQueryItem queryItemWithName:@"pos" value:position]];
    }
    return items;
}

- (void)runRequestWithComponents:(NSURLComponents *)components completion:(GifProviderCompletion)completion {
    if (!self.isConfigured) {
        completion(nil, nil, [self configurationError]);
        return;
    }
    NSURL *url = components.URL;
    if (!url) {
        completion(nil, nil, [self genericErrorWithMessage:@"Invalid Tenor URL"]);
        return;
    }
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data ?: [NSData data] options:0 error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            completion(nil, nil, jsonError ?: [self genericErrorWithMessage:@"Invalid Tenor response"]);
            return;
        }
        NSArray *results = json[@"results"];
        NSMutableArray<GifItem *> *items = [NSMutableArray array];
        if ([results isKindOfClass:[NSArray class]]) {
            for (NSDictionary *result in results) {
                GifItem *item = [self gifItemFromResult:result];
                if (item) {
                    [items addObject:item];
                }
            }
        }
        NSString *next = [json[@"next"] isKindOfClass:[NSString class]] ? json[@"next"] : nil;
        // Tenor returns "0" / "" when there is no further page.
        if (next.length == 0 || [next isEqualToString:@"0"]) {
            next = nil;
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
    NSDictionary *formats = result[@"media_formats"];
    if (![formats isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *preview = formats[@"tinygif"] ?: formats[@"nanogif"] ?: formats[@"gif"];
    NSDictionary *content = formats[@"gif"] ?: formats[@"tinygif"];
    NSString *previewString = [preview isKindOfClass:[NSDictionary class]] ? preview[@"url"] : nil;
    NSString *contentString = [content isKindOfClass:[NSDictionary class]] ? content[@"url"] : nil;
    NSURL *previewURL = previewString.length ? [NSURL URLWithString:previewString] : nil;
    NSURL *contentURL = contentString.length ? [NSURL URLWithString:contentString] : nil;
    if (!previewURL || !contentURL) {
        return nil;
    }
    CGSize size = CGSizeZero;
    NSArray *dims = [preview isKindOfClass:[NSDictionary class]] ? preview[@"dims"] : nil;
    if ([dims isKindOfClass:[NSArray class]] && dims.count == 2) {
        size = CGSizeMake([dims[0] doubleValue], [dims[1] doubleValue]);
    }
    NSString *identifier = [result[@"id"] isKindOfClass:[NSString class]] ? result[@"id"] : contentString;
    NSString *desc = [result[@"content_description"] isKindOfClass:[NSString class]] ? result[@"content_description"] : nil;
    return [[GifItem alloc] initWithIdentifier:identifier
                                    previewURL:previewURL
                                    contentURL:contentURL
                                     pixelSize:size
                            contentDescription:desc];
}

#pragma mark - Errors

- (NSError *)configurationError {
    return [NSError errorWithDomain:@"GifProvider.Tenor" code:401
                           userInfo:@{NSLocalizedDescriptionKey: @"Missing Tenor API key"}];
}

- (NSError *)genericErrorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"GifProvider.Tenor" code:500
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
