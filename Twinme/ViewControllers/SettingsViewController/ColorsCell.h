/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ColorsCell
//

@protocol PersonalizationDelegate;

@interface ColorsCell : UITableViewCell

@property (weak, nonatomic) id<PersonalizationDelegate> personalizationDelegate;

- (void)bind;

@end
