/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PollHeaderCell.h"

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/Design.h>

#import "SwitchView.h"

#define MAX_QUESTION_LENGTH 128

//
// Interface: PollHeaderCell
//

@interface PollHeaderCell() <UITextViewDelegate, SwitchViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionCounterLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionCounterLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *questionCounterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multipleChoiceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *multipleChoiceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multipleChoiceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multipleChoiceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multipleChoiceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multipleChoiceLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *multipleChoiceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choiceSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *choiceSwitch;

@property (strong, nonatomic) UILabel *questionPlaceholderLabel;

@property BOOL initPlaceholder;

@end

//
// Implementation: PollHeaderCell
//

@implementation PollHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.initPlaceholder = NO;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.questionTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.questionTextViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.questionTextView.backgroundColor = Design.WHITE_COLOR;
    self.questionTextView.font = Design.FONT_REGULAR34;
    self.questionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    self.questionTextView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.questionTextView.delegate = self;
    self.questionTextView.text = @"";
    self.questionTextView.textContainer.lineFragmentPadding = 0;
    self.questionTextView.textContainerInset = UIEdgeInsetsZero;
    self.questionTextView.returnKeyType = UIReturnKeyNext;

    self.questionPlaceholderLabel = [[UILabel alloc] init];
    self.questionPlaceholderLabel.text = TwinmeLocalizedString(@"poll_view_ask_question", nil);
    self.questionPlaceholderLabel.textColor = Design.PLACEHOLDER_COLOR;
    self.questionPlaceholderLabel.font = Design.FONT_REGULAR34;
    self.questionPlaceholderLabel.numberOfLines = 1;
    self.questionPlaceholderLabel.userInteractionEnabled = NO;
    [self.questionTextView addSubview:self.questionPlaceholderLabel];
    
    self.questionCounterLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.questionCounterLabelTopConstraint.constant *= Design.WIDTH_RATIO;
    
    self.questionCounterLabel.font = Design.FONT_REGULAR28;
    self.questionCounterLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.questionCounterLabel.text = [NSString stringWithFormat:@"0/%d", MAX_QUESTION_LENGTH];
    
    self.multipleChoiceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.multipleChoiceView.userInteractionEnabled = YES;
    self.multipleChoiceView.backgroundColor = [UIColor clearColor];
    [self.multipleChoiceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMultipleChoice:)]];
    
    self.multipleChoiceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.multipleChoiceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.multipleChoiceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.multipleChoiceLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.multipleChoiceLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.multipleChoiceLabel.font = Design.FONT_MEDIUM34;
    self.multipleChoiceLabel.text = NSLocalizedString(@"poll_view_allow_multiple", nil);
    
    self.choiceSwitch.switchViewDelegate = self;
    
    CGSize switchSize = [Design switchSize];
    self.choiceSwitch.userInteractionEnabled = NO;
    self.choiceSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.choiceSwitchWidthConstraint.constant = switchSize.width;
    self.choiceSwitchHeightConstraint.constant = switchSize.height;
    [self.choiceSwitch setOn:YES];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (!self.initPlaceholder) {
        self.initPlaceholder = YES;
        
        CGFloat horizontalInset = self.questionTextView.textContainerInset.left + self.questionTextView.textContainer.lineFragmentPadding;
        CGFloat verticalInset = self.questionTextView.textContainerInset.top;
        
        CGFloat maxWidth = CGRectGetWidth(self.questionTextView.bounds) - horizontalInset - self.questionTextView.textContainerInset.right - self.questionTextView.textContainer.lineFragmentPadding;
        CGSize placeholderSize = [self.questionPlaceholderLabel sizeThatFits:CGSizeMake(MAX(0, maxWidth), CGFLOAT_MAX)];
        self.questionPlaceholderLabel.frame = CGRectMake(horizontalInset, verticalInset, MAX(0, maxWidth), placeholderSize.height);
    }
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.initPlaceholder = NO;
}

- (void)bind:(nonnull NSString *)question allowMultipleChoice:(BOOL)allowMultipleChoice beginEditing:(BOOL)beginEditing {
    
    self.questionTextView.text = question;
    [self updatePlaceholder];

    if ([question isEqualToString:@""]) {
        self.questionCounterLabel.text = [NSString stringWithFormat:@"0/%d", MAX_QUESTION_LENGTH];
    } else {
        self.questionCounterLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.questionTextView.text.length, MAX_QUESTION_LENGTH];
    }
    
    [self.choiceSwitch setOn:allowMultipleChoice];
    
    if (beginEditing) {
        [self.questionTextView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self updatePlaceholder];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self updatePlaceholder];

    if ([self.pollHeaderCellDelegate respondsToSelector:@selector(didUpdateQuestion:)]) {
        [self.pollHeaderCellDelegate didUpdateQuestion:self.questionTextView.text];
    }

    if ([textView.text isEqualToString:@""]) {
        self.questionCounterLabel.text = [NSString stringWithFormat:@"0/%d", MAX_QUESTION_LENGTH];
    } else {
        self.questionCounterLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.questionTextView.text.length, MAX_QUESTION_LENGTH];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        if ([self.pollHeaderCellDelegate respondsToSelector:@selector(didEndEditing:)]) {
            [self.pollHeaderCellDelegate didEndEditing:self.questionTextView.text];
        }
        
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= MAX_QUESTION_LENGTH;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self updatePlaceholder];
}

- (void)updatePlaceholder {
    
    self.questionPlaceholderLabel.hidden = self.questionTextView.text.length > 0;
}

- (void)onTapMultipleChoice:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.pollHeaderCellDelegate respondsToSelector:@selector(didUpdateAllowMultipleChoice:)]) {
        if (self.choiceSwitch.isEnabled) {
            [self.choiceSwitch setOn:!self.choiceSwitch.isOn];
        }
        
        [self.pollHeaderCellDelegate didUpdateAllowMultipleChoice:self.choiceSwitch.isOn];
    }
}

@end
