/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "WeeklyScheduleCell.h"

#import "DayCell.h"
#import "UIScheduleDay.h"

#import <TwinmeCommon/Design.h>

static NSString *DAY_CELL_IDENTIFIER = @"DayCellIdentifier";

//
// Interface: WeeklyScheduleCell
//

@interface WeeklyScheduleCell() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSMutableArray *days;
@property (nonatomic) CGFloat cellSize;

@end

//
// Implementation: WeeklyScheduleCell
//

@implementation WeeklyScheduleCell

- (void)awakeFromNib {
    [super awakeFromNib];
        
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.cellSize = 0;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DayCell" bundle:nil] forCellWithReuseIdentifier:DAY_CELL_IDENTIFIER];
}

- (void)bind:(CGFloat)width days:(NSMutableArray *)days {
    
    self.days = days;
    [self setupFlowLayout:width];
    [self updateColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.days.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.cellSize, self.cellSize);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    DayCell *dayCell = [collectionView dequeueReusableCellWithReuseIdentifier:DAY_CELL_IDENTIFIER forIndexPath:indexPath];
    [dayCell bind:[self.days objectAtIndex:indexPath.row] height:self.cellSize];
    return dayCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 
    UIScheduleDay *scheduleDay = [self.days objectAtIndex:indexPath.row];
    scheduleDay.isSelected = !scheduleDay.isSelected;
    [self.collectionView reloadData];
    
    if ([self.weeklyScheduleDelegate respondsToSelector:@selector(didSelectDay:)]) {
        [self.weeklyScheduleDelegate didSelectDay:scheduleDay];
    }
}

- (void)setupFlowLayout:(CGFloat)width {
    
    if (self.days && self.days.count > 0) {
        self.cellSize = round(width / self.days.count);
        
        UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [viewFlowLayout setMinimumInteritemSpacing:0];
        [viewFlowLayout setMinimumLineSpacing:0];
        [viewFlowLayout setItemSize:CGSizeMake(self.cellSize, self.cellSize)];
        
        [self.collectionView setCollectionViewLayout:viewFlowLayout];
    }
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end
