/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "FilePreviewViewController.h"
#import <Twinlife/TLConversationService.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#import "PreviewItem.h"

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: FilePreviewViewController ()
//

@interface FilePreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic) NSURL *copiedFileURL;

@end

//
// Implementation: FilePreviewViewController ()
//

#undef LOG_TAG
#define LOG_TAG @"FilePreviewViewController"

@implementation FilePreviewViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    return self;
}

- (void) viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - UIViewController (Utils)

- (BOOL)hasLandscapeMode {
    DDLogVerbose(@"%@ hasLandscapeMode", LOG_TAG);
    
    return YES;
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    DDLogVerbose(@"%@ numberOfPreviewItemsInPreviewController: %@", LOG_TAG, controller);
    
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    DDLogVerbose(@"%@ previewController: %@ previewItemAtIndex: %ld", LOG_TAG, controller, (long)index);
    
    PreviewItem *previewItem = [[PreviewItem alloc] initPreviewItemWithURL:[self copyFileURL] title:self.namedFileDescriptor.name];
    return previewItem;
}

#pragma mark - QLPreviewControllerDelegate

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    DDLogVerbose(@"%@ previewControllerWillDismiss: %@", LOG_TAG, controller);
    
    [self removeFiles];
    
    UIWindow *currentWindow = [UIViewController currentWindow];
    BOOL isLandscape = NO;
    
    if (currentWindow) {
        isLandscape = UIInterfaceOrientationIsLandscape(currentWindow.windowScene.interfaceOrientation);
    }
    
    if (isLandscape) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

- (NSURL *)copyFileURL {
    DDLogVerbose(@"%@ copyFileURL", LOG_TAG);
    
    NSURL *urlToCopy = [self.namedFileDescriptor getURL];
    if (!urlToCopy || !urlToCopy.isFileURL) {
        return urlToCopy;
    }
    
    NSString *fileName = self.namedFileDescriptor.name;
    fileName = [NSString copyFileName:fileName fileExtension:self.namedFileDescriptor.extension urlToCopy:urlToCopy];
    
    NSURL *exportDirectoryURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString] isDirectory:YES];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:exportDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
        return urlToCopy;
    }
    
    NSURL *copyURL = [exportDirectoryURL URLByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] copyItemAtURL:urlToCopy toURL:copyURL error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:exportDirectoryURL error:nil];
        return urlToCopy;
    }
    
    self.copiedFileURL = copyURL;

    return copyURL;
}

- (void)removeFiles {
    DDLogVerbose(@"%@ removeFiles", LOG_TAG);
    
    if (!self.copiedFileURL) {
        return;
    }
        
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.copiedFileURL.path]) {
        [fileManager removeItemAtURL:self.copiedFileURL error:nil];
    }
    
    self.copiedFileURL = nil;
}

@end
