/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AbstractShowViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/CallViewController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_AVATAR_OVER_WIDTH = 120;
static CGFloat DESIGN_ACTION_VIEW_MIN_TOP = 80;
static CGFloat DESIGN_ACTION_VIEW_MIN_MARGIN = 90;
static CGFloat AVATAR_MAX_SIZE;
static CGFloat AVATAR_OVER_WIDTH;
static CGFloat ACTION_VIEW_HEIGHT;
static CGFloat ACTION_VIEW_MAX_TOP;
static CGFloat ACTION_VIEW_MIN_MARGIN;

//
// Interface: AbstractShowViewController ()
//

@interface AbstractShowViewController () <SlideContactViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *identityImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityAvatarViewTrailingConstraint;

@property (nonatomic) CALayer *avatarContainerViewLayer;
@property (nonatomic) UIImage *avatar;

@property (nonatomic) BOOL isAppear;
@property (nonatomic) BOOL initActionViewPosition;

@property (nonatomic) float lastOffset;
@property (nonatomic) float initialOffset;
@property (nonatomic) float initialSize;

@end

#undef LOG_TAG
#define LOG_TAG @"AbstractShowViewController"

@implementation AbstractShowViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    AVATAR_OVER_WIDTH = DESIGN_AVATAR_OVER_WIDTH * Design.WIDTH_RATIO;
    AVATAR_MAX_SIZE = Design.DISPLAY_WIDTH + (AVATAR_OVER_WIDTH * 2);
    ACTION_VIEW_MAX_TOP = Design.DISPLAY_WIDTH - AVATAR_OVER_WIDTH;
    ACTION_VIEW_HEIGHT = Design.DISPLAY_HEIGHT - (DESIGN_ACTION_VIEW_MIN_TOP * Design.HEIGHT_RATIO);
    ACTION_VIEW_MIN_MARGIN = DESIGN_ACTION_VIEW_MIN_MARGIN * Design.HEIGHT_RATIO;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _initActionViewPosition = NO;
        _lastOffset = 0;
        _initialOffset = 0;
        _initialSize = 0;
        _startModal = NO;
    }
    return self;
}


- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
}

