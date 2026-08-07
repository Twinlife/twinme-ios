/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractBottomSheetView.h>

//
// Interface: DeleteAccountConfirmView
//

@class TLSpaceSettings;

@interface DeleteAccountConfirmView : AbstractBottomSheetView

@property (nonatomic) TLSpaceSettings *spaceSettings;

- (void)updateKeyboard:(CGFloat)sizeKeyboard;

@end
