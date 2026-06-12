/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "PollItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "PollItem.h"
#import "PollChoiceCell.h"
#import "ConversationViewController.h"
#import "UIPollResult.h"

#import <TwinmeCommon/Design.h>

#import "CustomAppearance.h"
#import "DecoratedLabel.h"
#import "EphemeralView.h"
#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *POLL_CHOICE_CELL_IDENTIFIER = @"PollChoiceCellIdentifier";
static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

static const CGFloat DESIGN_CHOICE_HEIGHT = 80;

//
// Interface: PollItemCell ()
//

@interface PollItemCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentPollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choicesTableViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choicesTableViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choicesTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choicesTableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *choicesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UIView *contentDeleteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewTrailinConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;

@property (weak, nonatomic) UIFont *messageFont;

@property (nonatomic) TLPollDescriptor *pollDescriptor;
@property (nonatomic) NSMutableArray *pollResults;
@property (nonatomic) int maxResult;

@property (nonatomic) CustomAppearance *customAppearance;

@end

//
// Implementation: PollItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PollItemCell"

@implementation PollItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.isDeleteAnimationStarted = NO;
    self.maxResult = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.messageFont = Design.FONT_REGULAR34;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    tapContentGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.contentPollViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentPollViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentPollViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentPollViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    [self.contentDeleteView setBackgroundColor:Design.DELETE_COLOR_RED];
    self.contentDeleteView.hidden = YES;
    
    self.questionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.questionLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.questionLabel.textColor = [UIColor whiteColor];
    self.questionLabel.font = self.messageFont;
    
    self.choicesTableViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.choicesTableViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.choicesTableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.choicesTableViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.choicesTableView.delegate = self;
    self.choicesTableView.dataSource = self;
    self.choicesTableView.scrollEnabled = NO;
    self.choicesTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.choicesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.choicesTableView.backgroundColor = [UIColor clearColor];
    [self.choicesTableView registerNib:[UINib nibWithNibName:@"PollChoiceCell" bundle:nil] forCellReuseIdentifier:POLL_CHOICE_CELL_IDENTIFIER];
    
    self.resultLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.resultLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.resultLabel.textColor = [UIColor whiteColor];
    self.resultLabel.font = self.messageFont;
    self.resultLabel.text = TwinmeLocalizedString(@"poll_view_results", nil);
    
    self.resultViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.resultView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *resultTapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapResultView:)];
    resultTapContentGesture.cancelsTouchesInView = NO;
    [self.resultView addGestureRecognizer:resultTapContentGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentPollView addGestureRecognizer:longPressGesture];
    [tapContentGesture requireGestureRecognizerToFail:longPressGesture];
    [resultTapContentGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.annotationCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationCollectionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.ANNOTATION_CELL_WIDTH_NORMAL, self.annotationCollectionViewHeightConstraint.constant)];
    
    [self.annotationCollectionView setCollectionViewLayout:viewFlowLayout];
    self.annotationCollectionView.dataSource = self;
    self.annotationCollectionView.delegate = self;
    self.annotationCollectionView.backgroundColor = [UIColor clearColor];
    [self.annotationCollectionView registerNib:[UINib nibWithNibName:@"AnnotationCell" bundle:nil] forCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER];
    [self.annotationCollectionView registerNib:[UINib nibWithNibName:@"AnnotationCountCell" bundle:nil] forCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER];
    
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageView.layer.cornerRadius = self.stateImageViewHeightConstraint.constant * 0.5;
    self.stateImageView.clipsToBounds = YES;
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
         
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkView.clipsToBounds = YES;
    self.checkMarkView.hidden = YES;
    self.checkMarkView.backgroundColor = [UIColor whiteColor];
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    self.infoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.infoImageViewTrailinConstraint.constant *= Design.WIDTH_RATIO;
    
    self.infoImageView.hidden = YES;
    self.infoImageView.userInteractionEnabled = YES;
    self.infoImageView.tintColor = [UIColor orangeColor];
    
    UITapGestureRecognizer *infoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInfoTapGestureRecognizer:)];
    
    [self.infoImageView addGestureRecognizer:infoTapGesture];
    [infoTapGesture requireGestureRecognizerToFail:longPressGesture];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
        
    self.stateImageView.image = nil;
    self.contentDeleteView.hidden = YES;
    self.isDeleteAnimationStarted = NO;
    self.checkMarkView.hidden = YES;
    self.infoImageView.hidden = YES;
    [self.contentDeleteView.layer removeAllAnimations];
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.messageFont = [conversationViewController getMessageFont];
    self.customAppearance = [conversationViewController getCustomAppearance];
    
    [self.contentPollView setBackgroundColor:[self.customAppearance getMessageBackgroundColor]];
    self.questionLabel.textColor = [self.customAppearance getMessageTextColor];
    self.resultLabel.textColor = [self.customAppearance getMessageTextColor];
    
    PollItem *pollItem = (PollItem *)item;
    self.pollDescriptor = pollItem.pollDescriptor;
    self.pollResults = [self getPollResults:conversationViewController votes:pollItem.votes];
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:pollItem.corners & ITEM_TOP_RIGHT item:item];
    self.contentPollViewTopConstraint.constant = topMargin;
    self.contentPollViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:pollItem.corners & ITEM_BOTTOM_RIGHT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded || [item isEditedtem]) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    self.contentDeleteView.hidden = YES;
    
    self.stateImageView.backgroundColor = [UIColor clearColor];
    self.infoImageView.hidden = YES;
    
    self.questionLabel.text = self.pollDescriptor.question;
    
    CGFloat choicesHeight = 0;
    for (UIPollResult *pollResult in self.pollResults) {
        CGFloat choiceHeight = [PollChoiceCell cellHeightForChoice:pollResult.choiceHeight];
        choicesHeight = choicesHeight + choiceHeight;
    }
    
    self.choicesTableViewHeightConstraint.constant = choicesHeight;
    [self.choicesTableView reloadData];

    int corners = pollItem.corners;
    
    switch (pollItem.state) {
        case ItemStateDefault:
            self.stateImageView.hidden = YES;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = nil;
            break;
            
        case ItemStateSending:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateSending"];
            break;
            
        case ItemStateReceived:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateReceived"];
            break;
            
        case ItemStateRead:
        case ItemStatePeerDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[pollItem peerTwincodeOutboundId]];
            
            if ([self.stateImageView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
                self.stateImageView.backgroundColor = Design.GREY_ITEM;
            }
            
            break;
            
        case ItemStateNotSent:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateNotSent"];
            
            if (self.item.errorAnnotation && !self.isSelectItemMode) {
                self.infoImageView.hidden = NO;
            }
            
            break;
            
        case ItemStateDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            [self startStateImageAnimation];
            break;
            
        case ItemStateBothDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            self.contentDeleteView.hidden = NO;
            if (self.item.deleteProgress == 0) {
                [self.item startDeleteItem];
            }
            [self startDeleteAnimation];
            break;
    }
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.topLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.topRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.bottomRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
        self.bottomLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
    } else {
        self.topLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.topRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.bottomRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
        self.bottomLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
    }
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.contentPollView];
            [self.contentView bringSubviewToFront:self.annotationCollectionView];
        }
    } else {
        self.overlayView.hidden = YES;
        [self.contentView bringSubviewToFront:self.contentDeleteView];
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self updateFont];
    [self updateColor];
    [self setNeedsDisplay];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
        
    UIPollResult *pollResult = [self.pollResults objectAtIndex:indexPath.row];
    return [PollChoiceCell cellHeightForChoice:pollResult.choiceHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.pollDescriptor.choices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    PollChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:POLL_CHOICE_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[PollChoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:POLL_CHOICE_CELL_IDENTIFIER];
    }
        
    UIPollResult *pollResult = [self.pollResults objectAtIndex:indexPath.row];
    [cell bindWithPollResult:pollResult textColor:[self.customAppearance getMessageTextColor] maxResult:self.maxResult];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    TLChoice *choice = [self.pollDescriptor.choices objectAtIndex:indexPath.row];
    PollItem *pollItem = (PollItem *)self.item;
    if ([self.pollActionDelegate respondsToSelector:@selector(selectChoice:pollDescriptor:votes:)]) {
        [self.pollActionDelegate selectChoice:choice pollDescriptor:self.pollDescriptor votes:pollItem.votes];
    }
}

