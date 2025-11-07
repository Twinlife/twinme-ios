/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

//
// Interface: ShareExtensionContactCell
//

@interface ShareExtensionContactCell : UITableViewCell

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar isCertified:(BOOL)isCertified hideSeparator:(BOOL)hideSeparator;

@end
