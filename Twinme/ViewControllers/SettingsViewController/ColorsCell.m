/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ColorsCell.h"
#import "ColorCell.h"

#import "PersonalizationViewController.h"

#import "UICustomColor.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *COLOR_CELL_IDENTIFIER = @"ColorCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 80;
static CGFloat DESIGN_COLLECTION_CELL_WIDTH = 70;
static CGFloat DESIGN_COLLECTION_WIDTH_INSET = 14;

//
// Interface: ColorsCell
//

@interface ColorsCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *colorsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) NSMutableArray *colors;
@property (nonatomic) UICustomColor *selectedColor;

@end

//
// Implementation: ColorsCell
//

#undef LOG_TAG
#define LOG_TAG @"ColorsCell"

@implementation ColorsCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.colors = Design.COLORS;
    
    for (UICustomColor *customColor in self.colors) {
        if ([customColor.color isEqualToString:Design.MAIN_STYLE]) {
            [customColor setSelectedColor:YES];
            self.selectedColor = customColor;
            break;
        }
    }
    
    if (!self.selectedColor) {
        UICustomColor *customColor = self.colors[0];
        [customColor setSelectedColor:YES];
        self.selectedColor = self.colors[0];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setSectionInset:UIEdgeInsetsMake(0, DESIGN_COLLECTION_WIDTH_INSET * Design.WIDTH_RATIO, 0, DESIGN_COLLECTION_WIDTH_INSET * Design.WIDTH_RATIO)];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(widthCell, heightCell)];
    
    [self.colorsCollectionView setCollectionViewLayout:viewFlowLayout];
    self.colorsCollectionView.dataSource = self;
    self.colorsCollectionView.delegate = self;
    self.colorsCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.colorsCollectionView registerNib:[UINib nibWithNibName:@"ColorCell" bundle:nil] forCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER];
}

- (void)bind {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [self.colorsCollectionView reloadData];
    
    [self updateColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.colors.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    return CGSizeMake(widthCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    ColorCell *colorCell = [collectionView dequeueReusableCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UICustomColor *uiColor = self.colors[indexPath.row];
    [colorCell bindWithColor:uiColor];
    
    return colorCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    self.selectedColor = self.colors[indexPath.row];
    [Design setMainColor:self.selectedColor.color];
    
    for (UICustomColor *color in self.colors) {
        if ([color isEqual:self.selectedColor]) {
            [color setSelectedColor:YES];
        } else {
            [color setSelectedColor:NO];
        }
    }
    
    [self.colorsCollectionView reloadData];
    
    if ([self.personalizationDelegate respondsToSelector:@selector(updateColor)]) {
        [self.personalizationDelegate updateColor];
    }
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.colorsCollectionView.backgroundColor = Design.WHITE_COLOR;
}

@end