- (void)onTapResultView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTapResultView", LOG_TAG);
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if ([self.pollActionDelegate respondsToSelector:@selector(resultsPoll:)]) {
            [self.pollActionDelegate resultsPoll:self.pollDescriptor];
        }
    }
}

- (void)startDeleteAnimation {
    DDLogVerbose(@"%@ startDeleteAnimation", LOG_TAG);
    
    if (self.isDeleteAnimationStarted) {
        return;
    }
    
    self.isDeleteAnimationStarted = YES;
    
    CGFloat initialWidth = 0;
    CGFloat animationDuration = DESIGN_DELETE_ANIMATION_DURATION;
    if (self.item.deleteProgress > 0) {
        initialWidth = (self.item.deleteProgress * self.contentPollView.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentPollView.frame.size.width;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentDeleteView.frame = contentDeleteFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
                [self.deleteActionDelegate deleteItem:self.item];
            }
        }
    }];
}

- (void)startStateImageAnimation {
    DDLogVerbose(@"%@ startStateImageAnimation", LOG_TAG);
    
    self.stateImageView.hidden = NO;
    [self.stateImageView.layer removeAllAnimations];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 0.5;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.stateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)deleteEphemeralItem {
    DDLogVerbose(@"%@ deleteEphemeralItem", LOG_TAG);
    
    if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
        
        [self.deleteActionDelegate deleteItem:self.item];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
        
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (section == 1) {
        return self.item.forwarded ? 1 : 0;
    } else if (section == 2) {
        return [self.item isEditedtem] ? 1 : 0;
    }
    
    return self.item.likeDescriptorAnnotations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (indexPath.section != 0) {
        return CGSizeMake(Design.ANNOTATION_CELL_WIDTH_NORMAL, self.annotationCollectionViewHeightConstraint.constant);
    }

    if (indexPath.row < self.item.likeDescriptorAnnotations.count) {
        AnnotationWithCount *annotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        return CGSizeMake([self annotationWidth:annotation], self.annotationCollectionViewHeightConstraint.constant);
    }
    
    return CGSizeZero;
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
    
    if (indexPath.section != 0) {
        AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];

        if (indexPath.section == 1) {
            [annotationCell bindWithForwardedAnnotation:NO];
        } else {
            [annotationCell bindWithUpdatedAnnotation:NO];
        }
        
        return annotationCell;
    } else {
        AnnotationWithCount *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        if (descriptorAnnotation.count == 1) {
            AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCell.annotationActionDelegate = self;
            [annotationCell bindWithAnnotation:descriptorAnnotation.annotation descriptorId:self.item.descriptorId isPeerItem:NO];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation.annotation count:descriptorAnnotation.count descriptorId:self.item.descriptorId isPeerItem:NO];
            return annotationCountCell;
        }
    }
}

