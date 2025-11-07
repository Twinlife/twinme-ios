/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ExpirationDateCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ExpirationDateCell
//

@interface ExpirationDateCell()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

//
// Implementation: ExpirationDateCell
//

#undef LOG_TAG
#define LOG_TAG @"ExpirationDateCell"

@implementation ExpirationDateCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    BOOL darkModeStyle = NO;
    if (@available(iOS 13.0, *)) {
        if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            darkModeStyle = YES;
        }
    }
    
    if (twinmeApplication.displayMode == DisplayModeLight && darkModeStyle) {
        self.contentView.backgroundColor = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    } else {
        self.contentView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    }

    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.tintColor = Design.MAIN_COLOR;
    [self.datePicker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
}

- (void)dateDidChange {
    DDLogVerbose(@"%@ dateDidChange", LOG_TAG);
    
    if ([self.expirationDateDelegate respondsToSelector:@selector(didChangeDate:)]) {
        [self.expirationDateDelegate didChangeDate:self.datePicker.date];
    }
}

@end

