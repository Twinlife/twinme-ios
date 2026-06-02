/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLMessage.h>

#import "PeerPollItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "PollChoiceCell.h"
#import "PeerPollItem.h"
#import "UIPollResult.h"
#import "ConversationViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#import "CustomAppearance.h"
#import "DecoratedLabel.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif


static const CGFloat DESIGN_CHOICE_HEIGHT = 80;
static const CGFloat DESIGN_AVATAR_RIGHT_MARGIN = 18;

static UIColor *DESIGN_SHADOW_COLOR;

static NSString *POLL_CHOICE_CELL_IDENTIFIER = @"PollChoiceCellIdentifier";
static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: PeerPollItemCell ()
//

@interface PeerPollItemCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentPollViewLeadingConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (weak, nonatomic) UIFont *messageFont;
@property (nonatomic) CGFloat avatarHeightConstraintValue;

@property (nonatomic) TLPollDescriptor *pollDescriptor;
@property (nonatomic) NSMutableArray *pollResults;

@property (nonatomic) CustomAppearance *customAppearance;

@end

//
// Implementation: PeerPollItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerPollItemCell"

@implementation PeerPollItemCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_SHADOW_COLOR = [UIColor colorWithRed:210./255. green:210./255. blue:210./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.messageFont = Design.FONT_REGULAR34;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    tapContentGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;

    // Keep the value because sometimes we are going to erase it.
    self.avatarHeightConstraintValue = self.avatarViewHeightConstraint.constant;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentPollViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentPollViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentPollViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentPollViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentPollViewLeadingConstraint.constant = self.avatarViewLeadingConstraint.constant + self.avatarViewHeightConstraint.constant + DESIGN_AVATAR_RIGHT_MARGIN * Design.HEIGHT_RATIO;
    
    self.contentPollView.backgroundColor = Design.GREY_ITEM;
        
    self.questionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.questionLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.questionLabel.textColor = Design.FONT_COLOR_DEFAULT;
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
    self.resultLabel.textColor = Design.FONT_COLOR_DEFAULT;
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
    [resultTapContentGesture requireGestureRecognizerToFail:longPressGesture];
    [tapContentGesture requireGestureRecognizerToFail:longPressGesture];
    
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
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.customAppearance = [conversationViewController getCustomAppearance];
    
    [self.contentPollView setBackgroundColor:[self.customAppearance getPeerMessageBackgroundColor]];
    self.questionLabel.textColor = [self.customAppearance getPeerMessageTextColor];
    self.resultLabel.textColor = [self.customAppearance getPeerMessageTextColor];
    self.messageFont = [conversationViewController getMessageFont];

    PeerPollItem *peerPollItem = (PeerPollItem *)item;
    self.pollDescriptor = peerPollItem.pollDescriptor;
    self.pollResults = [self getPollResults:conversationViewController votes:peerPollItem.votes];
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:peerPollItem.corners & ITEM_TOP_LEFT item:item];
    self.contentPollViewTopConstraint.constant = topMargin;
    self.contentPollViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerPollItem.corners & ITEM_BOTTOM_LEFT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded || [item isEditedtem]) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    self.questionLabel.text = self.pollDescriptor.question;
    self.choicesTableViewHeightConstraint.constant = self.pollDescriptor.choices.count * roundf(DESIGN_CHOICE_HEIGHT * Design.HEIGHT_RATIO);
    [self.choicesTableView reloadData];
    
    int corners = peerPollItem.corners;
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
    
    if (peerPollItem.visibleAvatar && [conversationViewController displayPeerItemAvatar]) {
        self.avatarView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
        self.avatarView.hidden = NO;
        self.avatarViewHeightConstraint.constant = self.avatarHeightConstraintValue;
    } else {
        self.avatarViewHeightConstraint.constant = 0;
        self.avatarView.hidden = YES;
        self.avatarView.image = nil;
        
        if (![conversationViewController displayPeerItemAvatar]) {
            if ([conversationViewController isSelectItemMode]) {
                self.contentPollViewLeadingConstraint.constant = self.checkMarkViewLeadingConstraint.constant + self.checkMarkViewLeadingConstraint.constant + Design.AVATAR_CONVERSATION_LEADING;
            } else {
                self.contentPollViewLeadingConstraint.constant = Design.AVATAR_CONVERSATION_LEADING;
            }            
        }
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
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    if (self.isSelectItemMode) {
        self.avatarView.hidden = YES;
    }
    
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
        
    return roundf(DESIGN_CHOICE_HEIGHT * Design.HEIGHT_RATIO);
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
    [cell bindWithPollResult:pollResult textColor:[self.customAppearance getPeerMessageTextColor]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    TLChoice *choice = [self.pollDescriptor.choices objectAtIndex:indexPath.row];
    PeerPollItem *peerPollItem = (PeerPollItem *)self.item;
    if ([self.pollActionDelegate respondsToSelector:@selector(selectChoice:pollDescriptor:votes:)]) {
        [self.pollActionDelegate selectChoice:choice pollDescriptor:self.pollDescriptor votes:peerPollItem.votes];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
        
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (section == 0) {
        return self.item.forwarded ? 1 : 0;
    } else if (section == 1) {
        return [self.item isEditedtem] ? 1 : 0;
    }
    return self.item.likeDescriptorAnnotations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (indexPath.section < 2) {
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
    
    if (indexPath.section < 2) {
        AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];

        if (indexPath.section == 0) {
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
            [annotationCell bindWithAnnotation:descriptorAnnotation.annotation descriptorId:self.item.descriptorId isPeerItem:YES];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation.annotation count:descriptorAnnotation.count descriptorId:self.item.descriptorId isPeerItem:YES];
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

#pragma mark - Private methods

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

#pragma - mark UIView(UIViewRendering)

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
    return pollResults;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
