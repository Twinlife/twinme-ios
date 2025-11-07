/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIStorage;

//
// Interface: StorageCell
//

@interface StorageCell : UITableViewCell

- (void)bindWithStorage:(UIStorage *)uiStorage;

@end
