/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <Twinlife/TLAssertion.h>

//
// Interface: TLApplicationAssertPoint
//

@interface ApplicationAssertPoint : TLAssertPoint

+(nonnull TLAssertPoint *)REGISTER_FOR_REMOTE_FAILED;
+(nonnull TLAssertPoint *)INVALID_TITLE;
+(nonnull TLAssertPoint *)INVALID_SUBJECT;
+(nonnull TLAssertPoint *)INVALID_NAME;
+(nonnull TLAssertPoint *)INVALID_DESCRIPTOR;

@end
