/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGetTwincodeAction.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "PeerInvitationItemCell.h"

#import "ConversationViewController.h"
#import "PeerInvitationItem.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import "UIView+GradientBackgroundColor.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PeerInvitationItemCell ()
//

@interface PeerInvitationItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *contentInvitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *invitationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLInvitationDescriptor *invitationDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) CAShapeLayer *borderLayer;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;

@property (nonatomic) TLGroup *group;
@property (nonatomic, nullable) TLGetTwincodeAction *twincodeAction;

@end

//
// Implementation: PeerInvitationItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerInvitationItemCell"

@implementation PeerInvitationItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    _twinmeApplication = [delegate twinmeApplication];
    _twinmeContext = [delegate twinmeContext];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentInvitationView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentInvitationView setBackgroundColor:Design.GREY_ITEM];
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentInvitationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentInvitationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentInvitationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentInvitationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideInvitation:)];
    [self.contentInvitationView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentInvitationView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.invitationLabel.font = Design.FONT_REGULAR26;
    self.invitationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.invitationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.groupImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.groupImageViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.groupImageView.clipsToBounds = YES;
    self.groupImageView.layer.cornerRadius = self.groupImageViewHeightConstraint.constant * 0.5;
    
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

    self.invitationDescriptor = nil;
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    self.topLeftRadius = 0;
    self.topRightRadius = 0;
    self.bottomRightRadius = 0;
    self.bottomLeftRadius = 0;
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
}

#pragma mark - TLGetTwincodeAction

- (void)onGetTwincodeActionWithErrorCode:(TLBaseServiceErrorCode)errorCode name:(nullable NSString *)name avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeActionWithErrorCode: %d name: %@ avatar: %@", LOG_TAG, errorCode, name, avatar);

    self.twincodeAction = nil;

    if (!avatar) {
        avatar = [TLTwinmeAttributes DEFAULT_GROUP_AVATAR];
    }
    
    if ([self.groupImageView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.groupImageView.backgroundColor = Design.GREY_ITEM;
    } else {
        self.groupImageView.backgroundColor = [UIColor clearColor];
    }
    
    self.groupImageView.image = avatar;
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);

    [super bindWithItem:item conversationViewController:conversationViewController];
    
    PeerInvitationItem* peerInvitationItem = (PeerInvitationItem *)item;
    self.invitationDescriptor = peerInvitationItem.invitationDescriptor;
    self.contentInvitationViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:peerInvitationItem.corners & ITEM_TOP_LEFT item:item];
    self.contentInvitationViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerInvitationItem.corners & ITEM_BOTTOM_LEFT item:item];
    
    CGFloat leadingMargin = (self.contentInvitationViewHeightConstraint.constant - self.avatarViewHeightConstraint.constant) * 0.5;
    self.avatarViewLeadingConstraint.constant = leadingMargin;
    self.invitationLabelLeadingConstraint.constant = leadingMargin;

    self.twincodeAction = [[TLGetTwincodeAction alloc] initWithTwinmeContext:self.twinmeContext twincodeOutboundId:self.invitationDescriptor.groupTwincodeId withBlock:^(TLBaseServiceErrorCode errorCode, NSString *name, UIImage *avatar) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onGetTwincodeActionWithErrorCode:errorCode name:name avatar:avatar];
        });
    }];
    [self.twincodeAction start];

    NSString *invitationStatus = @"";
    switch (self.invitationDescriptor.status) {
        case TLInvitationDescriptorStatusTypePending:
            invitationStatus = TwinmeLocalizedString(@"conversation_view_controller_invitation_title", nil);
            break;
            
        case TLInvitationDescriptorStatusTypeAccepted:
            invitationStatus = TwinmeLocalizedString(@"conversation_view_controller_invitation_accepted", nil);
            break;
            
        case TLInvitationDescriptorStatusTypeJoined:
            invitationStatus = TwinmeLocalizedString(@"conversation_view_controller_invitation_joined", nil);
            break;
            
        case TLInvitationDescriptorStatusTypeRefused:
            invitationStatus = TwinmeLocalizedString(@"conversation_view_controller_invitation_refused", nil);
            break;
            
        case TLInvitationDescriptorStatusTypeWithdrawn:
            invitationStatus = TwinmeLocalizedString(@"conversation_view_controller_invitation_refused", nil);
            break;
            
        default:
            break;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:Design.INVITATION_LINE_SPACING];
    NSMutableAttributedString *invitationAttributedString = [[NSMutableAttributedString alloc] initWithString:self.invitationDescriptor.name attributes:[NSDictionary dictionaryWithObject:Design.FONT_MEDIUM26 forKey:NSFontAttributeName]];
    [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:invitationStatus attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR26 forKey:NSFontAttributeName]]];
    [invitationAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, invitationAttributedString.length - 1)];
    self.invitationLabel.attributedText = invitationAttributedString;
    
    int corners = peerInvitationItem.corners;
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
    
    if (peerInvitationItem.visibleAvatar) {
        self.avatarView.hidden = NO;
        self.avatarView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
    } else {
        self.avatarView.hidden = YES;
        self.avatarView.image = nil;
    }
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.contentInvitationView];
        }
    } else {
        self.overlayView.hidden = YES;
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    if (self.isSelectItemMode) {
        self.avatarView.hidden = YES;
    }
    
    [self updateColor];
    [self setNeedsDisplay];
}

#pragma mark - IBActions

- (void)onTouchUpInsideInvitation:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideInvitation: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && [self.groupActionDelegate respondsToSelector:@selector(openGroupWithInvitationDescriptor:)]) {
        
        [self.groupActionDelegate openGroupWithInvitationDescriptor:self.invitationDescriptor];
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
    } else {
        if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
            [self.menuActionDelegate closeMenu];
        }
    }
}

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGFloat width = self.contentInvitationView.bounds.size.width;
    CGFloat height = self.contentInvitationView.bounds.size.height;
    CGFloat maxRadius = MIN(width / 2, height / 2);
    CGFloat topLeft = MIN(self.topLeftRadius, maxRadius);
    CGFloat topRight = MIN(self.topRightRadius, maxRadius);
    CGFloat bottomRight = MIN(self.bottomRightRadius, maxRadius);
    CGFloat bottomLeft = MIN(self.bottomLeftRadius, maxRadius);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft, 0)];
    [path addLineToPoint:CGPointMake(width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRight)];
    [path addArcWithCenter:CGPointMake(width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft, height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.contentInvitationView.layer.masksToBounds = YES;
    self.contentInvitationView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor clearColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentInvitationView.bounds;
    [self.contentInvitationView.layer addSublayer:self.borderLayer];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.invitationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
