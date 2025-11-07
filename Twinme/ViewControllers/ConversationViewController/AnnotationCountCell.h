/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AnnotationCountCell
//

@class TLDescriptorAnnotation;
@protocol AnnotationActionDelegate;

@interface AnnotationCountCell : UICollectionViewCell

@property (weak, nonatomic) id<AnnotationActionDelegate> annotationActionDelegate;

- (void)bindWithAnnotation:(TLDescriptorAnnotation *)descriptorAnnotation descriptorId:(TLDescriptorId *)descriptorId isPeerItem:(BOOL)isPeerItem;

@end
