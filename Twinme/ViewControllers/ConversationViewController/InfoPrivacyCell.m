/*
 *  Copyright (c) 2017-2021 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Phetsana Phommarinh (pphommarinh@skyrock.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoPrivacyCell.h"

#import "ConversationViewController.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

@interface InfoPrivacyCell ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation InfoPrivacyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.infoLabel.font = Design.FONT_REGULAR30;
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)updatePseudo:(NSString*)pseudo {
    self.infoLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_controller_info", nil), pseudo];
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
    } else {
        self.overlayView.hidden = YES;
    }
    
    [self updateFont];
    
    [self setNeedsDisplay];
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
        [self.menuActionDelegate closeMenu];
    }
}

- (void)updateFont {
    
    self.infoLabel.font = Design.FONT_REGULAR30;
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
}

@end
