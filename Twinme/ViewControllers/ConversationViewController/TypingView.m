/*
 *  Copyright (c) 2019-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>

#import "UIContact.h"
#import "TypingView.h"
#import "TypingAvatarCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *TYPING_AVATAR_CELL_IDENTIFIER = @"TypingAvatarCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 70;
static CGFloat DESIGN_BUBBLE_INTIAL_HEIGHT = 16;
static CGFloat ANIMATION_DURATION = 0.2;

//
// Interface: TypingView ()
//

@interface TypingView () <UICollectionViewDataSource, CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewLeadingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewWidthConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewHeightConstrain;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftRoundViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftRoundViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftRoundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleRoundViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleRoundViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *middleRoundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightRoundViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightRoundViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightRoundView;

@property (nonatomic) NSArray *typingOriginators;

@end

@implementation TypingView

//
// Implementation: TypingView
//

#undef LOG_TAG
#define LOG_TAG @"TypingView"

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TypingView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
        self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO);
        [self initViews];
    }
    return self;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super awakeFromNib];
    
    self.membersCollectionViewLeadingConstrain.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewWidthConstrain.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewHeightConstrain.constant = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.membersCollectionView setCollectionViewLayout:viewFlowLayout];
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.backgroundColor = [UIColor clearColor];
    [self.membersCollectionView registerNib:[UINib nibWithNibName:@"TypingAvatarCell" bundle:nil] forCellWithReuseIdentifier:TYPING_AVATAR_CELL_IDENTIFIER];
    
    self.typingOriginators = [[NSMutableArray alloc]init];
    
    self.leftRoundViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftRoundViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftRoundView.backgroundColor = Design.MAIN_COLOR;
    self.leftRoundView.clipsToBounds = YES;
    self.leftRoundView.layer.cornerRadius = self.leftRoundViewHeightConstraint.constant / 2.0;
    
    self.middleRoundViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.middleRoundViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.middleRoundView.backgroundColor = Design.MAIN_COLOR;
    self.middleRoundView.clipsToBounds = YES;
    self.middleRoundView.layer.cornerRadius = self.middleRoundViewHeightConstraint.constant / 2.0;
    
    self.rightRoundViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightRoundViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.rightRoundView.backgroundColor = Design.MAIN_COLOR;
    self.rightRoundView.clipsToBounds = YES;
    self.rightRoundView.layer.cornerRadius = self.rightRoundViewHeightConstraint.constant / 2.0;
}

-(void)animationBubble:(UIView *)bubbleView forKey:(NSString *)key {
    DDLogVerbose(@"%@ animationBubble: %@ key:%@", LOG_TAG, bubbleView, key);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animation setValue:key forKey:@"layer"];
    animation.delegate = self;
    animation.autoreverses = YES;
    animation.repeatCount = 1;
    animation.duration = ANIMATION_DURATION;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)];
    animation.removedOnCompletion = YES;
    [bubbleView.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    DDLogVerbose(@"%@ animationDidStop: %@ finished:%d", LOG_TAG, animation, finished);
    
    if (finished) {
        if ([[animation valueForKey:@"layer"] isEqualToString:@"left"]) {
            [self animationBubble:self.middleRoundView forKey:@"middle-left"];
        } else if ([[animation valueForKey:@"layer"] isEqualToString:@"middle-left"]) {
            [self animationBubble:self.rightRoundView forKey:@"right"];
        } else if ([[animation valueForKey:@"layer"] isEqualToString:@"right"]) {
            [self animationBubble:self.middleRoundView forKey:@"middle-right"];
        } else if ([[animation valueForKey:@"layer"] isEqualToString:@"middle-right"]) {
            [self animationBubble:self.leftRoundView forKey:@"left"];
        }
    }
}

- (void)setOriginators:(nonnull NSArray<UIImage *> *)originators {
    DDLogVerbose(@"%@ setOriginators: %@", LOG_TAG, originators);
    
    self.typingOriginators = originators;
    
    if (self.typingOriginators.count > 5) {
        self.membersCollectionViewWidthConstrain.constant = (DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO) * 5;
    } else {
        self.membersCollectionViewWidthConstrain.constant = (DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO) * self.typingOriginators.count;
    }
    
    [self.leftRoundView.layer removeAllAnimations];
    [self.middleRoundView.layer removeAllAnimations];
    [self.rightRoundView.layer removeAllAnimations];
    self.leftRoundViewHeightConstraint.constant = DESIGN_BUBBLE_INTIAL_HEIGHT * Design.HEIGHT_RATIO;
    self.middleRoundViewHeightConstraint.constant = DESIGN_BUBBLE_INTIAL_HEIGHT * Design.HEIGHT_RATIO;
    self.rightRoundViewHeightConstraint.constant = DESIGN_BUBBLE_INTIAL_HEIGHT * Design.HEIGHT_RATIO;
    [self animationBubble:self.leftRoundView forKey:@"left"];
    
    [self.membersCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.typingOriginators.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    return CGSizeMake(heightCell, heightCell);
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
    
    TypingAvatarCell *typingAvatarCell = [collectionView dequeueReusableCellWithReuseIdentifier:TYPING_AVATAR_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIImage *avatar = self.typingOriginators[indexPath.row];
    
    [typingAvatarCell bindWithAvatar:avatar];
    
    return typingAvatarCell;
}

@end
