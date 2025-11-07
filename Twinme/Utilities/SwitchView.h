/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class SwitchView;

@protocol SwitchViewDelegate <NSObject>

@optional - (void)switchViewDidTap:(SwitchView *)switchView;

@optional - (void)switchViewNeedsConfirm:(SwitchView *)switchView;

@end

//
// Interface: SwitchView
//

@interface SwitchView : UIView

@property(nonatomic, weak) id<SwitchViewDelegate> switchViewDelegate;
@property(nonatomic) BOOL isOn;
@property(nonatomic) BOOL isEnabled;
@property(nonatomic) BOOL needsConfirm;

- (void)setOn:(BOOL)on;

- (void)setEnabled:(BOOL)enabled;

- (void)setConfirm:(BOOL)confirm;

- (void)resetSwitch;

@end
