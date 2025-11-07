/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "OnboardingExternalCallViewController.h"
#import "TemplateExternalCallViewController.h"

#import "OnboardingExternalCallCell.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "WelcomeFlowLayout.h"
#import "UIOnboarding.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat MIN_CONTENT_VIEW_HEIGHT = 278;
static CGFloat MIN_CONTENT_CELL_HEIGHT = 640;
static CGFloat MIN_CONTENT_CELL_SMALL_HEIGHT = 520;
static CGFloat TEXT_MARGIN = 44;

static NSString *ONBOARDING_CELL_IDENTIFIER = @"OnboardingExternalCallCellIdentifier";

//
// Interface: OnboardingExternalCallViewController ()

@interface OnboardingExternalCallViewController () <OnboardingExternalCallDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

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

@property (nonatomic) NSMutableArray *uiOnboarding;

@property (nonatomic) UIView *overlayView;

@end

#undef LOG_TAG
#define LOG_TAG @"OnboardingExternalCallViewController"

@implementation OnboardingExternalCallViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _startFromSupportSection = NO;
        _createExternalCallEnable = NO;
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

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    [self initOnboarding];
    [self showActionView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.uiOnboarding.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(self.view.frame.size.width, self.onboardingCollectionViewHeightConstraint.constant);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ willDisplayCell: %@ forItemAtIndexPath: %@", LOG_TAG, collectionView, cell, indexPath);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    OnboardingExternalCallCell *onboardingExternalCallCell = [collectionView dequeueReusableCellWithReuseIdentifier:ONBOARDING_CELL_IDENTIFIER forIndexPath:indexPath];
    onboardingExternalCallCell.onboardingExternalCallDelegate = self;
    [onboardingExternalCallCell bindWithOnboarding:[self.uiOnboarding objectAtIndex:indexPath.row] fromSupportSection:self.startFromSupportSection];
    return onboardingExternalCallCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    CGFloat center = width / 2.0;
    int currentPage = (int) ((offset + center) / width);
    self.onboardingPageControl.currentPage = currentPage;
}

#pragma mark - OnboardingExternalCallDelegate

- (void)didTouchDoNotDisplayAgain {
    DDLogVerbose(@"%@ didTouchDoNotDisplayAgain", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
    [self.twinmeApplication setShowOnboardingType:OnboardingTypeExternalCall state:NO];
    [self startExternalCallTemplate];
}

- (void)didTouchCreateExernalCall {
    DDLogVerbose(@"%@ didTouchCreateExernalCall", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    
    if (self.startFromSupportSection) {
        [self closeActionView];
    } else {
        [self startExternalCallTemplate];
    }
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
    self.titleLabel.text = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
        
    self.onboardingCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.onboardingCollectionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.onboardingCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.onboardingCollectionView.dataSource = self;
    self.onboardingCollectionView.delegate = self;
    self.onboardingCollectionView.pagingEnabled = YES;
    
    self.onboardingCollectionView.backgroundColor = [UIColor clearColor];
    [self.onboardingCollectionView registerNib:[UINib nibWithNibName:@"OnboardingExternalCallCell" bundle:nil] forCellWithReuseIdentifier:ONBOARDING_CELL_IDENTIFIER];
    
    self.onboardingPageControlWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.onboardingPageControlBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.onboardingPageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.onboardingPageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    self.onboardingPageControl.userInteractionEnabled = NO;
    
    self.onboardingPageControl.transform = CGAffineTransformMakeScale(1.2, 1.2);
}

- (void)initOnboarding {
    DDLogVerbose(@"%@ initOnboarding", LOG_TAG);
    
    self.uiOnboarding = [[NSMutableArray alloc]init];
        
    [self.uiOnboarding addObject:[[UIOnboarding alloc]initWithOnboardingType:OnboardingExternalCallPartOne hideActionView:YES]];
    [self.uiOnboarding addObject:[[UIOnboarding alloc]initWithOnboardingType:OnboardingExternalCallPartTwo hideActionView:YES]];
    [self.uiOnboarding addObject:[[UIOnboarding alloc]initWithOnboardingType:OnboardingExternalCallPartThree hideActionView:YES]];
    [self.uiOnboarding addObject:[[UIOnboarding alloc]initWithOnboardingType:OnboardingExternalCallPartFour hideActionView:NO]];

    self.onboardingPageControl.numberOfPages = self.uiOnboarding.count;
    
    CGFloat titleWidth = Design.DISPLAY_WIDTH - (self.titleLabelLeadingConstraint.constant * 2);
    CGRect titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(titleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_BOLD36
    } context:nil];
    
    CGFloat maxCollectionViewHeight = Design.DISPLAY_HEIGHT - (MIN_CONTENT_VIEW_HEIGHT * Design.HEIGHT_RATIO) - titleRect.size.height;
    CGFloat textWidth = Design.DISPLAY_WIDTH - (TEXT_MARGIN * Design.WIDTH_RATIO * 2);
    CGFloat minContentCell = self.startFromSupportSection ? (MIN_CONTENT_CELL_SMALL_HEIGHT * Design.HEIGHT_RATIO) : (MIN_CONTENT_CELL_HEIGHT * Design.HEIGHT_RATIO);
    
    CGFloat collectionViewHeight = 0;
    for (UIOnboarding *uiOnboarding in self.uiOnboarding) {
        
        CGRect textRect = [[uiOnboarding getMessage] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
            NSFontAttributeName : Design.FONT_MEDIUM32
        } context:nil];
        
        CGFloat cellContentHeight = minContentCell + textRect.size.height;
        
        if (cellContentHeight > collectionViewHeight) {
            collectionViewHeight = cellContentHeight;
        }
    }
    
    if (collectionViewHeight > maxCollectionViewHeight) {
        collectionViewHeight = maxCollectionViewHeight;
    }
    
    self.onboardingCollectionViewHeightConstraint.constant = collectionViewHeight;
    
    [self setupOnboarding];
}

- (void)setupOnboarding {
    DDLogVerbose(@"%@ setupOnboarding", LOG_TAG);
    
    WelcomeFlowLayout *viewFlowLayout = [[WelcomeFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(self.view.frame.size.width, self.onboardingCollectionViewHeightConstraint.constant)];
    [self.onboardingCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.onboardingCollectionView reloadData];
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

- (void)startExternalCallTemplate {
    DDLogVerbose(@"%@ startExternalCallTemplate", LOG_TAG);
    
    if (!self.createExternalCallEnable) {
        if ([self.onboardingExternalCallDelegate respondsToSelector:@selector(didTouchCreateExernalCall)]) {
            [self.onboardingExternalCallDelegate didTouchCreateExernalCall];
        }
        [self finish];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        TemplateExternalCallViewController *templateExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateExternalCallViewController"];
        [selectedNavigationController pushViewController:templateExternalCallViewController animated:YES];
    }];

    [self finish];

    [CATransaction commit];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
 
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.titleLabel.font = Design.FONT_BOLD36;
}

@end
