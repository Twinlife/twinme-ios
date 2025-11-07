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

#import "WelcomeHelpViewController.h"

#import "WelcomeCell.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import "WelcomeFlowLayout.h"
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Design.h>

#import "UIWelcome.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat MIN_CONTENT_VIEW_HEIGHT = 290;
static CGFloat MIN_CONTENT_CELL_HEIGHT = 640;
static CGFloat TEXT_MARGIN = 44;

static NSString *WELCOME_CELL_IDENTIFIER = @"WelcomeCellIdentifier";

//
// Interface: WelcomeHelpViewController ()
//

@interface WelcomeHelpViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *welcomeCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomePageControlBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomePageControlWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *welcomePageControl;

@property (nonatomic) NSMutableArray *uiWelcome;

@property (nonatomic) UIView *overlayView;

@end

#undef LOG_TAG
#define LOG_TAG @"WelcomeHelpViewController"

@implementation WelcomeHelpViewController

#pragma mark - UIViewController

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
    [self initWelcome];
    [self showActionView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.uiWelcome.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(self.view.frame.size.width, self.welcomeCollectionViewHeightConstraint.constant);
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
        
    WelcomeCell *welcomeCell = [collectionView dequeueReusableCellWithReuseIdentifier:WELCOME_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIWelcome *uiWelcome = [self.uiWelcome objectAtIndex:indexPath.row];
    [welcomeCell bindWithTitle:[uiWelcome getMessage] image:[uiWelcome getImage] font:Design.FONT_MEDIUM32];
    
    return welcomeCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    CGFloat center = width / 2.0;
    int currentPage = (int) ((offset + center) / width);
    self.welcomePageControl.currentPage = currentPage;
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
    
    self.logoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.welcomeCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeCollectionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.welcomeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.welcomeCollectionView.dataSource = self;
    self.welcomeCollectionView.delegate = self;
    self.welcomeCollectionView.pagingEnabled = YES;
    
    self.welcomeCollectionView.backgroundColor = [UIColor clearColor];
    [self.welcomeCollectionView registerNib:[UINib nibWithNibName:@"WelcomeCell" bundle:nil] forCellWithReuseIdentifier:WELCOME_CELL_IDENTIFIER];
    
    self.welcomePageControlWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.welcomePageControlBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.welcomePageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.welcomePageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    self.welcomePageControl.userInteractionEnabled = NO;
    
    self.welcomePageControl.transform = CGAffineTransformMakeScale(1.2, 1.2);
}

- (void)initWelcome {
    DDLogVerbose(@"%@ initWelcome", LOG_TAG);
    
    self.uiWelcome = [[NSMutableArray alloc]init];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartOne spaceSettings:self.currentSpace.settings
                              ]];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartTwo spaceSettings:self.currentSpace.settings]];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartThree spaceSettings:self.currentSpace.settings]];
    
    self.welcomePageControl.numberOfPages = self.uiWelcome.count;
        
    CGFloat maxCollectionViewHeight = Design.DISPLAY_HEIGHT - (MIN_CONTENT_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    CGFloat textWidth = Design.DISPLAY_WIDTH - (TEXT_MARGIN * Design.WIDTH_RATIO * 2);
    CGFloat minContentCell = MIN_CONTENT_CELL_HEIGHT * Design.HEIGHT_RATIO;
    
    CGFloat collectionViewHeight = 0;
    for (UIWelcome *uiWelcome in self.uiWelcome) {
        
        CGRect textRect = [[uiWelcome getMessage] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
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
    
    self.welcomeCollectionViewHeightConstraint.constant = collectionViewHeight;
    
    [self setupOnboarding];
}

- (void)setupOnboarding {
    DDLogVerbose(@"%@ setupOnboarding", LOG_TAG);
    
    WelcomeFlowLayout *viewFlowLayout = [[WelcomeFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(self.view.frame.size.width, self.welcomeCollectionViewHeightConstraint.constant)];
    [self.welcomeCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.welcomeCollectionView reloadData];
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

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end
