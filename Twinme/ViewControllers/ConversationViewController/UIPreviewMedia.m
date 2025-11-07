/*
 *  Copyright (c) 2025 twinlife SA.
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
        self.size = size;
        self.previewType = isVideo ? PreviewTypeVideo : PreviewTypeImage;
    }
    return self;
}

@end

