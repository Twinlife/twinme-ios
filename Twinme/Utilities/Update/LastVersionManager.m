/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import "LastVersionManager.h"

#import "LastVersion.h"

#define URL_LAST_VERSION @"https://skred.mobi/download/skred-ios.json"
#define VERSION_KEY @"version"
#define MINIMUM_OS_KEY @"iOS"
#define IMAGES_KEY @"images"
#define IMAGES_DARK_KEY @"images_dark"
#define CHANGES_KEY @"changes"
#define MAJOR_KEY @"major"
#define MINOR_KEY @"minor"

#define LAST_UPDATED_VERSION @"LastUpdatedVersion"

@interface LastVersionManager ()

@property NSOperatingSystemVersion currentVersion;
@property NSOperatingSystemVersion lastInformedVersion;

/// Split the version string into a struct with 3 integers for the version comparison.
+ (NSOperatingSystemVersion)toVersion:(nonnull NSString *)version;

@end

//
// Installed   Informed   Available   Type          Message
// 3.2         null       3.2         What's new    Major      Transition internal test
// 3.2         null       3.3         Upgrade       Minor
// 3.3         null       3.2         <empty>
// 3.3         null       3.3         What's new    Major
// 3.3         XXX        4.1         Upgrade       Major
// 4.1         3.3        3.3         <empty>                  New information not available yet
// 4.1         3.3        4.1         What's new    Major      Informed < Installed == Available (Major upgrade)
// 4.2         3.3        4.2         What's new    Major      Informed < Installed == Available (Major upgrade)
// 4.2         4.1        4.2         What's new    Minor      Informed < Installed == Available (Minor upgrade)
//
@implementation LastVersionManager

+ (NSOperatingSystemVersion)toVersion:(nonnull NSString *)version {

    int majorVersion = INT_MAX;
    int minorVersion = 0;
    int patchVersion = 0;

    NSArray<NSString *> *items = [version componentsSeparatedByString:@"."];
    if (items.count >= 1) {
        majorVersion = [items[0] intValue];

        if (items.count >= 2) {
            minorVersion = [items[1] intValue];
            if (items.count >= 3) {
                patchVersion = [items[2] intValue];
            }
        }
    }

    return (NSOperatingSystemVersion){.majorVersion = majorVersion, .minorVersion = minorVersion, .patchVersion = patchVersion};
}

- (void)getLastVersion {
    
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_UPDATED_VERSION];
    if (object) {
        self.lastInformedVersion = [LastVersionManager toVersion:(NSString *)object];
    } else {
        self.lastInformedVersion = (NSOperatingSystemVersion){.majorVersion = 0, .minorVersion = 0, .patchVersion = 0};
    }

    NSURL *url = [NSURL URLWithString:URL_LAST_VERSION];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    urlSessionConfiguration.requestCachePolicy = NSURLRequestReloadRevalidatingCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *urlSessionDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            @try {
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (jsonDictionary) {
                    [self parseJSON:jsonDictionary];
                }
            } @catch (NSException *eException) {
                // protect and ignore the exception in case something weird happens.
            }
        }
    }];
    [urlSessionDataTask resume];
    
    self.currentVersion = [LastVersionManager toVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
}

- (BOOL)isVersionUpdated {
    
    if (!self.lastVersion) {
        return NO;
    }
    
    if (self.lastVersion.version.majorVersion != self.currentVersion.majorVersion || self.lastVersion.version.minorVersion != self.currentVersion.minorVersion || self.lastVersion.version.patchVersion != self.currentVersion.patchVersion) {
        return NO;
    }
    
    // Last informed version is different.
    return self.lastInformedVersion.majorVersion != self.currentVersion.majorVersion || self.lastInformedVersion.minorVersion != self.currentVersion.minorVersion;
}

- (BOOL)isNewVersionAvailable {
    
    if (!self.lastVersion) {
        return NO;
    }
    
    if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:self.lastVersion.minOsVersion]) {
        return NO;
    }
    
    // Current version can be 12.6.0 but JSON can report a 12.5.3 because it is not updated yet.
    // We have to compare each number separately because a 12.10.1 is newer than a 12.5.3.
    if (self.currentVersion.majorVersion < self.lastVersion.version.majorVersion) {
        return YES;
    } else if (self.currentVersion.majorVersion > self.lastVersion.version.majorVersion) {
        return NO;
    }

    if (self.currentVersion.minorVersion < self.lastVersion.version.minorVersion) {
        return YES;
    } else if (self.currentVersion.minorVersion > self.lastVersion.version.minorVersion) {
        return NO;
    }

    return self.currentVersion.patchVersion < self.lastVersion.version.patchVersion ? YES : NO;
}

- (BOOL)isCurrentVersion {
    
    if (!self.lastVersion) {
        return NO;
    }
    
    return self.lastVersion.version.majorVersion == self.currentVersion.majorVersion && self.lastVersion.version.minorVersion == self.currentVersion.minorVersion && self.lastVersion.version.patchVersion == self.currentVersion.patchVersion;
}

