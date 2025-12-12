/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "FullScreenMediaCollectionView.h"

#import <TwinmeCommon/Design.h>

#define DESIGN_VIDEO_CONTROL_HEIGHT 240

static CGFloat VIDEO_CONTROL_HEIGHT = 0;

//
// Interface: FullScreenMediaCollectionView
//

@interface FullScreenMediaCollectionView ()

@end

//
// Implementation: FullScreenMediaCollectionView
//

@implementation FullScreenMediaCollectionView

+ (void)initialize {
    
    VIDEO_CONTROL_HEIGHT = DESIGN_VIDEO_CONTROL_HEIGHT * Design.HEIGHT_RATIO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
        
    if (self.isCurrentItemVideo && self.isVideoControlVisible) {
        CGPoint point = [gestureRecognizer locationInView:self];
        if (point.y >= self.bounds.size.height - VIDEO_CONTROL_HEIGHT) {
            return NO;
        }
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
