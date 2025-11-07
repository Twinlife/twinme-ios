/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLGetTwincodeAction.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "InvitationContactItemCell.h"

#import "InvitationContactItem.h"
#import "ConversationViewController.h"

#import "CustomAppearance.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "UIView+Toast.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InvitationContactItemCell ()
//

@interface InvitationContactItemCell ()

@property (weak, nonatomic) IBOutlet UIView *contentInvitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInvitationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *invitationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentDeleteView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLTwincodeDescriptor *twincodeDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;

@property (nonatomic) NSString *name;
@property (nonatomic, nullable) TLGetTwincodeAction *twincodeAction;

@property (nonatomic) CAShapeLayer *borderLayer;
@property (nonatomic) CustomAppearance *customAppearance;

@end

//
// Implementation: InvitationContactItemCell
//

#undef LOG_TAG
#define LOG_TAG @"InvitationContactItemCell"

@implementation InvitationContactItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    _twinmeApplication = [delegate twinmeApplication];
    _twinmeContext = [delegate twinmeContext];
    
    self.isDeleteAnimationStarted = NO;
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentInvitationView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentInvitationView setBackgroundColor:Design.MAIN_COLOR];
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.contentInvitationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentInvitationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentInvitationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentInvitationViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideInvitation:)];
    [self.contentInvitationView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentInvitationView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.contactImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contactImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactImageView.clipsToBounds = YES;
    self.contactImageView.layer.cornerRadius = self.contactImageViewHeightConstraint.constant * 0.5;
    
    self.invitationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationLabel.font = Design.FONT_REGULAR26;
    self.invitationLabel.textColor = [UIColor whiteColor];
    self.invitationLabel.text = TwinmeLocalizedString(@"conversation_view_controller_invitation_pending", nil);
    
    self.contentDeleteView.hidden = YES;
    self.contentDeleteView.alpha = 1.0;
    self.contentDeleteView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
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
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    // Cancel the twincode action if it was not finished: we will display another content.
    if (self.twincodeAction) {
        [self.twincodeAction cancel];
        self.twincodeAction = nil;
    }

    self.twincodeDescriptor = nil;
    self.stateImageView.image = nil;
    self.contentDeleteView.hidden = YES;
    self.isDeleteAnimationStarted = NO;
    [self.contentDeleteView.layer removeAllAnimations];
}

#pragma mark - TLGetTwincodeAction

- (void)onGetTwincodeActionWithErrorCode:(TLBaseServiceErrorCode)errorCode name:(nullable NSString *)name avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeActionWithErrorCode: %d name: %@ avatar: %@", LOG_TAG, errorCode, name, avatar);

    self.twincodeAction = nil;

    if (errorCode != TLBaseServiceErrorCodeSuccess || !name) {
        self.invitationLabel.text = @"";
        return;
    }

    if (!avatar) {
        avatar = [TLTwinmeAttributes DEFAULT_AVATAR];
    }

    self.name = name;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:Design.INVITATION_LINE_SPACING];
    NSMutableAttributedString *invitationAttributedString = [[NSMutableAttributedString alloc] initWithString:self.name attributes:[NSDictionary dictionaryWithObject:Design.FONT_MEDIUM26 forKey:NSFontAttributeName]];
    [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"conversation_view_controller_invitation_pending", nil) attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR26 forKey:NSFontAttributeName]]];
    [invitationAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, invitationAttributedString.length - 1)];
    self.invitationLabel.attributedText = invitationAttributedString;

    self.contactImageView.image = avatar;
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.customAppearance = [conversationViewController getCustomAppearance];
    
    self.invitationLabel.textColor = [self.customAppearance getMessageTextColor];
    [self.contentInvitationView setBackgroundColor:[self.customAppearance getMessageBackgroundColor]];
        
    InvitationContactItem *invitationContactItem = (InvitationContactItem *)item;
    self.twincodeDescriptor = invitationContactItem.twincodeDescriptor;
    self.contentInvitationViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:invitationContactItem.corners & ITEM_TOP_RIGHT item:item];
    self.contentInvitationViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:invitationContactItem.corners & ITEM_BOTTOM_RIGHT item:item];
    
    CGFloat leadingMargin = (self.contentInvitationViewHeightConstraint.constant - self.contactImageViewHeightConstraint.constant) * 0.5;
    self.contactImageViewLeadingConstraint.constant = leadingMargin;
    self.invitationLabelLeadingConstraint.constant = leadingMargin;
    
    NSUUID *twincodeOutboundId;
    if (self.twincodeDescriptor.sendTo) {
        twincodeOutboundId = self.twincodeDescriptor.sendTo;
    } else {
        twincodeOutboundId = self.twincodeDescriptor.twincodeId;
    }

    self.twincodeAction = [[TLGetTwincodeAction alloc] initWithTwinmeContext:self.twinmeContext twincodeOutboundId:twincodeOutboundId withBlock:^(TLBaseServiceErrorCode errorCode, NSString *name, UIImage *avatar) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onGetTwincodeActionWithErrorCode:errorCode name:name avatar:avatar];
        });
    }];
    [self.twincodeAction start];

    self.contentDeleteView.hidden = YES;
    
    self.stateImageView.backgroundColor = [UIColor clearColor];
    self.stateImageView.tintColor = [UIColor clearColor];
    
    int corners = invitationContactItem.corners;
    switch (invitationContactItem.state) {
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
            self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[item peerTwincodeOutboundId]];
            if ([self.stateImageView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
                self.stateImageView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
                self.stateImageView.tintColor = [UIColor whiteColor];
            }
            break;
            
        case ItemStateNotSent:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateNotSent"];
            break;
            
        case ItemStateDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            [self startStateImageAnimation];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
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
            [self.contentView bringSubviewToFront:self.contentInvitationView];
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

- (void)startDeleteAnimation {
    DDLogVerbose(@"%@ startDeleteAnimation", LOG_TAG);
    
    if (self.isDeleteAnimationStarted) {
        return;
    }
    
    self.isDeleteAnimationStarted = YES;
    
    CGFloat initialWidth = 0;
    CGFloat animationDuration = DESIGN_DELETE_ANIMATION_DURATION;
    if (self.item.deleteProgress > 0) {
        initialWidth = (self.item.deleteProgress * self.contentInvitationView.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentInvitationView.frame.size.width;
    
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

#pragma mark - IBActions

- (void)onTouchUpInsideInvitation:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideInvitation: %@", LOG_TAG, tapGesture);
    
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
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentInvitationView.bounds.size.width;
    CGFloat height = self.contentInvitationView.bounds.size.height;
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
    self.contentInvitationView.layer.masksToBounds = YES;
    self.contentInvitationView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [self.customAppearance getMessageBorderColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentInvitationView.bounds;
    [self.contentInvitationView.layer addSublayer:self.borderLayer];
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    if (self.name) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:Design.INVITATION_LINE_SPACING];
        NSMutableAttributedString *invitationAttributedString = [[NSMutableAttributedString alloc] initWithString:self.name attributes:[NSDictionary dictionaryWithObject:Design.FONT_MEDIUM26 forKey:NSFontAttributeName]];
        [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [invitationAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"conversation_view_controller_invitation_pending", nil) attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR26 forKey:NSFontAttributeName]]];
        [invitationAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, invitationAttributedString.length - 1)];
        self.invitationLabel.attributedText = invitationAttributedString;
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
