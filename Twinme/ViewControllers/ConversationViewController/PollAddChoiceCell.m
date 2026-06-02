/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PollAddChoiceCell.h"

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/Design.h>

#import "UIPollChoice.h"

#define MAX_CHOICE_LENGTH 32

//
// Interface: PollAddChoiceCell
//

@interface PollAddChoiceCell() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *choiceTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceCounterLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *choiceCounterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTextFieldTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceTextFieldBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *choiceTextField;

@property (nonatomic) UIPollChoice *pollChoice;

@end

//
// Implementation: PollAddChoiceCell
//

@implementation PollAddChoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.userInteractionEnabled = YES;
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = Design.GREY_ITEM.CGColor;
    
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChoice:)]];

    self.choiceTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.choiceTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.choiceTitleLabel.textColor = Design.MAIN_COLOR;
    self.choiceTitleLabel.font = Design.FONT_REGULAR30;
    
    self.choiceCounterLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.choiceCounterLabel.textColor = Design.MAIN_COLOR;
    self.choiceCounterLabel.font = Design.FONT_REGULAR30;
    self.choiceCounterLabel.text = [NSString stringWithFormat:@"0/%d", MAX_CHOICE_LENGTH];

    self.choiceTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.choiceTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.choiceTextFieldTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.choiceTextFieldBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.choiceTextField.delegate = self;
    self.choiceTextField.placeholder = TwinmeLocalizedString(@"poll_view_enter_response", nil);
    self.choiceTextField.font = Design.FONT_REGULAR34;
    self.choiceTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.choiceTextField.returnKeyType = UIReturnKeyNext;
    self.choiceTextField.backgroundColor = [UIColor clearColor];
    
    [self.choiceTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.choiceTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"poll_view_enter_response", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.choiceCounterLabel.hidden = YES;
}

- (void)bindWithChoice:(nonnull UIPollChoice *)pollChoice {
        
    self.pollChoice = pollChoice;
    self.choiceTitleLabel.text = [self.pollChoice getChoicePosition];
    self.choiceTextField.text = self.pollChoice.choice;
    self.choiceCounterLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.choiceTextField.text.length, MAX_CHOICE_LENGTH];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pollChoice.isSelected) {
            [self.choiceTextField becomeFirstResponder];
            self.choiceCounterLabel.hidden = NO;
            self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
            self.containerView.layer.borderWidth = 2;
            self.containerView.layer.borderColor = Design.MAIN_COLOR.CGColor;
        } else {
            [self.choiceTextField resignFirstResponder];
            self.choiceCounterLabel.hidden = YES;
            self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
            self.containerView.layer.borderWidth = 2;
            self.containerView.layer.borderColor = Design.GREY_ITEM.CGColor;
        }
    });
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = Design.MAIN_COLOR.CGColor;
    self.choiceCounterLabel.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.choiceCounterLabel.hidden = YES;
    
    if ([self.pollAddChoiceCellDelegate respondsToSelector:@selector(didEndEditingChoice:)]) {
        [self.pollAddChoiceCellDelegate didEndEditingChoice:self.pollChoice];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.pollAddChoiceCellDelegate respondsToSelector:@selector(didReturnChoice:)]) {
        [self.pollAddChoiceCellDelegate didReturnChoice:self.pollChoice];
    }
    
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.choiceCounterLabel.hidden = YES;
    
    [textField resignFirstResponder];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    return textField.text.length + (string.length - range.length) <= MAX_CHOICE_LENGTH;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    self.choiceCounterLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.choiceTextField.text.length, MAX_CHOICE_LENGTH];
    
    if ([self.pollAddChoiceCellDelegate respondsToSelector:@selector(didUpdateChoice:text:)]) {
        [self.pollAddChoiceCellDelegate didUpdateChoice:self.pollChoice text:textField.text];
    }
}

- (void)onTapChoice:(UITapGestureRecognizer *)tapGesture {
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.choiceTextField becomeFirstResponder];
    }
}

@end
