/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: DayCell
//

@class UIScheduleDay;

@interface DayCell : UICollectionViewCell

- (void)bind:(nonnull UIScheduleDay *)scheduleDay height:(CGFloat)height;

@end
