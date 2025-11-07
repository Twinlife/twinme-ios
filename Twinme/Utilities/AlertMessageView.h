/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: AlertMessageView
//

@class AlertMessageView;

@protocol AlertMessageViewDelegate <NSObject>

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView;

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView;

@end

@interface AlertMessageView : UIView

@property (weak, nonatomic) id<AlertMessageViewDelegate> alertMessageViewDelegate;
@property (nonatomic) BOOL forceDarkMode;

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message;

- (void)initViews;

- (void)showAlertView;

- (void)closeAlertView;

- (void)finish;

@end