#pragma mark - AnnotationActionDelegate

- (void)didTapAnnotation:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ didTapAnnotation: %@", LOG_TAG, descriptorId);
    
    if ([self.reactionViewDelegate respondsToSelector:@selector(openAnnotationViewWithDescriptorId:)]) {
        [self.reactionViewDelegate openAnnotationViewWithDescriptorId:self.item.descriptorId];
    }
}

#pragma mark - IBActions

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    DDLogVerbose(@"%@ onLongPressInsideContent: %@", LOG_TAG, longPressGesture);
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan && [self.menuActionDelegate respondsToSelector:@selector(openMenu:)]) {
        [self.menuActionDelegate openMenu:self.item];
    }
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
    } else {
        if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
            [self.menuActionDelegate closeMenu];
        }
    }
}

- (void)onTouchUpReplyView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpReplyView: %@", LOG_TAG, tapGesture);
    
    if ([self.replyItemDelegate respondsToSelector:@selector(didSelectReplyTo:)]) {
        [self.replyItemDelegate didSelectReplyTo:self.item.replyTo];
    }
}

- (void)handleInfoTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ handleInfoTapGestureRecognizer: %@", LOG_TAG, tapGesture);
    
    if ([self.infoItemDelegate respondsToSelector:@selector(didTapInfoItem:)]) {
        [self.infoItemDelegate didTapInfoItem:self.item];
    }
}

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentPollView.bounds.size.width;
    CGFloat height = self.contentPollView.bounds.size.height;
    CGFloat radius = MIN(width / 2, height / 2);
    CGFloat topLeftRadius = MIN(self.topLeftRadius, radius);
    CGFloat topRightRadius = MIN(self.topRightRadius, radius);
    CGFloat bottomRightRadius = MIN(self.bottomRightRadius, radius);
    CGFloat bottomLeftRadius = MIN(self.bottomLeftRadius, radius);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeftRadius, 0)];
    [path addLineToPoint:CGPointMake(width - topRightRadius, 0)];
    [path addArcWithCenter:CGPointMake(width - topRightRadius, topRightRadius) radius:topRightRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(width - bottomRightRadius, height - bottomRightRadius) radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeftRadius, height)];
    [path addArcWithCenter:CGPointMake(bottomLeftRadius, height - bottomLeftRadius) radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeftRadius)];
    [path addArcWithCenter:CGPointMake(topLeftRadius, topLeftRadius) radius:topLeftRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.contentPollView.layer.masksToBounds = YES;
    self.contentPollView.layer.mask = mask;
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
    self.contentDeleteView.layer.mask = maskDelete;
}

