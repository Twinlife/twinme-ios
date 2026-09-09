/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: DiagnosticCell
//

@class UIDiagnosticItem;

@interface DiagnosticCell : UITableViewCell

- (void)bind:(nonnull UIDiagnosticItem *)diagnosticItem;

@end
