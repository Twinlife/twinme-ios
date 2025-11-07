/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "CallItemCell.h"

#import "CallItem.h"
#import "ConversationViewController.h"
#import "CustomAppearance.h"
#import "UIView+Toast.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallItemCell ()
//

@interface CallItemCell () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *callAvatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAvatarImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAvatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAvatarImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *callTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callTypeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callTypeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *callInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callInfoLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *callAgainLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAgainLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAgainLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *callAgainImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAgainImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callAgainImageViewHeightConstraint;
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

@property (nonatomic) TLCallDescriptor *callDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;

@property (nonatomic) CAShapeLayer *borderLayer;
@property (nonatomic) CustomAppearance *customAppearance;

@end

//
// Implementation: CallItemCell
//

#undef LOG_TAG
#define LOG_TAG @"CallItemCell"

@implementation CallItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.isDeleteAnimationStarted = NO;
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentCallView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.contentCallViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.contentCallView setBackgroundColor:Design.MAIN_COLOR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideCall:)];
    [self.contentCallView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentCallView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.callAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAvatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.callAvatarImageView.clipsToBounds = YES;
    self.callAvatarImageView.layer.cornerRadius = self.callAvatarImageViewHeightConstraint.constant * 0.5;
    
    self.callTypeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callTypeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.callTypeLabel.font = Design.FONT_MEDIUM30;
    self.callTypeLabel.textColor = [UIColor whiteColor];
    
    self.callInfoLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.callInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.callInfoLabel.font = Design.FONT_REGULAR30;
    self.callInfoLabel.textColor = [UIColor whiteColor];
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.callInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.callAgainLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callAgainLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAgainLabel.font = Design.FONT_MEDIUM30;
    self.callAgainLabel.textColor = [UIColor whiteColor];
    self.callAgainLabel.text = TwinmeLocalizedString(@"history_view_controller_call_again_title", nil);
    
    self.callAgainImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callAgainImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAgainImageView.tintColor = [UIColor whiteColor];
    self.callAgainImageView.image = [self.callAgainImageView.image imageFlippedForRightToLeftLayoutDirection];
    
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
    
    self.callDescriptor = nil;
    self.stateImageView.image = nil;
    self.topLeftRadius = 0;
    self.topRightRadius = 0;
    self.bottomRightRadius = 0;
    self.bottomLeftRadius = 0;
    self.contentDeleteView.hidden = YES;
    self.isDeleteAnimationStarted = NO;
    [self.contentDeleteView.layer removeAllAnimations];
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
    
    [self.contentCallView setBackgroundColor:[self.customAppearance getMessageBackgroundColor]];
    self.callTypeLabel.textColor = [self.customAppearance getMessageTextColor];
    self.callInfoLabel.textColor = [self.customAppearance getMessageTextColor];
    self.callAgainLabel.textColor = [self.customAppearance getMessageTextColor];
    self.callAgainImageView.tintColor = [self.customAppearance getMessageTextColor];
    
    CallItem *callItem = (CallItem *)item;
    self.callDescriptor = callItem.callDescriptor;
    self.contentCallViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:callItem.corners & ITEM_TOP_RIGHT item:item];
    self.contentCallViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:callItem.corners & ITEM_BOTTOM_RIGHT item:item];
    
    if (self.callDescriptor.isVideo) {
        self.callTypeLabel.text = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
    } else {
        self.callTypeLabel.text = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
    }
    
    self.callAvatarImageView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
    
    if ([self.callAvatarImageView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.callAvatarImageView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.callAvatarImageView.tintColor = [UIColor whiteColor];
    } else {
        self.callAvatarImageView.backgroundColor = [UIColor clearColor];
        self.callAvatarImageView.tintColor = [UIColor clearColor];
    }
    
    if (self.callDescriptor.isTerminated) {
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
        dateComponentsFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        self.callInfoLabel.text = [dateComponentsFormatter stringFromTimeInterval:self.callDescriptor.duration / 1000];
    } else {
        self.callInfoLabel.text = @"";
    }
    
    self.contentDeleteView.hidden = YES;
    
    self.stateImageView.hidden = YES;
    [self.stateImageView.layer removeAllAnimations];
    self.stateImageView.image = nil;
    
    int corners = callItem.corners;
    switch (callItem.state) {
        case ItemStateDefault:
            break;
            
        case ItemStateSending:
            corners &= ~ITEM_BOTTOM_RIGHT;
            break;
            
        case ItemStateReceived:
            corners &= ~ITEM_BOTTOM_RIGHT;
            break;
            
        case ItemStateRead:
        case ItemStatePeerDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            break;
            
        case ItemStateNotSent:
            corners &= ~ITEM_BOTTOM_RIGHT;
            break;
            
        case ItemStateDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            break;
            
        case ItemStateBothDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
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
            [self.contentView bringSubviewToFront:self.contentCallView];
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
        initialWidth = (self.item.deleteProgress * self.contentCallView.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentCallView.frame.size.width;
    
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

- (void)onTouchUpInsideCall:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideCall: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && [self.callActionDelegate respondsToSelector:@selector(recallWithCallDescriptor:)]) {
        [self.callActionDelegate recallWithCallDescriptor:self.callDescriptor];
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
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentCallView.bounds.size.width;
    CGFloat height = self.contentCallView.bounds.size.height;
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
    self.contentCallView.layer.masksToBounds = YES;
    self.contentCallView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [self.customAppearance getMessageBorderColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentCallView.bounds;
    [self.contentCallView.layer addSublayer:self.borderLayer];
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.callTypeLabel.font = Design.FONT_MEDIUM30;
    self.callInfoLabel.font = Design.FONT_REGULAR30;
    self.callAgainLabel.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