- (int)getScrollViewContentHeight {
    DDLogVerbose(@"%@ getScrollViewContentHeight", LOG_TAG);
    
    int actionViewHeight = [self getActionViewHeight];
    
    if ([self getActionViewHeight] == -1) {
        actionViewHeight = ACTION_VIEW_HEIGHT;
    }
    return actionViewHeight + ACTION_VIEW_MAX_TOP;
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
        
    self.navigationController.delegate = self;
    
    if (self.startModal) {
        self.startModal = NO;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    self.isAppear = YES;
    
    if (!self.initActionViewPosition) {
        self.initActionViewPosition = YES;
        int actionViewHeight = [self getActionViewHeight];
        if (actionViewHeight != -1) {
            int heightDiff = Design.DISPLAY_HEIGHT - actionViewHeight;
            if (heightDiff < 0) {
                [self.actionView setSlideContactTopMargin:heightDiff];
            }
            self.actionViewHeightConstraint.constant = actionViewHeight;
        }
        [self.actionView setMinPosition:AVATAR_MAX_SIZE - ACTION_VIEW_MIN_MARGIN];
        
        self.containerViewHeightConstraint.constant = [self getScrollViewContentHeight];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidDisappear:animated];
    
    self.isAppear = NO;
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    if (self.navigationController.viewControllers.count > 1) {
        [self finish];
    } else {
        [self openSideMenu:YES];
    }
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    return -1;
}

- (BOOL)showNavigationBar {
    DDLogVerbose(@"%@ showNavigationBar", LOG_TAG);
    
    return YES;
}

- (void)moveSlideToInitialPosition {
    DDLogVerbose(@"%@ moveSlideToInitialPosition", LOG_TAG);
    
    [self moveSlideToPosition:ACTION_VIEW_MAX_TOP];
}

- (void)moveSlideToPosition:(CGFloat)position {
    DDLogVerbose(@"%@ moveSlideToPosition: %f", LOG_TAG, position);
    
    CGFloat diffPosition = self.actionViewTopConstraint.constant - position;
    CGFloat avatarViewSize = self.avatarViewWidthConstraint.constant - diffPosition;
    
    if (avatarViewSize < Design.DISPLAY_WIDTH) {
        avatarViewSize = Design.DISPLAY_WIDTH;
    } else if (avatarViewSize > AVATAR_MAX_SIZE) {
        avatarViewSize = AVATAR_MAX_SIZE;
    }
    
    self.avatarViewWidthConstraint.constant = avatarViewSize;
    self.avatarViewHeightConstraint.constant = avatarViewSize;
    self.actionViewTopConstraint.constant = position;
}

#pragma mark - SlideContactViewDelegate methods

- (void)didMoveView:(SlideContactView *)slideContactView {
    DDLogVerbose(@"%@ didMoveView: %@", LOG_TAG, slideContactView);
    
    CGFloat diffPosition = self.actionViewTopConstraint.constant - slideContactView.frame.origin.y;
    
    CGFloat avatarViewSize = self.avatarViewWidthConstraint.constant - diffPosition;
    
    if (avatarViewSize < Design.DISPLAY_WIDTH) {
        avatarViewSize = Design.DISPLAY_WIDTH;
    } else if (avatarViewSize > AVATAR_MAX_SIZE) {
        avatarViewSize = AVATAR_MAX_SIZE;
    }
    
    if (slideContactView.frame.origin.y > 0) {
        self.avatarViewWidthConstraint.constant = avatarViewSize;
        self.avatarViewHeightConstraint.constant = avatarViewSize;
    }
        
    self.actionViewTopConstraint.constant = slideContactView.frame.origin.y;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    if (scrollView == self.scrollView) {
        
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat diffPosition = self.lastOffset - offset;
        CGFloat avatarViewSize = self.avatarViewWidthConstraint.constant + diffPosition;
        
        if (avatarViewSize < Design.DISPLAY_WIDTH) {
            avatarViewSize = Design.DISPLAY_WIDTH;
        } else if (self.initialOffset == offset) {
            avatarViewSize = self.initialSize;
        } else {
            self.lastOffset = offset;
        }
        
        self.avatarViewWidthConstraint.constant = avatarViewSize;
        self.avatarViewHeightConstraint.constant = avatarViewSize;
        
        if (self.initialOffset == 0) {
            self.initialOffset = offset;
            self.initialSize = avatarViewSize;
        }
    }
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    DDLogVerbose(@"%@ navigationController: %@ willShowViewController: %@ animated: %@", LOG_TAG, navigationController, viewController, animated ? @"YES" : @"NO");
    
    if (viewController != self && !self.isAppear) {
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    if (transitionCoordinator.interactive) {
        [transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if ([context isCancelled] && viewController == self) {
                self.navigationController.navigationBarHidden = NO;
            } else if ([self showNavigationBar] && ![context isCancelled] && viewController == self) {
                self.navigationController.navigationBarHidden = YES;
            }
        }];
    } else {
        if (([self showNavigationBar] && viewController == self) || [viewController isKindOfClass:[CallViewController class]]) {
            self.navigationController.navigationBarHidden = YES;
        } else {
            self.navigationController.navigationBarHidden = NO;
        }
        if (![navigationController.viewControllers containsObject:self]) {
            self.view.clipsToBounds = YES;
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.backClickableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.backClickableViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.backClickableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *backGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackTapGesture:)];
    [self.backClickableView addGestureRecognizer:backGestureRecognizer];
    self.backClickableView.isAccessibilityElement = YES;
    
    self.backClickableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.backClickableView.layer.cornerRadius = self.backClickableViewHeightConstraint.constant * 0.5;
    self.backClickableView.clipsToBounds = YES;
    
    self.backImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.backImageView.tintColor = [UIColor whiteColor];
    self.backImageView.image = [self.backImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.avatarViewHeightConstraint.constant = AVATAR_MAX_SIZE - AVATAR_OVER_WIDTH;
    self.avatarViewWidthConstraint.constant = AVATAR_MAX_SIZE - AVATAR_OVER_WIDTH;
        
    self.avatarView.clipsToBounds = YES;
    self.avatarView.userInteractionEnabled = YES;
    
    self.actionViewTopConstraint.constant = ACTION_VIEW_MAX_TOP;
    self.actionViewHeightConstraint.constant = ACTION_VIEW_HEIGHT;
    self.actionView.backgroundColor = Design.WHITE_COLOR;
    self.actionView.slideContactViewDelegate = self;
    self.actionView.canMove = NO;
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabel.font = Design.FONT_BOLD44;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.editViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.editViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *editViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditTapGesture:)];
    [self.editView addGestureRecognizer:editViewGestureRecognizer];
    self.editView.isAccessibilityElement = YES;
    [self.editView setAccessibilityLabel:TwinmeLocalizedString(@"application_edit", nil)];
    
    self.editImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editImageView.tintColor = Design.MAIN_COLOR;
    
    self.descriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.descriptionLabel.font = Design.FONT_REGULAR32;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.descriptionLabel.text = @"";
    
    self.identityViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.identityViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.identityView.isAccessibilityElement = YES;
    UITapGestureRecognizer *identityViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIdentityTapGesture:)];
    [self.identityView addGestureRecognizer:identityViewGestureRecognizer];
    [self.identityView setAccessibilityLabel:TwinmeLocalizedString(@"show_contact_view_controller_identity_title", nil)];
    
    [self.identityView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.identityViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.identityTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.identityTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.identityTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.identityTitleLabel.font = Design.FONT_BOLD26;
    self.identityTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.identityTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_identity_title", nil).uppercaseString;
    
    self.identityImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.identityImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.identityLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.identityLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.identityLabel.font = Design.FONT_REGULAR32;
    self.identityLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.identityAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.identityAvatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.identityAvatarView.layer.cornerRadius = self.identityAvatarViewHeightConstraint.constant * 0.5;
    self.identityAvatarView.clipsToBounds = YES;
    
    self.scrollView.delegate = self;
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.view.clipsToBounds = YES;
        [self backTap];
    }
}

- (void)handleEditTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEditTapGesture", LOG_TAG);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self editTap];
    }
}

- (void)handleIdentityTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleIdentityTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self identityTap];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_BOLD44;
    self.identityTitleLabel.font = Design.FONT_BOLD26;
    self.identityLabel.font = Design.FONT_REGULAR32;
    self.descriptionLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.identityTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.identityLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.actionView.backgroundColor = [UIColor clearColor];
    [self.actionView setNeedsDisplay];
    self.editImageView.tintColor = Design.MAIN_COLOR;
}

@end
