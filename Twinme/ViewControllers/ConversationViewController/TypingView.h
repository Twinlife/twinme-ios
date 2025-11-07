/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TypingView
//
#import <Twinme/TLContact.h>

@interface TypingView : UIView

- (void)setOriginators:(nonnull NSArray<UIImage *> *)originators;

@end
