/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: InfoAnnotationItem
//

@class UIAnnotation;

@interface InfoAnnotationItem : Item

@property (nonatomic, nonnull) UIAnnotation *annotation;

- (nonnull instancetype)initWithAnnotation:(nonnull UIAnnotation *)annotation;

@end
