/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupWordsCell.h"
#import "BackupWordCell.h"
#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "UIBackupWord.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *BACKUP_WORD_CELL_IDENTIFIER = @"BackupWordCellIdentifier";

static const CGFloat DESIGN_WORD_HEIGHT = 100;

//
// Interface: BackupWordsCell ()
//

@interface BackupWordsCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *wordsCollectionView;

@property (nonatomic) NSArray *words;

@end

//
// Implementation: BackupWordsCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupWordsCell"

@implementation BackupWordsCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.wordsCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordsCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordsCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.wordsCollectionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.wordsCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.wordsCollectionView.dataSource = self;
    self.wordsCollectionView.delegate = self;
    self.wordsCollectionView.scrollEnabled = NO;
    self.wordsCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.wordsCollectionView registerNib:[UINib nibWithNibName:@"BackupWordCell" bundle:nil] forCellWithReuseIdentifier:BACKUP_WORD_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH * 0.5f, DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO)];
    
    [self.wordsCollectionView setCollectionViewLayout:viewFlowLayout];
}

- (void)bindWithWords:(nonnull NSArray *)words {
    DDLogVerbose(@"%@ bindWithWords: %@", LOG_TAG, words);
    
    self.words = words;
    
    if (!self.words) {
        self.wordsCollectionViewHeightConstraint.constant = 0;
    } else {
        self.wordsCollectionViewHeightConstraint.constant = self.words.count * 0.5 * DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    [self.wordsCollectionView reloadData];
    
    [self updateColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.words.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH * 0.5f, DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    BackupWordCell *backupWordCell = [collectionView dequeueReusableCellWithReuseIdentifier:BACKUP_WORD_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIBackupWord *backupWord = self.words[indexPath.row];
    [backupWordCell bind:backupWord];
    
    return backupWordCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.wordsCollectionView.backgroundColor = Design.WHITE_COLOR;
}


@end
