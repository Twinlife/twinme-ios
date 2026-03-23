/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DayCell.h"

#import "UIScheduleDay.h"

#import <TwinmeCommon/Design.h>

#define ROUNDED_VIEW_MARGIN 8

//
// Interface: DayCell
//

@interface DayCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@end

//
// Implementation: DayCell
//

@implementation DayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.roundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.roundedView.backgroundColor = Design.GREY_ITEM;
    self.roundedView.layer.cornerRadius = self.roundedViewHeightConstraint.constant * 0.5f;
    
    self.dayLabel.font = Design.FONT_BOLD44;
    self.dayLabel.textColor = [UIColor whiteColor];
}

- (void)bind:(nonnull UIScheduleDay *)scheduleDay height:(CGFloat)height {
    
    self.dayLabel.text = scheduleDay.day;
    
    self.roundedViewHeightConstraint.constant = height - (ROUNDED_VIEW_MARGIN * Design.HEIGHT_RATIO * 2);
    self.roundedView.layer.cornerRadius = self.roundedViewHeightConstraint.constant * 0.5f;
    
    if (scheduleDay.isSelected) {
        self.roundedView.backgroundColor = Design.MAIN_COLOR;
        self.dayLabel.textColor = [UIColor whiteColor];
    } else {
        self.roundedView.backgroundColor = Design.GREY_ITEM;
        self.dayLabel.textColor = [UIColor darkGrayColor];
    }
}

@end
