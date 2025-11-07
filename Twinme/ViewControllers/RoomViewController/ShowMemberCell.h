/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ShowMemberCell
//

@interface ShowMemberCell : UICollectionViewCell

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar memberCount:(NSInteger)memberCount;

@end
