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

#import "PreviewItem.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: FilePreviewViewController ()
//

@interface FilePreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

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
    
    PreviewItem *previewItem = [[PreviewItem alloc] initPreviewItemWithURL:[self.namedFileDescriptor getURL] title:self.namedFileDescriptor.name];
    return previewItem;
}

#pragma mark - QLPreviewControllerDelegate

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    DDLogVerbose(@"%@ previewControllerWillDismiss: %@", LOG_TAG, controller);
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

@end
