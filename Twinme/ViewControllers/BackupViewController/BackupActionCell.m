/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupActionCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupActionCell ()
//

@interface BackupActionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewCenterConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewCenterConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@end

//
// Implementation: BackupActionCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupActionCell"

@implementation BackupActionCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.leftViewCenterConstraint.constant = - Design.DISPLAY_WIDTH * 0.25;
    
    self.leftView.userInteractionEnabled = YES;
    UITapGestureRecognizer *leftsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeftTapGesture:)];
    [self.leftView addGestureRecognizer:leftsGestureRecognizer];
    
    self.leftImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.leftImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.leftImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftImageView.tintColor = Design.BLACK_COLOR;
    
    self.leftLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.leftLabel.font = Design.FONT_MEDIUM30;
    self.leftLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.rightViewCenterConstraint.constant = Design.DISPLAY_WIDTH * 0.25;
    
    self.rightView.userInteractionEnabled = YES;
    UITapGestureRecognizer *rightsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRightTapGesture:)];
    [self.rightView addGestureRecognizer:rightsGestureRecognizer];
    
    self.rightImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.rightImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.rightImageView.tintColor = Design.BLACK_COLOR;
    
    self.rightLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.rightLabel.font = Design.FONT_MEDIUM30;
    self.rightLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithTitle:(nonnull NSString *)leftTitle rightTitle:(nullable NSString *)rightTitle leftImage:(nonnull UIImage *)leftImage rightImage:(nullable UIImage *)rightImage {
    DDLogVerbose(@"%@ bindWithTitle: %@ rightTitle: %@", LOG_TAG, leftTitle, rightTitle);
    
    self.leftView.accessibilityLabel = leftTitle;
    self.leftLabel.text = leftTitle;
    self.leftImageView.image = leftImage;
    
    if (rightTitle) {
        self.rightView.accessibilityLabel = rightTitle;
        self.rightLabel.text = rightTitle;
        self.rightImageView.image = rightImage;
        
        self.leftViewCenterConstraint.constant = - Design.DISPLAY_WIDTH * 0.25;
        self.rightView.hidden = NO;
    } else {
        self.leftViewCenterConstraint.constant = 0;
        self.rightView.hidden = YES;
    }
    
    [self updateColor];
    [self updateFont];
}

- (void)handleLeftTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLeftTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.backupActionDelegate respondsToSelector:@selector(didTapLeftBackupAction:)]) {
        [self.backupActionDelegate didTapLeftBackupAction:self];
    }
}

- (void)handleRightTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRightTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.backupActionDelegate respondsToSelector:@selector(didTapRightBackupAction:)]) {
        [self.backupActionDelegate didTapRightBackupAction:self];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.leftLabel.font = Design.FONT_MEDIUM30;
    self.rightLabel.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.leftLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.rightLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.leftView.tintColor = Design.BLACK_COLOR;
    self.rightView.tintColor = Design.BLACK_COLOR;
}

@end
