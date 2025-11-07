/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class CoachMarkViewController;
@class CoachMark;

//
// Protocol: CoachMarkDelegate
//

@protocol CoachMarkDelegate <NSObject>

- (void)didTapCoachMarkOverlay:(CoachMarkViewController *)coachMarkViewController;

- (void)didTapCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController;

- (void)didLongPressCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController;

@end

@interface CoachMarkViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<CoachMarkDelegate> delegate;

- (void)initWithCoachMark:(CoachMark *)coachMark;

- (void)showInView:(UIViewController *)view;

- (void)closeView;

- (CoachMark *)getCoachMark;

@end
