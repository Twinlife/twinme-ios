/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: NotificationSoundCell
//

@interface NotificationSoundCell : UITableViewCell

- (void)bindWithName:(NSString *)name;

@property (nonatomic) BOOL checked;

@end
