/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "RecordView.h"

static CGFloat TIME_INTERVAL_TO_CANCEL = 0.5;

@interface RecordView ()

@property(nonatomic) NSDate *touchesBeganDate;

@end

@implementation RecordView

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    self.touchesBeganDate = [NSDate date];
    
    [self.recordViewDelegate recordViewTouchBegan:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    } completion:nil];
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.touchesBeganDate];
    if (timeInterval <= TIME_INTERVAL_TO_CANCEL) {
        [self.recordViewDelegate recordViewTouchCancel:self];
    } else {
        [self.recordViewDelegate recordViewTouchEnd:self];
    }
}

@end
