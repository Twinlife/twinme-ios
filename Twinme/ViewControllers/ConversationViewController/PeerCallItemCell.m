/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Utils/NSString+Utils.h>

#import "PeerCallItemCell.h"

#import "ConversationViewController.h"

#import <TwinmeCommon/Design.h>
#import "PeerCallItem.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PeerCallItemCell ()
//

@interface PeerCallItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *contentCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCallViewLeadingConstraint;
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
@property (nonatomic) CAShapeLayer *borderLayer;

@end

//
// Implementation: PeerCallItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerCallItemCell"

@implementation PeerCallItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentCallView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentCallViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentCallViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideCall:)];
    [self.contentCallView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentCallView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.contentCallView.backgroundColor = Design.GREY_ITEM;
    
    self.callAvatarImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAvatarImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callAvatarImageView.clipsToBounds = YES;
    self.callAvatarImageView.layer.cornerRadius = self.callAvatarImageViewHeightConstraint.constant * 0.5;
    
    self.callTypeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callTypeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.callTypeLabel.font = Design.FONT_MEDIUM30;
    self.callTypeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.callInfoLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.callInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.callInfoLabel.font = Design.FONT_REGULAR30;
    self.callInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.callInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.callAgainLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callAgainLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAgainLabel.font = Design.FONT_MEDIUM30;
    self.callAgainLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.callAgainLabel.text = TwinmeLocalizedString(@"history_view_controller_call_again_title", nil);
    
    self.callAgainImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callAgainImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callAgainImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.callAgainImageView.image = [self.callAgainImageView.image imageFlippedForRightToLeftLayoutDirection];
    
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
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.callDescriptor = nil;
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

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    PeerCallItem *peerCallItem = (PeerCallItem *)item;
    self.callDescriptor = peerCallItem.peerCallDescriptor;
    
    if (self.callDescriptor.isVideo) {
        self.callTypeLabel.text = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
    } else {
        self.callTypeLabel.text = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
    }
    
    self.callAvatarImageView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
    
    if (!self.callDescriptor.isAccepted && self.callDescriptor.isIncoming) {
        if (self.callDescriptor.isTerminated) {
            self.callInfoLabel.textColor = Design.DELETE_COLOR_RED;
            self.callInfoLabel.text = TwinmeLocalizedString(@"conversation_view_controller_call_missed", nil);
        } else {
            self.callInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
            self.callInfoLabel.text = @"";
        }
    } else {
        self.callInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
        dateComponentsFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        self.callInfoLabel.text = [dateComponentsFormatter stringFromTimeInterval:self.callDescriptor.duration / 1000];
    }
    
    self.contentCallViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:peerCallItem.corners & ITEM_TOP_LEFT item:item];
    self.contentCallViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerCallItem.corners & ITEM_BOTTOM_LEFT item:item];
        
    int corners = peerCallItem.corners;
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
    
    if (peerCallItem.visibleAvatar) {
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
            [self.contentView bringSubviewToFront:self.contentCallView];
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
    
    [super drawRect:rect];
    
    CGFloat width = self.contentCallView.bounds.size.width;
    CGFloat height = self.contentCallView.bounds.size.height;
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
    self.contentCallView.layer.masksToBounds = YES;
    self.contentCallView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor clearColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentCallView.bounds;
    [self.contentCallView.layer addSublayer:self.borderLayer];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.callTypeLabel.font = Design.FONT_MEDIUM30;
    self.callInfoLabel.font = Design.FONT_REGULAR30;
    self.callAgainLabel.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentCallView.backgroundColor = Design.GREY_ITEM;
    self.callTypeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.callAgainLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.callAgainImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
