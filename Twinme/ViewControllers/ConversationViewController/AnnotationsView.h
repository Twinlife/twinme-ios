/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: AnnotationsViewDelegate
//

@class AnnotationsView;

@protocol AnnotationsViewDelegate <NSObject>

- (void)cancelAnnotationView:(AnnotationsView *)annotationsView;

@end

//
// Interface: AnnotationsView
//

@interface AnnotationsView : AbstractMenuView

@property (weak, nonatomic) id<AnnotationsViewDelegate> annotationsViewDelegate;

- (void)openMenu:(NSMutableArray *)annotations;

@end
