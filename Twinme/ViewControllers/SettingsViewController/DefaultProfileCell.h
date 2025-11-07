/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: DefaultProfileCell
//

@protocol DefaultProfileDelegate;

@interface DefaultProfileCell : UITableViewCell

@property (nonatomic, weak) id<DefaultProfileDelegate>delegate;

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar;

@end
