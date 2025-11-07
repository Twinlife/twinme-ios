/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SelectedMembersCell
//

@interface SelectedMembersCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;

- (void)bindWithMembers:(nonnull NSMutableArray *)uiMembers fromCreateGroup:(BOOL)fromCreateGroup adminAvatar:(nullable UIImage *)adminAvatar;

@end
