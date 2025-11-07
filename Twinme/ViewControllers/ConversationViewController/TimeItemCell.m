/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TimeItemCell.h"

#import "TimeItem.h"
#import "ConversationViewController.h"

#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>

#import "DashedLine.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_TIME_CELL_MARGIN1 = 61;

//
// Implementation: TimeItemCell
//

#undef LOG_TAG
#define LOG_TAG @"TimeItemCell"

@implementation TimeItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier topMargin:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self configureSubviewsWithMarginTop:topMargin bottomMargin:bottomMargin];
    }
    return self;
}

- (void)configureSubviewsWithMarginTop:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin {
    
    NSDictionary *views = @{
        @"messageLabel":self.messageLabel,
    };
    NSDictionary *metrics = @{
        @"margin1":@(DESIGN_TIME_CELL_MARGIN1 * Design.WIDTH_RATIO)
    };
    
    [self.contentView addSubview:self.overlayView];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin1)-[messageLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[messageLabel]-(margin1)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    self.item = item;
    
    TimeItem *timeItem = (TimeItem *)item;
    self.messageLabel.text = [NSString formatItemTimeInterval:timeItem.timestamp / 1000];
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
    } else {
        self.overlayView.hidden = YES;
    }
}

- (UILabel *)messageLabel {
    
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.userInteractionEnabled = NO;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = Design.FONT_MEDIUM24;
        [_messageLabel setTextColor:Design.TIME_COLOR];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (UIView *)overlayView {
    
    if (!_overlayView) {
        _overlayView = [UIView new];
        _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        _overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        _overlayView.hidden = YES;
    }
    return _overlayView;
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
        [self.menuActionDelegate closeMenu];
    }
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
}

@end
