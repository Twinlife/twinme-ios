/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: ConfirmViewDelegate
//

@class AbstractConfirmView;

@protocol ConfirmViewDelegate <NSObject>

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView;

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView;

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView;

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView;

@end

@interface AbstractConfirmView : UIView

@property (weak, nonatomic) id<ConfirmViewDelegate> confirmViewDelegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *bulletView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (nonatomic) BOOL forceDarkMode;

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon;

- (void)setConfirmTitle:(nonnull NSString *)title;

- (void)updateTitle:(nonnull NSMutableAttributedString *)title;

- (void)initViews;

- (void)showConfirmView;

- (void)closeConfirmView;

- (void)handleConfirmTapGesture:(nonnull UITapGestureRecognizer *)sender;

- (void)finish;

- (void)updateColor;

- (void)updateFont;

@end
