/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PollFooterCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: PollFooterCell
//

@interface PollFooterCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addChoiceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addChoiceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addChoiceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addChoiceLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *addChoiceLabel;

@property BOOL canAddChoice;

@end

//
// Implementation: PollFooterCell
//

@implementation PollFooterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapFooter:)]];

    self.addChoiceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.addChoiceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.addChoiceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.addChoiceLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addChoiceLabel.text = [NSString stringWithFormat:@"+ %@", NSLocalizedString(@"poll_view_add_response", nil)];
    self.addChoiceLabel.font = Design.FONT_MEDIUM34;
    self.addChoiceLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bind:(BOOL)canAddChoice {
    
    self.canAddChoice = canAddChoice;
    self.addChoiceLabel.hidden = !canAddChoice;
}

- (void)onTapFooter:(UITapGestureRecognizer *)tapGesture {
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if (self.canAddChoice && [self.pollFooterCellDelegate respondsToSelector:@selector(didTapPollFooter)]) {
            [self.pollFooterCellDelegate didTapPollFooter];
        }
    }
}
@end
