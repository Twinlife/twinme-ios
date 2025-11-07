/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ApplicationAssertion.h"

//
// Implementation: TLApplicationAssertPoint
//

@implementation ApplicationAssertPoint

TL_CREATE_ASSERT_POINT(REGISTER_FOR_REMOTE_FAILED, 5000)

TL_CREATE_ASSERT_POINT(INVALID_TITLE, 5001)
TL_CREATE_ASSERT_POINT(INVALID_SUBJECT, 5002)
TL_CREATE_ASSERT_POINT(INVALID_NAME, 5003)
TL_CREATE_ASSERT_POINT(INVALID_DESCRIPTOR, 5004)

@end
