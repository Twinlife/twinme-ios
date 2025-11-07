/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

#import "SlideContactView.h"
#import "InsideBorderView.h"

#define MAX_NAME_LENGTH 32
#define MAX_DESCRIPTION_LENGTH 128

//
// Interface: AbstractShowViewController
//

@interface AbstractShowViewController : AbstractTwinmeViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backClickableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SlideContactView *actionView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet InsideBorderView *identityView;
@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *identityAvatarView;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *fallbackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;

@property (nonatomic) BOOL isAppear;
@property (nonatomic) NSString *identityName;
@property (nonatomic) UIImage *identityAvatar;
@property (nonatomic) BOOL startModal;

- (void)initViews;

- (void)backTap;

- (void)editTap;

- (void)identityTap;

- (BOOL)showNavigationBar;

- (void)moveSlideToInitialPosition;

- (void)moveSlideToPosition:(CGFloat)position;

- (int)getActionViewHeight;

- (int)getScrollViewContentHeight;

@end
