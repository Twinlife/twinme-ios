/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: SectionCallDelegate
//

@protocol SectionCallDelegate <NSObject>

- (void)didTapRight;

@end

//
// Interface: SectionCallCell
//

@interface SectionCallCell : UITableViewCell

@property (weak, nonatomic) id<SectionCallDelegate> sectionCallDelegate;

- (void)bindWithTitle:(NSString *)title hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString showRightAction:(BOOL)showRightAction;

@end
