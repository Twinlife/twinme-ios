/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import "PollChoiceCell.h"

#import "UIPollResult.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PollChoiceCell
//

@interface PollChoiceCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarOneImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarOneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarTwoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarTwoImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarTwoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: PollChoiceCell
//

#undef LOG_TAG
#define LOG_TAG @"PollChoiceCell"

@implementation PollChoiceCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.valueLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.valueLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.valueLabel.font = Design.FONT_MEDIUM32;
    
    self.counterLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.counterLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterLabel.font = Design.FONT_MEDIUM32;
    
    self.avatarOneImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarOneImageView.clipsToBounds = YES;
    self.avatarOneImageView.layer.cornerRadius = self.avatarOneImageViewHeightConstraint.constant * 0.5;
    
    self.avatarTwoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarTwoImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarTwoImageView.clipsToBounds = YES;
    self.avatarTwoImageView.layer.cornerRadius = self.avatarTwoImageViewHeightConstraint.constant * 0.5;
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    checkMarkViewLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.checkMarkImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkImageView.image = [self.checkMarkImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.checkMarkImageView.tintColor = [UIColor blackColor];
    
    self.separatorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.clipsToBounds = YES;
    self.separatorView.layer.cornerRadius = self.separatorViewHeightConstraint.constant * 0.5;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)bindWithPollResult:(UIPollResult *)pollResult textColor:(UIColor *)textColor {
    DDLogVerbose(@"%@ bindWithPollResult: %@ textColor: %@", LOG_TAG, pollResult, textColor);
        
    self.valueLabel.text = pollResult.choice.label;
    self.counterLabel.text = [NSString stringWithFormat:@"%d",pollResult.count];
    
    self.avatarOneImageView.hidden = YES;
    self.avatarTwoImageView.hidden = YES;
    
    if (pollResult.voters.count > 1) {
        self.avatarTwoImageView.hidden = NO;
        self.avatarTwoImageView.image = pollResult.voters[1];
    }
    
    if (pollResult.voters.count > 0) {
        self.avatarOneImageView.hidden = NO;
        self.avatarOneImageView.image = pollResult.voters[0];
    }
        
    if (pollResult.isSelected) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
    
    self.valueLabel.textColor = textColor;
    self.counterLabel.textColor = textColor;
    self.separatorView.backgroundColor = textColor;
}

@end
