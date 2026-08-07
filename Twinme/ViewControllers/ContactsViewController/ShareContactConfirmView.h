/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractBottomSheetView.h>

@class TLContactShareDescriptor;

//
// Interface: ShareContactConfirmView
//

@interface ShareContactConfirmView : AbstractBottomSheetView

@property (nonnull) TLContactShareDescriptor *contactShareDescriptor;

- (void)setup:(NSString *)leftName rightName:(NSString *)rightName contactName:(NSString *)contactName leftAvatar:(UIImage *)leftAvatar rightAvatar:(UIImage *)rightAvatar;

@end