- (NSMutableArray<UIPollResult *> *)getPollResults:(ConversationViewController *)conversationViewController votes:(NSDictionary<NSUUID *, NSArray<TLChoice *> *> *)votes {
    DDLogVerbose(@"%@ getPollResults", LOG_TAG);
    
    NSMutableArray<UIPollResult *> *pollResults = [[NSMutableArray alloc] init];

    NSArray<TLChoice *> *choices = self.pollDescriptor.choices;
    for (TLChoice *choice in choices) {
        [pollResults addObject:[[UIPollResult alloc] initWithChoice:choice]];
    }
    
    for (NSUUID *twincodeOutboundId in votes) {
        NSArray<TLChoice *> *userVotes = votes[twincodeOutboundId];

        for (TLChoice *userVote in userVotes) {
            for (UIPollResult *pollResult in pollResults) {
                if ([pollResult.choice isEqual:userVote]) {
                    pollResult.count = pollResult.count + 1;

                    if (pollResult.voters.count < 2) {
                        UIImage *avatar = [conversationViewController getPollAvatarWithUUID:twincodeOutboundId];
                        if (avatar != nil) {
                            [pollResult.voters addObject:avatar];
                        }
                    }
                    
                    if ([conversationViewController isUserVote:twincodeOutboundId]) {
                        pollResult.isSelected = YES;
                    }
                }
            }
        }
    }
    
    self.maxResult = 0;
    CGFloat maxWidth = [PollChoiceCell maxChoiceWidth:self.contentPollViewWidthConstraint.constant - self.choicesTableViewLeadingConstraint.constant *2];
    for (UIPollResult *pollResult in pollResults) {
        [pollResult calculateChoiceHeightWithMaxWidth:maxWidth font:Design.FONT_MEDIUM32];
        if (pollResult.count > self.maxResult) {
            self.maxResult = pollResult.count;
        }
    }
    
    return pollResults;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.questionLabel.font = self.messageFont;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
