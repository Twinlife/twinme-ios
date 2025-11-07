/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CustomTabView.h"

#import "CustomTabCell.h"

#import "UICustomTab.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_VIEW_HEIGHT = 148;
static const CGFloat DESIGN_MIN_MARGIN = 40;

static NSString *CUSTOM_TAB_CELL_IDENTIFIER = @"CustomTabCellIdentifier";

//
// Interface: CustomTabView ()
//

@interface CustomTabView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabContainerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *tabContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *tabCollectionView;

@property (nonatomic) NSArray<UICustomTab *> *customTabs;

@property (nonatomic) UIColor *mainColor;
@property (nonatomic) UIColor *customBackgroundColor;
@property (nonatomic) UIColor *textSelectedColor;
@property (nonatomic) UIColor *borderColor;

@end

//
// Implementation: CustomTabView
//

#undef LOG_TAG
#define LOG_TAG @"CustomTabView"

@implementation CustomTabView

#pragma mark - UIView

- (nonnull instancetype)initWithCustomTab:(nonnull NSArray<UICustomTab *> *)customTabs {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CustomTabView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    
    if (self) {
        _customTabs = customTabs;
        _mainColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
        _customBackgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
        _textSelectedColor = [UIColor whiteColor];
        [self initViews];
    }
    
    return self;
}

- (void)updateColor:(nullable UIColor *)backgroundColor mainColor:(nullable UIColor *)mainColor textSelectedColor:(nullable UIColor *)textSelectedColor borderColor:(nullable UIColor *)borderColor {
    DDLogVerbose(@"%@ updateMainColor", LOG_TAG);
    
    self.mainColor = mainColor;
    self.customBackgroundColor = backgroundColor;
    self.textSelectedColor = textSelectedColor;
    self.borderColor = borderColor;
    
    [self updateColor];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.customTabs.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    UICustomTab *customTab = [self.customTabs objectAtIndex:indexPath.row];
    return CGSizeMake(customTab.width , customTab.height);
}
  
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
        
    CustomTabCell *customTabCell = [collectionView dequeueReusableCellWithReuseIdentifier:CUSTOM_TAB_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UICustomTab *customTab = [self.customTabs objectAtIndex:indexPath.row];
    [customTabCell bindWithCustomTab:customTab mainColor:self.mainColor textSelectedColor:self.textSelectedColor];
    
    return customTabCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
        
    for (UICustomTab *customTab in self.customTabs) {
        customTab.isSelected = NO;
    }
    
    if ([self.customTabViewDelegate respondsToSelector:@selector(didSelectTab:)]) {
        UICustomTab *customTab = [self.customTabs objectAtIndex:indexPath.row];
        customTab.isSelected = YES;
        [self.customTabViewDelegate didSelectTab:customTab];
    }
    
    [self.tabCollectionView reloadData];
}

#pragma mark - private

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    
    self.tabContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.tabContainerView.backgroundColor = Design.CUSTOM_TAB_BACKGROUND_COLOR;
    self.tabContainerView.clipsToBounds = YES;
    self.tabContainerView.layer.cornerRadius = self.tabContainerViewHeightConstraint.constant * 0.5;
    
    self.tabCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.tabCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tabCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.tabCollectionView.backgroundColor = [UIColor clearColor];
    self.tabCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tabCollectionView.dataSource = self;
    self.tabCollectionView.delegate = self;
    [self.tabCollectionView registerNib:[UINib nibWithNibName:@"CustomTabCell" bundle:nil] forCellWithReuseIdentifier:CUSTOM_TAB_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setEstimatedItemSize:CGSizeMake(Design.DISPLAY_WIDTH, 1)];
    [self.tabCollectionView setCollectionViewLayout:viewFlowLayout];
    
    [self updateCollectionViewWidth];
}

- (void)updateCollectionViewWidth {
    DDLogVerbose(@"%@ updateCollectionViewWidth", LOG_TAG);
    
    CGFloat maxWidth = Design.DISPLAY_WIDTH - (2 * DESIGN_MIN_MARGIN * Design.WIDTH_RATIO);
    CGFloat contentWidth = 0;
    for (UICustomTab *customTab in self.customTabs) {
        contentWidth += customTab.width;
    }

    CGFloat collectionMargin;
    if (contentWidth < maxWidth) {
        collectionMargin = (Design.DISPLAY_WIDTH - contentWidth) / 2;
    } else {
        collectionMargin = DESIGN_MIN_MARGIN * Design.WIDTH_RATIO;
    }
        
    self.tabContainerViewLeadingConstraint.constant = collectionMargin;
    self.tabContainerViewTrailingConstraint.constant = collectionMargin;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.backgroundColor = self.customBackgroundColor;
    self.tabContainerView.backgroundColor = Design.CUSTOM_TAB_BACKGROUND_COLOR;
    
    if (self.borderColor) {
        self.tabContainerView.layer.borderColor = self.borderColor.CGColor;
        self.tabContainerView.layer.borderWidth = 1;
    } else {
        self.tabContainerView.layer.borderColor = [UIColor clearColor].CGColor;
        self.tabContainerView.layer.borderWidth = 0;
    }
    
    [self.tabCollectionView reloadData];
}

@end
