/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "LogsViewController.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AuthentifiedLogsViewControllerRelationViewController ()
//

@interface LogsViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextView *logsView;

@property NSString *logs;

@end

//
// Implementation: LogsViewController
//

#undef LOG_TAG
#define LOG_TAG @"LogsViewController"

@implementation LogsViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initWithLogs:(NSString *)logs {
    DDLogVerbose(@"%@ initWithLogs: %@", LOG_TAG, logs);
    
    self.logs = logs;
    self.logsView.text = self.logs;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.WHITE_COLOR];
    [self setNavigationTitle:TwinmeLocalizedString(@"feedback_view_controller_logs", nil)];
    
    self.logsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logsViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.logsViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.logsViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.logsView.textColor = Design.FONT_COLOR_DEFAULT;
    self.logsView.editable = NO;
    self.logsView.text = self.logs;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.view setBackgroundColor:Design.WHITE_COLOR];
    self.logsView.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
