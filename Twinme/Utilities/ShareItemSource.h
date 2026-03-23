/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
// Interface: ShareItemSource
//

@interface ShareItemSource : NSObject <UIActivityItemSource>

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message subject:(nullable NSString *)subject;

@end
