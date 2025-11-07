/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/CoachMark.h>

@interface CoachMarkManager : NSObject

- (BOOL)showCoachMark;

- (void)setShowCoachMark:(BOOL)showCoachMark;

- (BOOL)showCoachMark:(CoachMarkTag)coachMarkTag;

- (void)resetCoachMark;

- (void)hideAllCoachMark;

- (void)hideCoachMark:(CoachMarkTag)coachMarkTag;

@end
