/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PreviewItem.h"

//
// Implementation: PreviewItem
//

@implementation PreviewItem

- (instancetype)initPreviewItemWithURL:(NSURL *)url title:(NSString *)title {
    
    self = [super init];
    
    if (self) {
        _previewItemURL = url;
        _previewItemTitle = title;
    }
    
    return self;
}

@end
