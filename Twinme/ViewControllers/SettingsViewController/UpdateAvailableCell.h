/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UpdateAvailableCell
//

@protocol UpdateVersionDelegate;

@interface UpdateAvailableCell : UITableViewCell

@property (weak, nonatomic) id<UpdateVersionDelegate> updateVersionDelegate;

- (void)bind;

@end
