/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


//
// Protocol: ExpirationDateDelegate
//

@protocol ExpirationDateDelegate <NSObject>

- (void)didChangeDate:(NSDate *)date;

@end

//
// Interface: ExpirationDateCell
//

@interface ExpirationDateCell : UITableViewCell

@property (weak, nonatomic) id<ExpirationDateDelegate> expirationDateDelegate;

- (void)bind;

@end
