/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: DisplayModeDelegate
//

#import <TwinmeCommon/Design.h>

@protocol DisplayModeDelegate <NSObject>

- (void)didSelectMode:(DisplayMode)displayMode;

@end

//
// Interface: DisplayModeCell
//

@interface DisplayModeCell : UITableViewCell

@property (nonatomic, weak) id<DisplayModeDelegate>delegate;

- (void)bind:(DisplayMode)displayMode defaultColor:(UIColor *)defaultColor;

@end
