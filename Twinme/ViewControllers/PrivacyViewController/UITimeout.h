/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UITimeout
//

@interface UITimeout : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) int64_t timeout;

- (instancetype)initWithTitle:(NSString *)title timeout:(int64_t)timeout;

@end
