/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AddCommentCell.h"

#import "ShareViewController.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AddCommentCell
//

@interface AddCommentCell()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTextFieldViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@end

//
// Implementation: AddCommentCell
//

#undef LOG_TAG
#define LOG_TAG @"AddCommentCell"

@implementation AddCommentCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.containerViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.backgroundColor = Design.FORWARD_COMMENT_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = self.containerViewHeightConstraint.constant * 0.5;
        
    self.commentTextFieldViewWidthConstraint.constant *= Design.WIDTH_RATIO;

    self.commentTextField.delegate = self;
    self.commentTextField.font = Design.FONT_REGULAR30;
    self.commentTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.commentTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    [self.commentTextField setReturnKeyType:UIReturnKeyDone];
    self.commentTextField.backgroundColor = Design.FORWARD_COMMENT_COLOR;
    
    self.commentTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"conversation_view_controller_message", nil) attributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:162./255. green:162./255 blue:162./255 alpha:255./255] forKey:NSForegroundColorAttributeName]];
    
    [self.commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    [self updateFont];
    [self updateColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if ([self.addCommentDelegate respondsToSelector:@selector(commentDidChange:)]) {
        [self.addCommentDelegate commentDidChange:textField.text];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.commentTextField.font = Design.FONT_REGULAR30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.commentTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.commentTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.commentTextField.backgroundColor = Design.FORWARD_COMMENT_COLOR;
    self.containerView.backgroundColor = Design.FORWARD_COMMENT_COLOR;
}

@end
