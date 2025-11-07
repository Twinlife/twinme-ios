/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPreviewInfo.h"

//
// Implementation: UIPreviewInfo
//

@implementation UIPreviewInfo

- (BOOL)isMedia {
    
    return self.previewType == PreviewTypeImage || self.previewType == PreviewTypeVideo;
}

@end
