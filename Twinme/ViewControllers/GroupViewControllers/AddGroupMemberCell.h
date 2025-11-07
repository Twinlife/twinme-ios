/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AddGroupMemberCell
//

@interface AddGroupMemberCell : UITableViewCell

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar  isCertified:(BOOL)isCertified hideSeparator:(BOOL)hideSeparator;

@property (nonatomic) BOOL checked;
@property (nonatomic) BOOL selectable;

@end
