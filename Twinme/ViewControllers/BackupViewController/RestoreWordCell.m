/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "RestoreWordCell.h"

#import "UIBackupWord.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: RestoreWordCell ()
//

@interface RestoreWordCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@end

//
// Implementation: RestoreWordCell
//

#undef LOG_TAG
#define LOG_TAG @"RestoreWordCell"

@implementation RestoreWordCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.backgroundColor = Design.GREY_ITEM;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = self.containerViewHeightConstraint.constant * 0.5f;
    
    self.wordLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.wordLabel.font = [Design getBackupWordFont];;
    self.wordLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    self.checkMarkImageView.hidden = YES;
}

- (void)bind:(UIBackupWord *)backupWord currentWord:(BOOL)currentWord {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, backupWord);
    
    self.checkMarkImageView.hidden = NO;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [backupWord getPosition] + 1] attributes:[NSDictionary dictionaryWithObject:Design.FONT_COLOR_GREY forKey:NSForegroundColorAttributeName]];
    
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@" "]];
    
    if ([backupWord getPosition] < 9) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@" "]];
    }
    
    [attributedString
     appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[backupWord getWord] attributes:[NSDictionary dictionaryWithObject:Design.FONT_COLOR_DEFAULT forKey:NSForegroundColorAttributeName]]];
    [self.wordLabel setAttributedText:attributedString];
    
    if (currentWord) {
        self.containerView.layer.borderWidth = 1;
        self.containerView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    } else {
        self.containerView.layer.borderWidth = 0;
        self.containerView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)bindWithPosition:(int)position currentWord:(BOOL)currentWord {
    DDLogVerbose(@"%@ bindWithPosition: %d", LOG_TAG, position);
    
    self.checkMarkImageView.hidden = YES;
    self.wordLabel.textColor = Design.FONT_COLOR_GREY;
    [self.wordLabel setText:[NSString stringWithFormat:@"%d", position + 1]];
    
    if (currentWord) {
        self.containerView.layer.borderWidth = 1;
        self.containerView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    } else {
        self.containerView.layer.borderWidth = 0;
        self.containerView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
