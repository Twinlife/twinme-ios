/*
 *  Copyright (c) 2022-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>

#import "PremiumServicesViewController.h"
#import "InAppSubscriptionViewController.h"

#import "PremiumFeatureCell.h"

#import "UIPremiumFeature.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "UIView+GradientBackgroundColor.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *PREMIUM_FEATURE_CELL_IDENTIFIER = @"PremiumFeatureCellIdentifier";

static float DESIGN_FEATURE_CELL_HEIGHT = 1028;
static float DESIGN_FEATURE_CELL_SPACING = 20;
static CGFloat FEATURE_CELL_HEIGHT;

//
// Interface: PremiumServicesViewController ()
//

@interface PremiumServicesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *featureCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featurePageControlLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *featurePageControlWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *featurePageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UIView *doNotShowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doNotShowLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *doNotShowLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;

@property (nonatomic) NSMutableArray *premiumFeatures;

@end

//
// Implementation: PremiumServicesViewController
//

#undef LOG_TAG
#define LOG_TAG @"PremiumServicesViewController"

@implementation PremiumServicesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hideDoNotShow = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    FEATURE_CELL_HEIGHT = DESIGN_FEATURE_CELL_HEIGHT * Design.HEIGHT_RATIO;
    
    [self initFeatures];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
        
    [self.bottomView setupGradientBackgroundFromColors:Design.BACKGROUND_GRADIENT_COLORS_BLACK];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.premiumFeatures.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return DESIGN_FEATURE_CELL_SPACING * Design.HEIGHT_RATIO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH, FEATURE_CELL_HEIGHT);
}
  
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForFooterInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);

    return CGSizeMake(0, self.bottomViewHeightConstraint.constant);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    PremiumFeatureCell *premiumFeatureCell = [collectionView dequeueReusableCellWithReuseIdentifier:PREMIUM_FEATURE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIPremiumFeature *premiumFeature = [self.premiumFeatures objectAtIndex:indexPath.row];
    [premiumFeatureCell bind:premiumFeature showBorder:YES];
    
    return premiumFeatureCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat cellHeight = DESIGN_FEATURE_CELL_HEIGHT * Design.HEIGHT_RATIO;
    if (offset < (cellHeight * 0.5)) {
        self.featurePageControl.currentPage = 0;
    } else  if (offset < (cellHeight * 1.5)) {
        self.featurePageControl.currentPage = 1;
    } else  if (offset < (cellHeight * 2.5)) {
        self.featurePageControl.currentPage = 2;
    } else  if (offset < (cellHeight * 3.5)) {
        self.featurePageControl.currentPage = 3;
    } else  if (offset < (cellHeight * 4.5)) {
        self.featurePageControl.currentPage = 4;
    } else {
        self.featurePageControl.currentPage = 5;
    }
}
    
#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.updateViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.updateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.updateViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.updateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.updateView.backgroundColor = Design.MAIN_COLOR;
    self.updateView.userInteractionEnabled = YES;
    self.updateView.isAccessibilityElement = YES;
    self.updateView.accessibilityLabel = TwinmeLocalizedString(@"side_menu_view_controller_subscribe", nil);
    self.updateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.updateView.clipsToBounds = YES;
    [self.updateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateTapGesture:)]];
    
    self.updateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.updateLabel.font = Design.FONT_BOLD36;
    self.updateLabel.textColor = [UIColor whiteColor];
    self.updateLabel.text = TwinmeLocalizedString(@"side_menu_view_controller_subscribe", nil);
    self.updateLabel.adjustsFontSizeToFitWidth = YES;
    
    self.featureCollectionView.backgroundColor = [UIColor blackColor];
    self.featureCollectionView.dataSource = self;
    self.featureCollectionView.delegate = self;
    [self.featureCollectionView registerNib:[UINib nibWithNibName:@"PremiumFeatureCell" bundle:nil] forCellWithReuseIdentifier:PREMIUM_FEATURE_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setEstimatedItemSize:CGSizeMake(Design.DISPLAY_WIDTH, FEATURE_CELL_HEIGHT)];
    
    [self.featureCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.featureCollectionView reloadData];
    
    self.featurePageControlLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.featurePageControlWidthConstraint.constant *= Design.WIDTH_RATIO;

    self.featurePageControl.backgroundColor = [UIColor clearColor];
    self.featurePageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.featurePageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    self.featurePageControl.numberOfPages = self.premiumFeatures.count;
    
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(M_PI / 2);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.2, 1.2);
    CGAffineTransform concatTransform =  CGAffineTransformConcat(scaleTransform, rotateTransform);
    CGFloat translationValue = -self.featurePageControlWidthConstraint.constant;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        translationValue = self.featurePageControlWidthConstraint.constant;
    }
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(translationValue * 0.5, 0);
    self.featurePageControl.transform = CGAffineTransformConcat(concatTransform, translateTransform);
    
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.doNotShowLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.doNotShowLabel.font = Design.FONT_MEDIUM24;
    self.doNotShowLabel.textColor = [UIColor whiteColor];
    
    NSMutableAttributedString *laterAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_continue_without_premium_services", nil)];
    [laterAttributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,[laterAttributedString length])];
    [self.doNotShowLabel setAttributedText:laterAttributedString];
    
    self.doNotShowView.userInteractionEnabled = YES;
    [self.doNotShowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoNotShowAgainTapGesture:)]];
    
    self.doNotShowView.hidden = self.hideDoNotShow;
    
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeImageView.tintColor = Design.BLACK_COLOR;
}

- (void)initFeatures {
    DDLogVerbose(@"%@ initFeatures", LOG_TAG);
    
    self.premiumFeatures = [[NSMutableArray alloc]init];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall spaceSettings:self.currentSpace.settings]];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeStreaming spaceSettings:self.currentSpace.settings]];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall spaceSettings:self.currentSpace.settings]];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeClickToCall spaceSettings:self.currentSpace.settings]];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeConversation spaceSettings:self.currentSpace.settings]];
    [self.premiumFeatures addObject:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeRemoteControl spaceSettings:self.currentSpace.settings]];
}

- (void)handleUpdateTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleUpgradeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self dismissViewControllerAnimated:YES completion:^{
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
            InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
            [selectedNavigationController presentViewController:navigationController animated:YES completion:nil];
        }];
    }
}

- (void)handleDoNotShowAgainTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.updateLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.updateView.backgroundColor = Design.MAIN_COLOR;
    self.closeImageView.tintColor = Design.BLACK_COLOR;
}

@end
