/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "GifService.h"
#import "GifItem.h"
#import "TenorGifProvider.h"
#import "GiphyGifProvider.h"

static NSString * const kTenorInfoPlistKey = @"TenorAPIKey";
static NSString * const kGiphyInfoPlistKey = @"GiphyAPIKey";
static NSString * const kActiveProviderDefaultsKey = @"GifService.activeProviderKind";
static NSString * const kRecentGifsDefaultsKey = @"GifService.recentGifs";
static NSUInteger const kMaxRecentGifs = 24;

@interface GifService ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSArray<id<GifProvider>> *availableProviders;
@property (nonatomic, strong, nullable) id<GifProvider> activeProvider;
@property (nonatomic, strong) NSMutableArray<GifItem *> *mutableRecentGifs;
@end

@implementation GifService

+ (GifService *)sharedService {
    static GifService *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GifService alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 20.0;
        configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        _session = [NSURLSession sessionWithConfiguration:configuration];

        [self buildProviders];
        [self loadRecentGifs];
        [self restoreActiveProvider];
    }
    return self;
}

#pragma mark - Providers

- (void)buildProviders {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *tenorKey = [self trimmedString:[bundle objectForInfoDictionaryKey:kTenorInfoPlistKey]];
    NSString *giphyKey = [self trimmedString:[bundle objectForInfoDictionaryKey:kGiphyInfoPlistKey]];

    NSMutableArray<id<GifProvider>> *providers = [NSMutableArray array];
    // Tenor is listed first so it is the default when both keys are present.
    if (tenorKey.length) {
        [providers addObject:[[TenorGifProvider alloc] initWithApiKey:tenorKey
                                                            clientKey:@"twinme-ios"
                                                              session:self.session]];
    }
    if (giphyKey.length) {
        [providers addObject:[[GiphyGifProvider alloc] initWithApiKey:giphyKey session:self.session]];
    }
    self.availableProviders = [providers copy];
}

- (NSString *)trimmedString:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    return [(NSString *)value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)restoreActiveProvider {
    NSNumber *stored = [[NSUserDefaults standardUserDefaults] objectForKey:kActiveProviderDefaultsKey];
    if (stored != nil) {
        for (id<GifProvider> provider in self.availableProviders) {
            if (provider.kind == stored.integerValue) {
                _activeProvider = provider;
                break;
            }
        }
    }
    if (!_activeProvider) {
        _activeProvider = self.availableProviders.firstObject;
    }
}

- (void)setActiveProvider:(id<GifProvider>)activeProvider {
    _activeProvider = activeProvider;
    if (activeProvider) {
        [[NSUserDefaults standardUserDefaults] setObject:@(activeProvider.kind) forKey:kActiveProviderDefaultsKey];
    }
}

- (BOOL)isConfigured {
    return self.availableProviders.count > 0;
}

#pragma mark - Download

- (void)downloadGif:(GifItem *)item completion:(GifDownloadCompletion)completion {
    if (!item.contentURL) {
        [self callDownloadCompletion:completion path:nil error:[self errorWithMessage:@"Missing GIF URL"]];
        return;
    }
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:item.contentURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error || !location) {
            [self callDownloadCompletion:completion path:nil error:error ?: [self errorWithMessage:@"GIF download failed"]];
            return;
        }
        NSString *fileName = [NSString stringWithFormat:@"gif_%@.gif", [[NSUUID UUID] UUIDString]];
        NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:destinationURL error:nil];
        NSError *moveError = nil;
        if (![fileManager moveItemAtURL:location toURL:destinationURL error:&moveError]) {
            [self callDownloadCompletion:completion path:nil error:moveError ?: [self errorWithMessage:@"Could not store GIF"]];
            return;
        }
        [self callDownloadCompletion:completion path:destinationPath error:nil];
    }];
    [task resume];
}

- (void)callDownloadCompletion:(GifDownloadCompletion)completion path:(NSString *)path error:(NSError *)error {
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(path, error);
    });
}

#pragma mark - Recents

- (void)loadRecentGifs {
    self.mutableRecentGifs = [NSMutableArray array];
    NSArray *stored = [[NSUserDefaults standardUserDefaults] arrayForKey:kRecentGifsDefaultsKey];
    if ([stored isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dictionary in stored) {
            GifItem *item = [GifItem gifItemWithDictionary:dictionary];
            if (item) {
                [self.mutableRecentGifs addObject:item];
            }
        }
    }
}

- (NSArray<GifItem *> *)recentGifs {
    return [self.mutableRecentGifs copy];
}

- (void)addRecentGif:(GifItem *)item {
    if (!item) {
        return;
    }
    NSMutableArray<GifItem *> *recents = self.mutableRecentGifs;
    [recents removeObject:item]; // de-duplicate (GifItem implements isEqual:)
    [recents insertObject:item atIndex:0];
    while (recents.count > kMaxRecentGifs) {
        [recents removeLastObject];
    }
    NSMutableArray<NSDictionary *> *serialised = [NSMutableArray array];
    for (GifItem *recent in recents) {
        [serialised addObject:[recent dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serialised forKey:kRecentGifsDefaultsKey];
}

#pragma mark - Helpers

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"GifService" code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"GIF error"}];
}

@end
