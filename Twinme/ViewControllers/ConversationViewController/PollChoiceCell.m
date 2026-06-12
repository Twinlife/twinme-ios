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

#define CHECKMARK_SIZE 44.0
#define VALUE_MARGIN 10.0
#define COUNTER_WIDTH 40.0
#define AVATAR_SIZE 30.0
#define AVATAR_MARGIN -20.0
#define COUNTER_MARGIN 4.0
#define MIN_CONTENT_HEIGHT 80.0
#define CHECKMARK_MARGIN 18.0
#define TRACK_MARGIN 8.0
#define TRACK_HEIGHT 8.0

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultTrackViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *resultTrackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *trackView;
@property (assign, nonatomic) CGFloat resultRatio;

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
    self.valueLabel.numberOfLines = 0;
    self.valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.valueLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.counterLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.counterLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.counterLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
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
    self.checkMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    checkMarkViewLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.checkMarkImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkImageView.image = [self.checkMarkImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.checkMarkImageView.tintColor = [UIColor blackColor];
    
    self.trackViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.trackViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.trackViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.trackView.clipsToBounds = YES;
    self.trackView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.trackView.layer.cornerRadius = self.trackViewHeightConstraint.constant * 0.5;
    
    self.resultTrackViewWidthConstraint.constant = 0.0;
    
    self.resultTrackView.clipsToBounds = YES;
    self.resultTrackView.backgroundColor = [UIColor colorWithRed:38./255. green:209./255. blue:160./255. alpha:1];
    self.resultTrackView.layer.cornerRadius = self.trackViewHeightConstraint.constant * 0.5;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.resultRatio = 0.0;
    self.resultTrackViewWidthConstraint.constant = 0.0;
}

- (void)layoutSubviews {
    DDLogVerbose(@"%@ layoutSubviews", LOG_TAG);
    
    [super layoutSubviews];
    
    [self updateResultTrackViewWidth];
}

- (void)updateResultTrackViewWidth {
    DDLogVerbose(@"%@ updateResultTrackViewWidth", LOG_TAG);
    
    CGFloat trackViewWidth = CGRectGetWidth(self.trackView.bounds);
    if (trackViewWidth <= 0.0) {
        return;
    }
    
    CGFloat resultTrackViewWidth = trackViewWidth * self.resultRatio;
    if (self.resultTrackViewWidthConstraint.constant != resultTrackViewWidth) {
        self.resultTrackViewWidthConstraint.constant = resultTrackViewWidth;
    }
}

- (void)bindWithPollResult:(UIPollResult *)pollResult textColor:(UIColor *)textColor maxResult:(int)maxResult {
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
    
    self.resultRatio = maxResult > 0 ? (CGFloat)pollResult.count / (CGFloat)maxResult : 0.0;
    [self updateResultTrackViewWidth];
    [self setNeedsLayout];
    
    self.valueLabel.textColor = textColor;
    self.counterLabel.textColor = textColor;
    self.trackView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

+ (CGFloat)maxChoiceWidth:(CGFloat)contentWidth {
        
    return contentWidth - (CHECKMARK_SIZE * Design.HEIGHT_RATIO) - (2 * VALUE_MARGIN * Design.WIDTH_RATIO) - ((2 * AVATAR_SIZE * Design.HEIGHT_RATIO) - (AVATAR_SIZE * Design.HEIGHT_RATIO + AVATAR_MARGIN * Design.WIDTH_RATIO)) - (COUNTER_MARGIN * Design.WIDTH_RATIO) - (COUNTER_WIDTH * Design.WIDTH_RATIO);
}

+ (CGFloat)cellHeightForChoice:(CGFloat)choiceHeight  {
     
    CGFloat contentHeight = (CHECKMARK_MARGIN * Design.HEIGHT_RATIO) + choiceHeight + (TRACK_MARGIN * Design.HEIGHT_RATIO) + (TRACK_HEIGHT * Design.HEIGHT_RATIO) + (CHECKMARK_MARGIN * Design.HEIGHT_RATIO);
    
    return MAX(contentHeight, MIN_CONTENT_HEIGHT * Design.HEIGHT_RATIO);
}
    


@end
