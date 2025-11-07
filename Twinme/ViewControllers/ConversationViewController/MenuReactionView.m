/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuReactionView.h"

#import "ReactionCell.h"

#import "UIReaction.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_COLLECTION_CELL_WIDTH = 76;
static const CGFloat DESIGN_MENU_VIEW_HEIGHT = 100;
static const CGFloat DESIGN_LEADING_MENU = 96;
static const CGFloat DESIGN_TRAILING_MENU = 52;

static NSString *REACTION_CELL_IDENTIFIER = @"ReactionCellIdentifier";

//
// Interface: MenuReactionView ()
//

@interface MenuReactionView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *reactionContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *reactionCollectionView;

@property (nonatomic) NSMutableArray *reactions;

@end

//
// Implementation: MenuReactionView
//

#undef LOG_TAG
#define LOG_TAG @"MenuReactionView"

@implementation MenuReactionView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    
    self.reactions = [[NSMutableArray alloc]init];
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)openMenu:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.reactionContainerViewWidthConstraint.constant = self.reactionCollectionViewLeadingConstraint.constant + self.reactionCollectionViewTrailingConstraint.constant + (self.reactions.count * (DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO));
    
    if (isPeerItem) {
        self.reactionContainerViewLeadingConstraint.constant = DESIGN_LEADING_MENU * Design.WIDTH_RATIO;
    } else {
        self.reactionContainerViewLeadingConstraint.constant = Design.DISPLAY_WIDTH - (self.reactionContainerViewWidthConstraint.constant + DESIGN_TRAILING_MENU * Design.WIDTH_RATIO);
    }
    
    [self updateColor];
    [self.reactionCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.reactions.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
        
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    return CGSizeMake(widthCell, self.reactionCollectionView.frame.size.height);
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
    
    ReactionCell *reactionCell = [collectionView dequeueReusableCellWithReuseIdentifier:REACTION_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIReaction *uiReaction = self.reactions[indexPath.row];
    [reactionCell bindWithReaction:uiReaction];
    
    return reactionCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
        
    if ([self.menuReactionDelegate respondsToSelector:@selector(selectReaction:)]) {
        UIReaction *uiReaction = self.reactions[indexPath.row];
        [self.menuReactionDelegate selectReaction:uiReaction];
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuReactionView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    [self addSubview:[objects objectAtIndex:0]];
        
    self.backgroundColor = [UIColor clearColor];
    
    self.reactionContainerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.reactionContainerViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.reactionContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.reactionContainerView.clipsToBounds = YES;
    self.reactionContainerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.reactionContainerView.backgroundColor = Design.MENU_REACTION_BACKGROUND_COLOR;
    
    self.reactionCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.reactionCollectionViewTrailingConstraint.constant *= Design.HEIGHT_RATIO;
        
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = round(self.reactionContainerViewHeightConstraint.constant);
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(widthCell, heightCell)];
    [self.reactionCollectionView setCollectionViewLayout:viewFlowLayout];
    
    self.reactionCollectionView.dataSource = self;
    self.reactionCollectionView.delegate = self;
    self.reactionCollectionView.backgroundColor = [UIColor clearColor];
    [self.reactionCollectionView registerNib:[UINib nibWithNibName:@"ReactionCell" bundle:nil] forCellWithReuseIdentifier:REACTION_CELL_IDENTIFIER];
    
    [self initReactions];
}
    
- (void)initReactions {
    DDLogVerbose(@"%@ initReactions", LOG_TAG);
    
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeLike image:[UIImage imageNamed:@"ReactionLike"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeUnlike image:[UIImage imageNamed:@"ReactionUnlike"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeLove image:[UIImage imageNamed:@"ReactionLove"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeCry image:[UIImage imageNamed:@"ReactionCry"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeHunger image:[UIImage imageNamed:@"ReactionHunger"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeSurprised image:[UIImage imageNamed:@"ReactionSurprised"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeScreaming image:[UIImage imageNamed:@"ReactionScreaming"]]];
    [self.reactions addObject:[[UIReaction alloc]initWithReaction:ReactionTypeFire image:[UIImage imageNamed:@"ReactionFire"]]];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.reactionContainerView.backgroundColor = Design.MENU_REACTION_BACKGROUND_COLOR;
}

@end
