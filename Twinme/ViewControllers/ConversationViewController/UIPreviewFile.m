/*
 *  Copyright (c) 2025 twinlife SA.
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

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url title:(nonnull NSString *)title extension:(NSString *)extension icon:(UIImage *)icon size:(int64_t)size {
    
    self = [super init];
    
    if (self) {
        self.url = url;
        self.title = title;
        self.extension = extension;
        self.icon = icon;
        self.previewType = PreviewTypeFile;
        [self formatSize:size];
    }
    return self;
}

- (void)formatSize:(int64_t)size {
    
    if (size > 0) {
        NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
        byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
        self.size = [byteCountFormatter stringFromByteCount:size];
    } else {
        self.size = @"";
    }
}

@end
