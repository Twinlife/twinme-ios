/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AnnotationInfoViewCell
//

@class UIAnnotation;

@interface AnnotationInfoCell : UITableViewCell

- (void)bindWithAnnotation:(UIAnnotation *)uiAnnotation hideSeparator:(BOOL)hideSeparator;

@end
