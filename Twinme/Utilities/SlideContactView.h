/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class SlideContactView;

@protocol SlideContactViewDelegate <NSObject>

@optional - (void)didMoveView:(SlideContactView *)slideContactView;

@end

//
// Interface: SlideContactView
//

@interface SlideContactView : UIView

@property(nonatomic, weak) id<SlideContactViewDelegate> slideContactViewDelegate;
@property(nonatomic) BOOL canMove;

- (void)setSlideContactTopMargin:(CGFloat)topMargin;

- (void)setMinPosition:(CGFloat)position;

@end
