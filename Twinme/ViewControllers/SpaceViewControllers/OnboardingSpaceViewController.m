/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "OnboardingSpaceViewController.h"

#import "OnboardingSpaceFirstPartCell.h"
#import "OnboardingSpaceSecondPartCell.h"
#import "OnboardingSpaceThirdPartCell.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import "WelcomeFlowLayout.h"
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Design.h>
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ONBOARDING_SPACE_FIRST_PART_CELL_IDENTIFIER = @"OnboardingSpaceFirstPartCellIdentifier";
static NSString *ONBOARDING_SPACE_SECOND_PART_CELL_IDENTIFIER = @"OnboardingSpaceSecondPartCellIdentifier";
static NSString *ONBOARDING_SPACE_THIRD_PART_CELL_IDENTIFIER = @"OnboardingSpaceThirdPartCellIdentifier";

static CGFloat MIN_CONTENT_VIEW_HEIGHT = 278;
static CGFloat DESIGN_ONBOARDING_SPACE_FIRST_PART_CELL_HEIGHT = 558;
static CGFloat DESIGN_ONBOARDING_SPACE_SECOND_PART_CELL_HEIGHT = 420;
static CGFloat DESIGN_ONBOARDING_SPACE_THIRD_PART_CELL_HEIGHT = 562;
static CGFloat DESIGN_ONBOARDING_SPACE_THIRD_PART_CELL_SMALL_HEIGHT = 442;
static CGFloat DESIGN_TEXT_MARGIN = 30;

//
// Interface: OnboardingSpaceViewController ()

@interface OnboardingSpaceViewController () <OnboardingSpaceDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *onboardingCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingPageControlBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onboardingPageControlWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *onboardingPageControl;

@property (nonatomic) UIView *overlayView;

@property (nonatomic) BOOL hideFirstPart;
@property (nonatomic) int firstPartIndex;
@property (nonatomic) int secondPartIndex;
@property (nonatomic) int thirdPartIndex;

@end

#undef LOG_TAG
#define LOG_TAG @"OnboardingSpaceViewController"

@implementation OnboardingSpaceViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hideFirstPart = NO;
        _startFromSupportSection = NO;
        _firstPartIndex = 0;
        _secondPartIndex = 1;
        _thirdPartIndex = 2;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
}

- (void)showInView:(UIViewController*)view hideFirstPart:(BOOL)hideFirstPart {
    DDLogVerbose(@"%@ showInView", LOG_TAG);
    
    self.hideFirstPart = hideFirstPart;
    
    if (self.hideFirstPart) {
        self.firstPartIndex = -1;
        self.secondPartIndex = 0;
        self.thirdPartIndex = 1;
    }
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    
    [self setupOnboarding];
    [self showActionView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.hideFirstPart) {
        return 2;
    }
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH, self.onboardingCollectionViewHeightConstraint.constant);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ willDisplayCell: %@ forItemAtIndexPath: %@", LOG_TAG, collectionView, cell, indexPath);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (indexPath.row == self.firstPartIndex) {
        OnboardingSpaceFirstPartCell *onboardingSpaceFirstPartCell = [collectionView dequeueReusableCellWithReuseIdentifier:ONBOARDING_SPACE_FIRST_PART_CELL_IDENTIFIER forIndexPath:indexPath];
        [onboardingSpaceFirstPartCell bind];
        return onboardingSpaceFirstPartCell;
    } else if (indexPath.row == self.secondPartIndex) {
        OnboardingSpaceSecondPartCell *onboardingSpaceSecondPartCell = [collectionView dequeueReusableCellWithReuseIdentifier:ONBOARDING_SPACE_SECOND_PART_CELL_IDENTIFIER forIndexPath:indexPath];
        onboardingSpaceSecondPartCell.onboardingSpaceDelegate = self;
        [onboardingSpaceSecondPartCell bind];
        return onboardingSpaceSecondPartCell;
    } else {
        OnboardingSpaceThirdPartCell *onboardingSpaceThirdPartCell = [collectionView dequeueReusableCellWithReuseIdentifier:ONBOARDING_SPACE_THIRD_PART_CELL_IDENTIFIER forIndexPath:indexPath];
        onboardingSpaceThirdPartCell.onboardingSpaceDelegate = self;
        [onboardingSpaceThirdPartCell bind:self.startFromSupportSection];
        return onboardingSpaceThirdPartCell;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    CGFloat center = width / 2.0;
    int currentPage = (int) ((offset + center) / width);
    self.onboardingPageControl.currentPage = currentPage;
}

#pragma mark - OnboardingSpaceDelegate

- (void)didShowMoreText:(int)page {
    DDLogVerbose(@"%@ didShowMoreText: %d", LOG_TAG, page);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    [self.onboardingCollectionView reloadData];
}

