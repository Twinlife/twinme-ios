/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import "ItemCell.h"

#import "Item.h"
#import "ConversationViewController.h"

#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>
#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/AsyncManager.h>

//
// Interface: ItemCell ()
//

@interface ItemCell () <UIGestureRecognizerDelegate>

@property NSTimer *ephemeralTimer;

@end

//
// Implementation: ItemCell
//

@implementation ItemCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.clipsToBounds = YES;
    self.isSelectItemMode = NO;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onSwipeInsideContentView:)];
    self.panGestureRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    
    self.backgroundColor = [UIColor clearColor];
    self.item = item;
    self.isSelectItemMode = [conversationViewController isSelectItemMode];
    
    if (((!self.item.isPeerItem && self.item.state == ItemStateRead) || self.item.isPeerItem) && [self.item isEphemeralItem]) {
        if (self.ephemeralTimer) {
            [self.ephemeralTimer invalidate];
            self.ephemeralTimer = nil;
        }
        
        int64_t timeInterval = (self.item.readTimestamp + self.item.expireTimeout) - ([[NSDate date] timeIntervalSince1970] * 1000);
        if (timeInterval > 0) {
            self.ephemeralTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval / 1000 target:self selector:@selector(deleteEphemeralItem) userInfo:nil repeats:NO];
        }
    }
}

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController asyncManager:(AsyncManager *)asyncManager {
    
}

- (void)startDeleteAnimation {
    
    NSAssert(YES, @"abstract method");
}

- (void)deleteEphemeralItem {
    
    NSAssert(YES, @"abstract method");
}

- (CGFloat)annotationWidth:(TLDescriptorAnnotation *)descriptorAnnotation {
    
    if (descriptorAnnotation.count == 1) {
        return Design.ANNOTATION_CELL_WIDTH_NORMAL;
    } else {
        return Design.ANNOTATION_CELL_WIDTH_LARGE;
    }
}

- (CGFloat)annotationCollectionWidth {
    
    CGFloat width = 0;
    
    if (self.item.forwarded) {
        width += Design.ANNOTATION_CELL_WIDTH_NORMAL;
    }
    
    if ([self.item isEditedtem]) {
        width += Design.ANNOTATION_CELL_WIDTH_NORMAL;
    }
    
    for (TLDescriptorAnnotation *descriptorAnnotation in self.item.likeDescriptorAnnotations) {
        width += [self annotationWidth:descriptorAnnotation];
    }
    
    return width;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    if (self.replyImageLoader) {
        [self.replyImageLoader cancel];
        self.replyImageLoader = nil;
    }

    if (self.replyVideoLoader) {
        [self.replyVideoLoader cancel];
        self.replyVideoLoader = nil;
    }

    self.item = nil;
    if (self.ephemeralTimer) {
        [self.ephemeralTimer invalidate];
        self.ephemeralTimer = nil;
    }
}

- (void)dealloc {
    
    self.panGestureRecognizer = nil;
}

#pragma mark - PanGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        self.panGestureRecognizer = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint translation = [self.panGestureRecognizer translationInView:gestureRecognizer.view];
        
        if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
            if ((translation.x < 0 && ![self.item isPeerItem]) || (translation.x > 0 && [self.item isPeerItem])) {
                return NO;
            }
        } else {
            if ((translation.x > 0 && ![self.item isPeerItem]) || (translation.x < 0 && [self.item isPeerItem])) {
                return NO;
            }
        }
        
        return fabs(translation.y) <= fabs(translation.x);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.superview];
        return fabs(velocity.y) <= 0.25;
    }
    return YES;
}

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
        
    CGPoint translation = [panGesture translationInView:self];
    
    if (!self.item || !self.item.replyAllowed || self.item.state == ItemStateDeleted) {
        return;
    }
    
    self.contentView.clipsToBounds = NO;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        if ([self.item isPeerItem]) {
            if (self.contentView.frame.origin.x > 0) {
                [self.contentView setFrame: CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                return;
            }
        } else {
            if (self.contentView.frame.origin.x < 0) {
                [self.contentView setFrame: CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                return;
            }
        }
    } else {
        if ([self.item isPeerItem]) {
            if (self.contentView.frame.origin.x < 0) {
                [self.contentView setFrame: CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                return;
            }
        } else {
            if (self.contentView.frame.origin.x > 0) {
                [self.contentView setFrame: CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                return;
            }
        }
    }
    
    self.contentView.center = CGPointMake(self.contentView.center.x + translation.x, self.contentView.center.y);
    [panGesture setTranslation:CGPointMake(0, 0) inView:self];
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.contentView.frame.origin.x;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.contentView setFrame: CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        } completion:^(BOOL finished) {
            self.contentView.clipsToBounds = YES;
            if (fabs(x) > Design.SWIPE_WIDTH_TO_REPLY) {
                if ([self.replyItemDelegate respondsToSelector:@selector(swipeToReplyToItem:)]) {
                    [self.replyItemDelegate swipeToReplyToItem:self.item];
                }
            }
        }];
    }
}

@end
