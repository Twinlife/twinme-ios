/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "NameItemCell.h"

#import "NameItem.h"
#import "ConversationViewController.h"

#import "CustomAppearance.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_AVATAR_WIDTH = 78;
static const CGFloat DESIGN_AVATAR_LEADING = 26;
static const CGFloat DESIGN_AVATAR_TRAILING = 18;

//
// Interface: NameItemCell ()
//

@interface NameItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

//
// Implementation: NameItemCell
//

#undef LOG_TAG
#define LOG_TAG @"NameItemCell"

@implementation NameItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    CGFloat nameLabelLeadingConstraintConstant = ((DESIGN_AVATAR_LEADING + DESIGN_AVATAR_TRAILING) * Design.WIDTH_RATIO) + (DESIGN_AVATAR_WIDTH * Design.HEIGHT_RATIO);
    self.nameLabelLeadingConstraint.constant = nameLabelLeadingConstraintConstant;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.font = Design.FONT_REGULAR24;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.nameLabel.text = nil;
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    self.item = item;
    
    [self.nameLabel setTextColor:[[conversationViewController getCustomAppearance] getConversationBackgroundText]];
    
    NameItem *nameItem = (NameItem *)item;
    self.nameLabel.text = nameItem.name;
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
    } else {
        self.overlayView.hidden = YES;
    }
    
    [self updateFont];
    [self updateColor];
    [self setNeedsDisplay];
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
        [self.menuActionDelegate closeMenu];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_REGULAR24;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
