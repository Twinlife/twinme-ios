/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinme/TLTwinmeContext.h>

@class AlertView;

@protocol AlertViewDelegate <NSObject>

@optional - (void)handleAcceptButtonClick:(AlertView *)alertView;

@optional - (void)handleCancelButtonClick:(AlertView *)alertView;

@optional - (void)handleCloseButtonClick:(AlertView *)alertView;

@end

@interface AlertView : UIViewController

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles alertViewDelegate:(id<AlertViewDelegate>)alertViewDelegate;

- (instancetype)initNetWorkAlertWithTitle:(NSString *)title alertViewDelegate:(id<AlertViewDelegate>)alertViewDelegate twinmeContext:(TLTwinmeContext *)twinmeContext viewController:(UIViewController *)viewController;

- (void)initViews;

- (void)showInView:(UIViewController *)view;

- (void)showNetworkAlertView;

- (void)closeAlertView;

- (void)dispose;

@end
