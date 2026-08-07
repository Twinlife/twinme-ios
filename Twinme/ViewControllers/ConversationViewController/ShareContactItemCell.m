/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ShareContactItemCell.h"

#import <Twinme/TLContact.h>
#import <Twinme/TLGetTwincodeAction.h>
#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLTwinmeContext.h>

#import <Twinlife/TLImageService.h>

#import <Utils/NSString+Utils.h>

#import "ConversationViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "ShareContactItem.h"
#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: ShareContactItemCell ()
//

@interface ShareContactItemCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentShareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftAvatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *rightAvatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineLeftView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineRightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *iconRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shareContactStatusImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *contentDeleteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
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
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;
@property (nonatomic) CAShapeLayer *lineLeftDashLayer;
@property (nonatomic) CAShapeLayer *lineRightDashLayer;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;

@property (nonatomic, nullable) TLGetTwincodeAction *twincodeAction;

@end

//
// Implementation: ShareContactItemCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareContactItemCell"

@implementation ShareContactItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    _twinmeApplication = [delegate twinmeApplication];
    _twinmeContext = [delegate twinmeContext];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentView addGestureRecognizer:longPressGesture];
    [tapContentGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.contentShareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentShareViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentShareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentShareViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftAvatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.leftAvatarImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftAvatarImageView.clipsToBounds = YES;
    self.leftAvatarImageView.layer.cornerRadius = self.leftAvatarImageViewHeightConstraint.constant * 0.5f;
    self.leftAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.leftAvatarImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.rightAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightAvatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.rightAvatarImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.rightAvatarImageView.clipsToBounds = YES;
    self.rightAvatarImageView.layer.cornerRadius = self.rightAvatarImageViewHeightConstraint.constant * 0.5f;
    self.rightAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.rightAvatarImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.lineLeftViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineLeftView.backgroundColor = [UIColor clearColor];
    
    self.lineRightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineRightView.backgroundColor = [UIColor clearColor];
    
    self.iconRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.iconRoundedView.backgroundColor = Design.GREY_ITEM;
    self.iconRoundedView.clipsToBounds = YES;
    self.iconRoundedView.layer.cornerRadius = self.iconRoundedViewHeightConstraint.constant * 0.5f;
    self.iconRoundedView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconRoundedView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.iconImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconImageView.image =  [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconImageView.tintColor = Design.FONT_COLOR_GREY;
    
    self.shareContactStatusImageView.hidden = YES;
    self.shareContactStatusImageView.clipsToBounds = YES;
    self.shareContactStatusImageView.layer.cornerRadius = self.iconRoundedViewHeightConstraint.constant * 0.5f;
    self.shareContactStatusImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.shareContactStatusImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM32;
    self.messageLabel.textColor = [UIColor whiteColor];
    
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
        
    [self.contentDeleteView setBackgroundColor:Design.DELETE_COLOR_RED];
    self.contentDeleteView.hidden = YES;
    
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

- (void)layoutSubviews {
    DDLogVerbose(@"%@ layoutSubviews", LOG_TAG);
    
    [super layoutSubviews];
    [self updateLineView];
}

- (void)updateLineView {
    DDLogVerbose(@"%@ updateLineView", LOG_TAG);
    
    if (CGRectIsEmpty(self.lineLeftView.bounds)) {
        return;
    }
    
    NSArray<NSNumber *> *lineDashPattern = @[
        @(Design.LINE_DASH_LONG_LENGTH),
        @(Design.LINE_DASH_SPACING),
        @(Design.LINE_DASH_SHORT_LENGTH),
        @(Design.LINE_DASH_SPACING)
    ];
    
    if (self.lineLeftDashLayer) {
        [self.lineLeftDashLayer removeFromSuperlayer];
    }
    
    if (self.lineRightDashLayer) {
        [self.lineRightDashLayer removeFromSuperlayer];
    }
    
    self.lineLeftDashLayer = [CAShapeLayer layer];
    self.lineLeftDashLayer.frame = self.lineLeftView.bounds;

    UIBezierPath *lineLeftPath = [UIBezierPath bezierPath];
    [lineLeftPath moveToPoint:CGPointMake(0, self.lineLeftView.bounds.size.height / 2.0)];
    [lineLeftPath addLineToPoint:CGPointMake(self.lineLeftView.bounds.size.width,
                                     self.lineLeftView.bounds.size.height / 2.0)];

    self.lineLeftDashLayer.path = lineLeftPath.CGPath;
    self.lineLeftDashLayer.strokeColor = UIColor.whiteColor.CGColor;
    self.lineLeftDashLayer.fillColor = nil;
    self.lineLeftDashLayer.lineWidth = self.lineLeftViewHeightConstraint.constant;
    self.lineLeftDashLayer.lineCap = kCALineCapRound;
    self.lineLeftDashLayer.lineDashPattern = lineDashPattern;
    
    [self.lineLeftView.layer addSublayer:self.lineLeftDashLayer];
    
    self.lineRightDashLayer = [CAShapeLayer layer];
    self.lineRightDashLayer.frame = self.lineRightView.bounds;
    
    UIBezierPath *lineRightPath = [UIBezierPath bezierPath];
    [lineRightPath moveToPoint:CGPointMake(self.lineRightView.bounds.size.width,
                                     self.lineRightView.bounds.size.height / 2.0)];
    [lineRightPath addLineToPoint:CGPointMake(0, self.lineRightView.bounds.size.height / 2.0)];

    self.lineRightDashLayer.path = lineRightPath.CGPath;
    self.lineRightDashLayer.strokeColor = UIColor.whiteColor.CGColor;
    self.lineRightDashLayer.fillColor = nil;
    self.lineRightDashLayer.lineWidth = self.lineRightViewHeightConstraint.constant;
    self.lineRightDashLayer.lineCap = kCALineCapRound;
    self.lineRightDashLayer.lineDashPattern = lineDashPattern;
    
    [self.lineRightView.layer addSublayer:self.lineRightDashLayer];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    // Cancel the twincode action if it was not finished: we will display another content.
    if (self.twincodeAction) {
        [self.twincodeAction cancel];
        self.twincodeAction = nil;
    }
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
    
}

#pragma mark - TLGetTwincodeAction

- (void)onGetTwincodeActionWithErrorCode:(TLBaseServiceErrorCode)errorCode name:(nullable NSString *)name avatar:(nullable UIImage *)avatar contactName:(NSString *)contactName {
    DDLogVerbose(@"%@ onGetTwincodeActionWithErrorCode: %d name: %@ avatar: %@", LOG_TAG, errorCode, name, avatar);

    self.twincodeAction = nil;
    
    if (errorCode != TLBaseServiceErrorCodeSuccess || !name) {
        if (errorCode == TLBaseServiceErrorCodeExpired) {
            if ([self.deleteActionDelegate respondsToSelector:@selector(deleteExpiredItem:)]) {
                [self.deleteActionDelegate deleteExpiredItem:self.item];
            }
        }
        return;
    }
    
    if (!avatar) {
        avatar = [TLTwinmeAttributes DEFAULT_AVATAR];
    }

    self.leftAvatarImageView.image = avatar;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_local_message", nil), name, contactName];
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    ShareContactItem *shareContactItem = (ShareContactItem *)item;
            
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:shareContactItem.corners & ITEM_TOP_RIGHT item:item];
    self.contentShareViewTopConstraint.constant = topMargin;
    self.contentShareViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:shareContactItem.corners & ITEM_BOTTOM_RIGHT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded || [item isEditedtem]) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    TLContact *contact = (TLContact *) [conversationViewController getOriginator];
    
    if (shareContactItem.contactShareDescriptor) {
        [self.twinmeContext getContactShareAvatarWithDescriptor:shareContactItem.contactShareDescriptor withBlock:^(UIImage * _Nullable avatar) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.leftAvatarImageView.image = avatar;
            });
        }];
        
        NSString *message = @"";
        switch (shareContactItem.contactShareDescriptor.status) {
            case TLInvitationDescriptorStatusTypePending:
                message = TwinmeLocalizedString(@"conversation_view_invitation_pending", nil);
                self.shareContactStatusImageView.hidden = YES;
                break;
                
            case TLInvitationDescriptorStatusTypeAccepted:
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_pending_acceptance", nil), shareContactItem.contactShareDescriptor.name];
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStatePending"];

                break;
                
            case TLInvitationDescriptorStatusTypeJoined:
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_invitation_item_accepted_invitation", nil), shareContactItem.contactShareDescriptor.name];
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStateJoined"];
                break;
                
            case TLInvitationDescriptorStatusTypeRefused:
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_decline_connection_by_peer", nil), contact.name];
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStateRefused"];
                break;
                
            case TLInvitationDescriptorStatusTypeWithdrawn:
                message = TwinmeLocalizedString(@"conversation_view_invitation_refused", nil);
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStateWithDrawn"];
                break;
                
            default:
                break;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_local_message", nil), shareContactItem.contactShareDescriptor.name, contact.name] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:message attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM30, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]]];
        self.messageLabel.attributedText = attributedString;
    } else if (shareContactItem.twincodeDescriptor && !self.twincodeAction) {
        self.shareContactStatusImageView.hidden = YES;
        
        NSUUID *twincodeOutboundId;
        if (shareContactItem.twincodeDescriptor.sendTo) {
            twincodeOutboundId = shareContactItem.twincodeDescriptor.sendTo;
        } else {
            twincodeOutboundId = shareContactItem.twincodeDescriptor.twincodeId;
        }

        self.twincodeAction = [[TLGetTwincodeAction alloc] initWithTwinmeContext:self.twinmeContext twincodeOutboundId:twincodeOutboundId withBlock:^(TLBaseServiceErrorCode errorCode, NSString *name, UIImage *avatar) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onGetTwincodeActionWithErrorCode:errorCode name:name avatar:avatar contactName:contact.name];
                [conversationViewController updateTableView];
            });
        }];
        [self.twincodeAction start];
        
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_local_message", nil), contact.name, @""];
    }
    
    self.rightAvatarImageView.image = [conversationViewController getContactAvatarWithUUID:nil];
    
    self.contentDeleteView.hidden = YES;
    
    self.stateImageView.backgroundColor = [UIColor clearColor];
    self.infoImageView.hidden = YES;
    
    int corners = shareContactItem.corners;
    
    switch (shareContactItem.state) {
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
            self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[shareContactItem peerTwincodeOutboundId]];
            
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
            [self.contentView bringSubviewToFront:self.contentShareView];
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

- (void)handleInfoTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ handleInfoTapGestureRecognizer: %@", LOG_TAG, tapGesture);
    
    if ([self.infoItemDelegate respondsToSelector:@selector(didTapInfoItem:)]) {
        [self.infoItemDelegate didTapInfoItem:self.item];
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
        initialWidth = (self.item.deleteProgress * self.contentShareView.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentShareView.frame.size.width;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
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
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 0.5;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.stateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentShareView.bounds.size.width;
    CGFloat height = self.contentShareView.bounds.size.height;
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
    self.contentShareView.layer.masksToBounds = YES;
    self.contentShareView.layer.mask = mask;
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
    self.contentDeleteView.layer.mask = maskDelete;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.contentShareView setBackgroundColor:Design.MAIN_COLOR];
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    self.iconRoundedView.backgroundColor = Design.GREY_ITEM;
    self.iconImageView.tintColor = Design.FONT_COLOR_GREY;
}

@end
