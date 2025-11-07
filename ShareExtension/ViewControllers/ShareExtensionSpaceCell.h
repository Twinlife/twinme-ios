/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

@class TLSpace;

//
// Interface: ShareExtensionSpaceCell
//

@interface ShareExtensionSpaceCell : UITableViewCell

- (void)bindWithSpace:(TLSpace *)space avatar:(UIImage *)avatar currentSpace:(BOOL)isCurrentSpace hideSeparator:(BOOL)hideSeparator;

@end
