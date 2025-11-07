/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuDateTimeView.h"
#import "SettingsItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: MenuDateTimeView ()
//

@interface MenuDateTimeView ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;

@property (nonatomic) UIDatePicker *datePicker;

@end

//
// Implementation: MenuDateTimeView
//

#undef LOG_TAG
#define LOG_TAG @"MenuDateTimeView"

@implementation MenuDateTimeView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuDateTimeView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)setMenuDateTimeTypeWithType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ setMenuDateTimeTypeWithType", LOG_TAG);
    
    self.menuDateTimeType = menuDateTimeType;
    
    [self setupTitle];
}

- (void)openMenu:(NSDate *)minimumDate date:(NSDate *)date {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.datePicker.minimumDate = minimumDate;
    self.datePicker.date = date;
   
    [self openMenu];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
   
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    self.datePickerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.datePickerViewBottomConstraint.constant = safeAreaInset;
    
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if (@available(iOS 14.0, *)) {
        [self.datePicker setPreferredDatePickerStyle:UIDatePickerStyleInline];
    }
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.tintColor = Design.MAIN_COLOR;
    
    [self.datePickerView addSubview:self.datePicker];
    self.datePickerViewWidthConstraint.constant = self.datePicker.frame.size.width;
    self.datePickerViewHeightConstraint.constant = self.datePicker.frame.size.height;
}

- (void)setupTitle {
    DDLogVerbose(@"%@ setupTitle", LOG_TAG);
    
    switch (self.menuDateTimeType) {
        case MenuDateTimeTypeStartDate:
        case MenuDateTimeTypeStartHour:
            self.titleLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_start", nil);
            break;
            
        case MenuDateTimeTypeEndDate:
        case MenuDateTimeTypeEndHour:
            self.titleLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_end", nil);
            break;
            
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuDateTimeViewDelegate respondsToSelector:@selector(menuDateTimeDidClosed:menuDateTimeType:date:)]) {
        [self.menuDateTimeViewDelegate menuDateTimeDidClosed:self menuDateTimeType:self.menuDateTimeType date:self.datePicker.date];
    }
}
@end

