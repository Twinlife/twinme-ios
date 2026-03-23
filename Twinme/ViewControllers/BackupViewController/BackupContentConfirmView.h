/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractBottomSheetView.h"

//
// Interface: BackupContentConfirmView
//

@class RestoreReport;

@interface BackupContentConfirmView : AbstractBottomSheetView

- (void)initWithStats:(nonnull NSDictionary<NSUUID *, NSNumber *> *)stats;

- (void)initWithRestoreReport:(nonnull RestoreReport *)restoreReport isLastBackup:(BOOL)isLastBackup;

- (void)setConfirmTitle:(nonnull NSString *)confirmTitle;

@end
