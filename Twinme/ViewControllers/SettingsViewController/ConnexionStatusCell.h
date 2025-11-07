/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ConnexionStatusCell
//

@class UIAppInfo;

@interface ConnexionStatusCell : UITableViewCell

- (void)bind:(UIAppInfo *)uiAppInfo proxy:(NSString *)proxy;

@end
