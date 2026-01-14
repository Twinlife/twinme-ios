/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPreviewMedia.h"

//
// Implementation: UIPreviewMedia
//

@implementation UIPreviewMedia

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url path:(nonnull NSString *)path size:(CGSize)size isVideo:(BOOL)isVideo {
    
    self = [super init];
    
    if (self) {
        self.url = url;
        self.path = path;
        self.previewType = isVideo ? PreviewTypeVideo : PreviewTypeImage;
        self.size = size;
        [self getFileSize];
    }
    return self;
}

- (void)getFileSize {
        
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil];
    if (attrs) {
        self.fileSize = [attrs fileSize];
    }
}

@end

