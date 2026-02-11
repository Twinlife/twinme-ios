/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import <Twinme/TLSchedule.h>

#import "ScheduleCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ScheduleCell
//

@interface ScheduleCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) ScheduleType scheduleType;

@end

//
// Implementation: ScheduleCell
//

#undef LOG_TAG
#define LOG_TAG @"ScheduleCell"

@implementation ScheduleCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_REGULAR34;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.dateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.dateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.dateView.userInteractionEnabled = YES;
    self.dateView.clipsToBounds = YES;
    self.dateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.dateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *dateViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDateViewTapGesture:)];
    [self.dateView addGestureRecognizer:dateViewGestureRecognizer];
    
    self.dateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.dateLabel.font = Design.FONT_REGULAR32;
    self.dateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.timeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.timeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.timeViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.timeView.userInteractionEnabled = YES;
    self.timeView.clipsToBounds = YES;
    self.timeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.timeView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *timeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTimeViewTapGesture:)];
    [self.timeView addGestureRecognizer:timeViewGestureRecognizer];
    
    self.timeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.timeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.timeLabel.font = Design.FONT_REGULAR32;
    self.timeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)bind:(ScheduleType)scheduleType date:(TLDate *)date time:(TLTime *)time {
    
    self.scheduleType = scheduleType;
    
    if (self.scheduleType == ScheduleTypeStart) {
        self.titleLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_start", nil);
    } else {
        self.titleLabel.text  = TwinmeLocalizedString(@"show_call_view_controller_setting_end", nil);
    }
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = date.day;
    dateComponents.month = date.month;
    dateComponents.year = date.year;
    dateComponents.hour = time.hour;
    dateComponents.minute = time.minute;
        
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *scheduleDate = [calendar dateFromComponents:dateComponents];
     
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];

    self.dateLabel.text = [dateFormatter stringFromDate:scheduleDate];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [dateFormatter stringFromDate:scheduleDate];
}

- (void)handleDateViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ handleDateViewTapGesture: %@", LOG_TAG, tapGesture);
    
    if ([self.scheduleDelegate respondsToSelector:@selector(scheduleDate:)]) {
        [self.scheduleDelegate scheduleDate:self.scheduleType];
    }
}

- (void)handleTimeViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ handleTimeViewTapGesture: %@", LOG_TAG, tapGesture);
    
    if ([self.scheduleDelegate respondsToSelector:@selector(scheduleTime:)]) {
        [self.scheduleDelegate scheduleTime:self.scheduleType];
    }
}

@end
