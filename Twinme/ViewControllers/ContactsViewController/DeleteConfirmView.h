/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

typedef enum {
    DeleteConfirmTypeHistory,
    DeleteConfirmTypeFile,
    DeleteConfirmTypeGroupMember,
    DeleteConfirmTypeOriginator,
    DeleteConfirmTypeSpace,
} DeleteConfirmType;

//
// Interface: DeleteConfirmView
//

@interface DeleteConfirmView : AbstractConfirmView

@property (nonatomic) DeleteConfirmType deleteConfirmType;

- (void)setConfirmTitle:(NSString *)confirmTitle;

@end
