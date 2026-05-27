/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "GifItem.h"

@implementation GifItem

- (instancetype)initWithIdentifier:(NSString *)identifier
                        previewURL:(NSURL *)previewURL
                        contentURL:(NSURL *)contentURL
                         pixelSize:(CGSize)pixelSize
                contentDescription:(NSString *)contentDescription {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _previewURL = [previewURL copy];
        _contentURL = [contentURL copy];
        _pixelSize = pixelSize;
        _contentDescription = [contentDescription copy];
    }
    return self;
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation {
    return @{
        @"id": self.identifier ?: @"",
        @"preview": self.previewURL.absoluteString ?: @"",
        @"content": self.contentURL.absoluteString ?: @"",
        @"w": @(self.pixelSize.width),
        @"h": @(self.pixelSize.height),
        @"desc": self.contentDescription ?: @""
    };
}

+ (GifItem *)gifItemWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *preview = dictionary[@"preview"];
    NSString *content = dictionary[@"content"];
    NSURL *previewURL = preview.length ? [NSURL URLWithString:preview] : nil;
    NSURL *contentURL = content.length ? [NSURL URLWithString:content] : nil;
    if (!previewURL || !contentURL) {
        return nil;
    }
    CGFloat w = [dictionary[@"w"] doubleValue];
    CGFloat h = [dictionary[@"h"] doubleValue];
    return [[GifItem alloc] initWithIdentifier:(dictionary[@"id"] ?: @"")
                                    previewURL:previewURL
                                    contentURL:contentURL
                                     pixelSize:CGSizeMake(w, h)
                            contentDescription:dictionary[@"desc"]];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[GifItem class]]) {
        return NO;
    }
    GifItem *other = (GifItem *)object;
    return [self.identifier isEqualToString:other.identifier] &&
           [self.contentURL isEqual:other.contentURL];
}

- (NSUInteger)hash {
    return self.identifier.hash ^ self.contentURL.hash;
}

@end
