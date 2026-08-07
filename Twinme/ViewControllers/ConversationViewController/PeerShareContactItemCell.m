/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLGetTwincodeAction.h>
#import <Twinme/TLTwinmeAttributes.h>
#import <Twinlife/TLImageService.h>

#import "PeerShareContactItemCell.h"

#import <Utils/NSString+Utils.h>

#import "ConversationViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import "PeerShareContactItem.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_AVATAR_LEADING = 36;
static const CGFloat DESIGN_ACTION_HEIGHT = 60;

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: PeerShareContactItemCell ()
//

@interface PeerShareContactItemCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentShareViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentShareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAvatarImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftAvatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAvatarImageViewHeightConstraint;
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
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) CGFloat avatarHeightConstraintValue;
@property (nonatomic) CAShapeLayer *lineLeftDashLayer;
@property (nonatomic) CAShapeLayer *lineRightDashLayer;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;

@property (nonatomic) TLContactShareDescriptor *contactShareDescriptor;
@property (nonatomic) TLTwincodeDescriptor *twincodeDescriptor;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;
@property (nonatomic, nullable) TLGetTwincodeAction *twincodeAction;


@end

//
// Implementation: PeerShareContactItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerClearItemCell"

@implementation PeerShareContactItemCell

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
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;

    // Keep the value because sometimes we are going to erase it.
    self.avatarHeightConstraintValue = self.avatarViewHeightConstraint.constant;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentShareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentShareViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentShareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentShareViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideShareContactView:)];
    [self.contentShareView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentShareView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.leftAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftAvatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftAvatarImageView.clipsToBounds = YES;
    self.leftAvatarImageView.layer.cornerRadius = self.leftAvatarImageViewHeightConstraint.constant * 0.5f;
    self.leftAvatarImageView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    self.leftAvatarImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.rightAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightAvatarImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.rightAvatarImageView.clipsToBounds = YES;
    self.rightAvatarImageView.layer.cornerRadius = self.rightAvatarImageViewHeightConstraint.constant * 0.5f;
    self.rightAvatarImageView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    self.rightAvatarImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.lineLeftViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineLeftView.backgroundColor = [UIColor clearColor];
    
    self.lineRightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lineRightView.backgroundColor = [UIColor clearColor];
    
    self.iconRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.iconRoundedView.backgroundColor = Design.GREY_ITEM;
    self.iconRoundedView.clipsToBounds = YES;
    self.iconRoundedView.layer.cornerRadius = self.iconRoundedViewHeightConstraint.constant * 0.5f;
    self.iconRoundedView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    self.iconRoundedView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.iconImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconImageView.image =  [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconImageView.tintColor = Design.FONT_COLOR_GREY;
    
    self.shareContactStatusImageView.hidden = YES;
    self.shareContactStatusImageView.clipsToBounds = YES;
    self.shareContactStatusImageView.layer.cornerRadius = self.iconRoundedViewHeightConstraint.constant * 0.5f;
    self.shareContactStatusImageView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    self.shareContactStatusImageView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.actionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.actionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionLabel.font = Design.FONT_MEDIUM34;
    self.actionLabel.textColor = [UIColor whiteColor];
    self.actionLabel.text = TwinmeLocalizedString(@"conversation_view_menu_item_view_reply_title", nil);
    
    self.actionViewViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.actionViewViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.actionView.backgroundColor = Design.FONT_COLOR_GREY;
    self.actionView.clipsToBounds = YES;
    self.actionView.layer.cornerRadius = self.actionViewViewHeightConstraint.constant * 0.5f;
    self.actionView.hidden = YES;
    
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
    
    // Cancel the twincode action if it was not finished: we will display another content.
    if (self.twincodeAction) {
        [self.twincodeAction cancel];
        self.twincodeAction = nil;
    }
    
    self.contactShareDescriptor = nil;
    self.twincodeDescriptor = nil;
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
    self.lineLeftDashLayer.strokeColor = Design.FONT_COLOR_GREY.CGColor;
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
    self.lineRightDashLayer.strokeColor = Design.FONT_COLOR_GREY.CGColor;
    self.lineRightDashLayer.fillColor = nil;
    self.lineRightDashLayer.lineWidth = self.lineRightViewHeightConstraint.constant;
    self.lineRightDashLayer.lineCap = kCALineCapRound;
    self.lineRightDashLayer.lineDashPattern = lineDashPattern;
    
    [self.lineRightView.layer addSublayer:self.lineRightDashLayer];
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
    
}

#pragma mark - TLGetTwincodeAction

- (void)onGetTwincodeActionWithErrorCode:(TLBaseServiceErrorCode)errorCode name:(nullable NSString *)name avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeActionWithErrorCode: %d name: %@ avatar: %@", LOG_TAG, errorCode, name, avatar);

    self.twincodeAction = nil;

    if (errorCode != TLBaseServiceErrorCodeSuccess || !name) {
        self.messageLabel.text = @"";
        
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

    self.rightAvatarImageView.image = avatar;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_peer_message", nil), name];
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
        
    PeerShareContactItem *peerShareContactItem = (PeerShareContactItem *)item;
    
    if (peerShareContactItem.contactShareDescriptor) {
        self.contactShareDescriptor = peerShareContactItem.contactShareDescriptor;
    } else if (peerShareContactItem.twincodeDescriptor) {
        self.twincodeDescriptor = peerShareContactItem.twincodeDescriptor;
    }
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:peerShareContactItem.corners & ITEM_TOP_LEFT item:item];
    self.contentShareViewTopConstraint.constant = topMargin;
    self.contentShareViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerShareContactItem.corners & ITEM_BOTTOM_LEFT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded || [item isEditedtem]) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    if (peerShareContactItem.contactShareDescriptor) {
        BOOL hideStatus = NO;
        NSString *message = @"";
        switch (peerShareContactItem.contactShareDescriptor.status) {
            case TLInvitationDescriptorStatusTypePending:
                hideStatus = YES;
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_peer_message", nil), peerShareContactItem.contactShareDescriptor.name];
                self.shareContactStatusImageView.hidden = YES;
                break;
                
            case TLInvitationDescriptorStatusTypeAccepted:
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_pending_acceptance", nil), peerShareContactItem.contactShareDescriptor.name];
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStateAccepted"];
                break;
                
            case TLInvitationDescriptorStatusTypeJoined:
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_accept_connection", nil), peerShareContactItem.contactShareDescriptor.name];
                self.shareContactStatusImageView.hidden = NO;
                self.shareContactStatusImageView.image = [UIImage imageNamed:@"InvitationStateJoined"];
                break;
                
            case TLInvitationDescriptorStatusTypeRefused:
                
                if (peerShareContactItem.contactShareDescriptor.autoAnswer) {
                    message = TwinmeLocalizedString(@"conversation_view_share_contact_item_automatic_decline", nil);
                } else {
                    message = TwinmeLocalizedString(@"conversation_view_share_contact_item_decline_connection", nil);
                }
                
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
                
        if (hideStatus) {
            self.actionView.hidden = NO;
            self.actionViewViewHeightConstraint.constant = Design.HEIGHT_RATIO * DESIGN_ACTION_HEIGHT;
            self.messageLabel.hidden = NO;
            self.messageLabel.font = Design.FONT_MEDIUM32;
            self.messageLabel.textColor =  Design.FONT_COLOR_DEFAULT;
            self.messageLabel.text = message;
        } else {
            self.actionView.hidden = YES;
            self.actionViewViewHeightConstraint.constant = 0;
            self.messageLabel.hidden = NO;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_peer_message", nil), peerShareContactItem.contactShareDescriptor.name] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:message attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
            self.messageLabel.attributedText = attributedString;
        }
        
        [self.twinmeContext getContactShareAvatarWithDescriptor:peerShareContactItem.contactShareDescriptor withBlock:^(UIImage * _Nullable avatar) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rightAvatarImageView.image = avatar;
            });
        }];
    } else if (peerShareContactItem.twincodeDescriptor) {
        self.actionView.hidden = NO;
        self.actionViewViewHeightConstraint.constant = Design.HEIGHT_RATIO * DESIGN_ACTION_HEIGHT;
        self.messageLabel.font = Design.FONT_MEDIUM32;
        self.messageLabel.textColor =  Design.FONT_COLOR_DEFAULT;
        self.messageLabel.hidden = NO;
        self.shareContactStatusImageView.hidden = YES;
        
        self.twincodeAction = [[TLGetTwincodeAction alloc] initWithTwinmeContext:self.twinmeContext twincodeOutboundId:self.twincodeDescriptor.twincodeId withBlock:^(TLBaseServiceErrorCode errorCode, NSString *name, UIImage *avatar) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onGetTwincodeActionWithErrorCode:errorCode name:name avatar:avatar];
                [conversationViewController updateTableView];
            });
        }];
        [self.twincodeAction start];
    }
    
    self.leftAvatarImageView.image = [conversationViewController getIdentityAvatar];
        
    int corners = peerShareContactItem.corners;
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
    
    if (peerShareContactItem.visibleAvatar && [conversationViewController displayPeerItemAvatar]) {
        self.avatarView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
        self.avatarView.hidden = NO;
        self.avatarViewHeightConstraint.constant = self.avatarHeightConstraintValue;
    } else {
        self.avatarViewHeightConstraint.constant = 0;
        self.avatarView.hidden = YES;
        self.avatarView.image = nil;
        
        if (![conversationViewController displayPeerItemAvatar]) {
            if ([conversationViewController isSelectItemMode]) {
                self.contentShareViewLeadingConstraint.constant = self.checkMarkViewLeadingConstraint.constant + self.checkMarkViewLeadingConstraint.constant + Design.AVATAR_CONVERSATION_LEADING;
            } else {
                self.contentShareViewLeadingConstraint.constant = Design.AVATAR_CONVERSATION_LEADING;
            }
        }
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
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    if (self.isSelectItemMode) {
        self.avatarView.hidden = YES;
    }
    
    [self updateFont];
    [self updateColor];
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

#pragma mark - IBActions

- (void)onTouchUpInsideShareContactView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideShareContactView: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (self.contactShareDescriptor) {
        if (![self.item isDeletedItem] && [self.shareContactActionDelegate respondsToSelector:@selector(openShareContactDescriptor:)]) {
            [self.shareContactActionDelegate openShareContactDescriptor:self.contactShareDescriptor];
        }
    } else if (self.twincodeDescriptor) {
        if (![self.item isDeletedItem] && [self.shareContactActionDelegate respondsToSelector:@selector(openTwincodeDescriptorFromShareContact:)]) {
            [self.shareContactActionDelegate openTwincodeDescriptorFromShareContact:self.twincodeDescriptor];
        }
    }
}


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
        return;
    } else {
        if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
            [self.menuActionDelegate closeMenu];
        }
    }
}

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
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.actionLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
 
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    self.contentShareView.backgroundColor = Design.GREY_ITEM;
    self.iconRoundedView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    self.actionView.backgroundColor = Design.FONT_COLOR_GREY;
}

@end