- (void)didTouchCreateSpace {
    DDLogVerbose(@"%@ didTouchCreateSpace", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    
    if (self.startFromSupportSection) {
        [self closeActionView];
    } else {
        [self finish];
    }
}

- (void)didTouchDoNotDisplayAgain {
    DDLogVerbose(@"%@ didTouchDoNotDisplayAgain", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
        
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.isAccessibilityElement = NO;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .0f;
    self.overlayView.userInteractionEnabled = YES;
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    UITapGestureRecognizer *tapOverlayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGestureRecognizer];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.hidden = YES;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.actionView.layer.cornerRadius = 40 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
        
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.actionView addGestureRecognizer:swipeGestureRecognizer];
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_BOLD36;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.text = TwinmeLocalizedString(@"premium_services_view_controller_space_title", nil);;
        
    self.onboardingCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.onboardingCollectionView.dataSource = self;
    self.onboardingCollectionView.delegate = self;
    self.onboardingCollectionView.pagingEnabled = YES;
    
    self.onboardingCollectionView.backgroundColor = [UIColor clearColor];
    [self.onboardingCollectionView registerNib:[UINib nibWithNibName:@"OnboardingSpaceFirstPartCell" bundle:nil] forCellWithReuseIdentifier:ONBOARDING_SPACE_FIRST_PART_CELL_IDENTIFIER];
    [self.onboardingCollectionView registerNib:[UINib nibWithNibName:@"OnboardingSpaceSecondPartCell" bundle:nil] forCellWithReuseIdentifier:ONBOARDING_SPACE_SECOND_PART_CELL_IDENTIFIER];
    [self.onboardingCollectionView registerNib:[UINib nibWithNibName:@"OnboardingSpaceThirdPartCell" bundle:nil] forCellWithReuseIdentifier:ONBOARDING_SPACE_THIRD_PART_CELL_IDENTIFIER];
    
    self.onboardingPageControlWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.onboardingPageControlBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.onboardingPageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.onboardingPageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    if (self.hideFirstPart) {
        self.onboardingPageControl.numberOfPages = 2;
    } else {
        self.onboardingPageControl.numberOfPages = 3;
    }
    
    self.onboardingPageControl.transform = CGAffineTransformMakeScale(1.2, 1.2);
}

- (void)setupOnboarding {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    CGFloat titleWidth = Design.DISPLAY_WIDTH - (self.titleLabelLeadingConstraint.constant * 2);
    CGRect titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(titleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_BOLD36
    } context:nil];
    
    CGFloat maxCollectionViewHeight = Design.DISPLAY_HEIGHT - (MIN_CONTENT_VIEW_HEIGHT * Design.HEIGHT_RATIO) - titleRect.size.height;
    
    CGFloat collectionViewHeight = 0;
    
    CGFloat heightFisrtPart = self.firstPartIndex != -1 ? [self getHeightCell:self.firstPartIndex] : 0;
    CGFloat heightSecondPart = [self getHeightCell:self.secondPartIndex];
    CGFloat heightThirdPart = [self getHeightCell:self.thirdPartIndex];
    
    collectionViewHeight = MAX(heightFisrtPart, heightSecondPart);
    collectionViewHeight = MAX(collectionViewHeight, heightThirdPart);
    
    if (collectionViewHeight > maxCollectionViewHeight) {
        collectionViewHeight = maxCollectionViewHeight;
    }
    
    self.onboardingCollectionViewHeightConstraint.constant = collectionViewHeight;
    
    WelcomeFlowLayout *viewFlowLayout = [[WelcomeFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(self.view.frame.size.width, self.onboardingCollectionViewHeightConstraint.constant)];
    [self.onboardingCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.onboardingCollectionView reloadData];
}

- (CGFloat)getHeightCell:(int)index {
    DDLogVerbose(@"%@ getHeightCell: %d", LOG_TAG, index);
    
    CGFloat heightCell = 0;
    if (index == self.firstPartIndex) {
        NSString *message = TwinmeLocalizedString(@"spaces_view_controller_message", nil);
        heightCell = (DESIGN_ONBOARDING_SPACE_FIRST_PART_CELL_HEIGHT * Design.HEIGHT_RATIO) + [self getHeightText:message];
    } else if (index == self.secondPartIndex) {
        NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_1", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_2", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_3", nil)];
        CGFloat height = (DESIGN_ONBOARDING_SPACE_SECOND_PART_CELL_HEIGHT * Design.HEIGHT_RATIO);
        heightCell = height + [self getHeightText:message];
    } else if (index == self.thirdPartIndex) {
        NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_4", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_5", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_6", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_7", nil)];
        [message appendString:@"\n\n"];
        [message appendString:TwinmeLocalizedString(@"create_space_view_controller_onboarding_message_part_8", nil)];
        
        CGFloat height = self.startFromSupportSection ? (DESIGN_ONBOARDING_SPACE_THIRD_PART_CELL_SMALL_HEIGHT * Design.HEIGHT_RATIO) : (DESIGN_ONBOARDING_SPACE_THIRD_PART_CELL_HEIGHT * Design.HEIGHT_RATIO);
        heightCell = height + [self getHeightText:message];
    }
    
    return heightCell;
}

- (CGFloat)getHeightText:(NSString *)string {
    DDLogVerbose(@"%@ getHeightText: %@", LOG_TAG, string);
    
    CGFloat textWidth = Design.DISPLAY_WIDTH - (DESIGN_TEXT_MARGIN * Design.WIDTH_RATIO * 2);
    CGRect textRect = [string boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
        NSFontAttributeName : Design.FONT_MEDIUM32
    } context:nil];
            
    return textRect.size.height + Design.FONT_MEDIUM32.lineHeight;
}

- (void)showActionView {
    DDLogVerbose(@"%@ showActionView", LOG_TAG);
    
    self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    self.actionView.hidden = NO;

    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.3f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT - self.actionView.frame.size.height, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
    }];
}

- (void)closeActionView {
    DDLogVerbose(@"%@ closeActionView", LOG_TAG);
    
    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
        [self finish];
    }];
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self closeActionView];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
