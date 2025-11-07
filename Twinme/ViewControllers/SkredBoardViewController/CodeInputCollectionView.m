/*
 *  Copyright (c) 2017 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

#import "CodeInputCollectionView.h"

#import "DigitCollectionViewCell.h"
#import "UIView+GradientBackgroundColor.h"

//
// Interface: UICollectionView()
//

@interface UICollectionView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

//
// Implementation: CodeInputCollectionView
//

@implementation CodeInputCollectionView

static CGFloat kCellHeightRatioInCollectionView = 0.3937;
static int kDigitPerLine = 5;

#pragma mark - Initializers

- (instancetype)init {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if(self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout])
        [self setup];
    return self;
}

#pragma mark - UI Setup

- (void)setup {
    
    self.dataSource = self;
    self.delegate = self;
    [self registerClass:[DigitCollectionViewCell class] forCellWithReuseIdentifier:digitCollectionViewCellIdentifier];
}

- (CGSize)cellSize {
    
    CGFloat cellHeight = self.frame.size.height * kCellHeightRatioInCollectionView;
    return CGSizeMake(cellHeight, cellHeight);
}

- (CGFloat)interItemSpacing {
    
    return (self.frame.size.width - kDigitPerLine * [self cellSize].width) / (kDigitPerLine + 2/* insets left&right = interItemSpacing */);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    CGFloat interItemSpacing = [self interItemSpacing];
    return UIEdgeInsetsMake(0, interItemSpacing, 0, interItemSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    CGFloat interItemSpacing = [self interItemSpacing];
    return interItemSpacing / 2;
}

-
(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return [self interItemSpacing];
}

#pragma mark - UICollectionViewDatasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    DigitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:digitCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *gradientColors;
    if ([self.codeInputCollectionViewDatasource respondsToSelector:@selector(codeInputCollectionView:colorsForDigit:)]) {
        gradientColors = [self.codeInputCollectionViewDatasource codeInputCollectionView:self colorsForDigit:indexPath.row];
    }
    [cell setDigit:indexPath.row gradientColors:gradientColors];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self.codeInputCollectionViewDelegate respondsToSelector:@selector(codeInputCollectionView:didSelectDigit:)]) {
        [self.codeInputCollectionViewDelegate codeInputCollectionView:self didSelectDigit:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    DigitCollectionViewCell *cell = (DigitCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    [cell setHighlight:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    DigitCollectionViewCell *cell = (DigitCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    [cell setHighlight:NO];
}

@end
