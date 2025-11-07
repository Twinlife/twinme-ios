/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: AnnotationActionDelegate
//

@protocol EnableNotificationDelegate <NSObject>

- (void)didTapInfoEnableNotification;

@end

//
// Interface: EnableNotificationCell
//

@interface EnableNotificationCell : UITableViewCell

@property (weak, nonatomic) id<EnableNotificationDelegate> enableNotificationDelegate;


- (void)bind;

@end
