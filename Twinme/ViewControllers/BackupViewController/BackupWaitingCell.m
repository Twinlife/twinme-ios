/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupWaitingCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: BackupWaitingCell ()
//

@interface BackupWaitingCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *waitLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *waitLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorViewTopContstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

//
// Implementation: BackupWaitingCell
//

#undef LOG_TAG
#define LOG_TAG @"BackupWaitingCell"

@implementation BackupWaitingCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.waitLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.waitLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.waitLabel.font = Design.FONT_REGULAR32;
    self.waitLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.waitLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_wait_message", @"LocalizableBackup", nil);
    
    self.activityIndicatorViewTopContstraint.constant *= Design.HEIGHT_RATIO;
    self.activityIndicatorViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.activityIndicatorView startAnimating];
}

@end