- (BOOL)isMajorVersionWithUpdate:(BOOL)update {
 
    if (!self.lastVersion) {
        return NO;
    }

    // Inform changes made since the last updated version we have recorded.
    NSOperatingSystemVersion version;
    if (!update) {
        version = self.lastInformedVersion;

        NSString *lastVersion = self.lastVersion.versionNumber;

        // Save the new last updated version.
        [[NSUserDefaults standardUserDefaults] setValue:lastVersion forKey:LAST_UPDATED_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.lastInformedVersion = self.lastVersion.version;

    } else {
        version = self.currentVersion;
    }

    // A 13.0.0 and a 12.6.0 are considered a major version compared to a 12.5.3.
    if (version.majorVersion < self.lastVersion.version.majorVersion) {
        return YES;
    } else if (version.majorVersion > self.lastVersion.version.majorVersion) {
        return NO;
    }

    if (version.minorVersion < self.lastVersion.version.minorVersion) {
        return YES;
    } else if (version.minorVersion > self.lastVersion.version.minorVersion) {
        return NO;
    }

    // Both majorVersion and minorVersion are equal: this is a minor version update.
    return NO;
}

- (void)parseJSON:(NSDictionary *)jsonDictionary {
    
    self.lastVersion = [[LastVersion alloc]init];
    self.lastVersion.minOsVersion = (NSOperatingSystemVersion){.majorVersion = INT_MAX, .minorVersion = 0, .patchVersion = 0};

    if ([jsonDictionary objectForKey:VERSION_KEY] && [[jsonDictionary objectForKey:VERSION_KEY] isKindOfClass:[NSString class]]) {
        self.lastVersion.versionNumber = [jsonDictionary objectForKey:VERSION_KEY];
        self.lastVersion.version = [LastVersionManager toVersion:self.lastVersion.versionNumber];
    }
    
    if ([jsonDictionary objectForKey:MINIMUM_OS_KEY] && [[jsonDictionary objectForKey:MINIMUM_OS_KEY] isKindOfClass:[NSString class]]) {
        NSString *minSDKSupported = [jsonDictionary objectForKey:MINIMUM_OS_KEY];
        self.lastVersion.minOsVersion = [LastVersionManager toVersion:minSDKSupported];
    }
    
    if ([jsonDictionary objectForKey:IMAGES_KEY] && [[jsonDictionary objectForKey:IMAGES_KEY] isKindOfClass:[NSArray class]]) {
        NSArray *arrayImages = [jsonDictionary objectForKey:IMAGES_KEY];
        self.lastVersion.updateImages = [[NSMutableArray alloc]init];
        for (id image in arrayImages) {
            if ([image isKindOfClass:[NSString class]]) {
                [self.lastVersion.updateImages addObject:image];
            }
        }
    }
    
    if ([jsonDictionary objectForKey:IMAGES_DARK_KEY] && [[jsonDictionary objectForKey:IMAGES_DARK_KEY] isKindOfClass:[NSArray class]]) {
        NSArray *arrayImages = [jsonDictionary objectForKey:IMAGES_DARK_KEY];
        self.lastVersion.updateImagesDark = [[NSMutableArray alloc]init];
        for (id image in arrayImages) {
            if ([image isKindOfClass:[NSString class]]) {
                [self.lastVersion.updateImagesDark addObject:image];
            }
        }
    }
    
    if ([jsonDictionary objectForKey:CHANGES_KEY] && [[jsonDictionary objectForKey:CHANGES_KEY] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = [jsonDictionary objectForKey:CHANGES_KEY];
        
        if ([dictionary objectForKey:MAJOR_KEY] && [[dictionary objectForKey:MAJOR_KEY] isKindOfClass:[NSArray class]]) {
            NSArray *arrayMajors = [dictionary objectForKey:MAJOR_KEY];
            self.lastVersion.majorChanges = [[NSMutableArray alloc]init];
            for (id major in arrayMajors) {
                if ([major isKindOfClass:[NSString class]]) {
                    [self.lastVersion.majorChanges addObject:major];
                }
            }
        }
        
        if ([dictionary objectForKey:MINOR_KEY] && [[dictionary objectForKey:MINOR_KEY] isKindOfClass:[NSArray class]]) {
            NSArray *arrayMinors = [dictionary objectForKey:MINOR_KEY];
            self.lastVersion.minorChanges = [[NSMutableArray alloc]init];
            for (id minor in arrayMinors) {
                if ([minor isKindOfClass:[NSString class]]) {
                    [self.lastVersion.minorChanges addObject:minor];
                }
            }
        }
    }
    
    if (self.lastInformedVersion.majorVersion == 0 && self.lastVersion) {
        self.lastInformedVersion = self.currentVersion;
        [[NSUserDefaults standardUserDefaults] setValue:self.lastVersion.versionNumber forKey:LAST_UPDATED_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
