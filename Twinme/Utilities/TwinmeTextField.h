/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TwinmeTextField
//

static NSString * const TwinmeTextFieldDidPasteItemNotification = @"TwinmeTextFieldDidPasteItemNotification";
static NSString * const TwinmeTextFieldDeleteBackWardNotification = @"TwinmeTextFieldDeleteBackWardNotification";

@interface TwinmeTextField : UITextField

@property(nonatomic) BOOL overrideDeleteBackWard;

@end

