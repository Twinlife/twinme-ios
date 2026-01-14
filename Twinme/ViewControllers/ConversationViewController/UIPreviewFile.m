/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPreviewFile.h"

//
// Implementation: UIPreviewFile
//

@implementation UIPreviewFile

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url title:(nonnull NSString *)title extension:(NSString *)extension icon:(UIImage *)icon fileSize:(long long)fileSize {
    
    self = [super init];
    
    if (self) {
        self.url = url;
        self.title = title;
        self.extension = extension;
        self.icon = icon;
        self.previewType = PreviewTypeFile;
        self.fileSize = fileSize;
        [self formatSize:fileSize];
    }
    return self;
}

- (void)formatSize:(long long)fileSize {
    
    if (fileSize > 0) {
        NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
        byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
        self.size = [byteCountFormatter stringFromByteCount:fileSize];
    } else {
        self.size = @"";
    }
}

@end
