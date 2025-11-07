/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ExportActionCell.h"
#import "ExportViewController.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ExportActionCell ()
//

@interface ExportActionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (nonatomic) ExportActionType exportActionType;

@end

//
// Implementation: ExportActionCell
//

#undef LOG_TAG
#define LOG_TAG @"ExportActionCell"

@implementation ExportActionCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.actionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.actionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.actionLabel.font = Design.FONT_BOLD34;
    self.actionLabel.textColor = [UIColor whiteColor];
    
    self.actionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.clipsToBounds = YES;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionTapGesture:)];
    [self.actionView addGestureRecognizer:tapGestureRecognizer];
}

- (void)bindWithAction:(ExportActionType)exportActionType enable:(BOOL)enable {
    DDLogVerbose(@"%@ bindWithAction: %u enable: %@", LOG_TAG, exportActionType, enable ? @"YES":@"NO");
    
    self.exportActionType = exportActionType;
    
    if (exportActionType == ExportActionTypeCancel || exportActionType == ExportActionTypeCleanup) {
        self.actionView.backgroundColor = Design.DELETE_COLOR_RED;
        if (exportActionType == ExportActionTypeCancel) {
            self.actionLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
        } else {
            self.actionLabel.text = TwinmeLocalizedString(@"cleanup_view_controller_clean", nil);
        }
    } else {
        self.actionView.backgroundColor = Design.MAIN_COLOR;
        self.actionLabel.text = TwinmeLocalizedString(@"export_view_controller_export", nil);
    }
    
    if (enable) {
        self.actionView.alpha = 1.f;
    } else {
        self.actionView.alpha = 0.5f;
    }
}

- (void)handleActionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleActionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.exportActionDelegate respondsToSelector:@selector(didTapAction:)]) {
        [self.exportActionDelegate didTapAction:self.exportActionType];
    }
}

@end
