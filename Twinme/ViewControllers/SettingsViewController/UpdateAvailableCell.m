/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AboutViewController.h"
#import "UpdateAvailableCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: UpdateAvailableCell
//

@interface UpdateAvailableCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *updateAvailableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateAvailableLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *updateAvailableLabel;

@end

//
// Implementation: UpdateAvailableCell
//

#undef LOG_TAG
#define LOG_TAG @"UpdateAvailableCell"

@implementation UpdateAvailableCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.updateAvailableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.updateAvailableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.updateAvailableView.clipsToBounds = YES;
    self.updateAvailableView.userInteractionEnabled = YES;
    self.updateAvailableView.backgroundColor = Design.MAIN_COLOR;
    self.updateAvailableView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleUpdateAvailableTapGesture:)];
    [self.updateAvailableView addGestureRecognizer:tapGestureRecognizer];
    
    self.updateAvailableLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.updateAvailableLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.updateAvailableLabel.textColor = [UIColor whiteColor];
    self.updateAvailableLabel.font = Design.FONT_REGULAR34;
    self.updateAvailableLabel.text = TwinmeLocalizedString(@"update_app_view_controller_update_available", nil);
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    self.updateAvailableLabel.font = Design.FONT_REGULAR34;
}

- (void)handleUpdateAvailableTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleUpdateAvailableTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.updateVersionDelegate respondsToSelector:@selector(updateAppVersion)]) {
        [self.updateVersionDelegate updateAppVersion];
    }
}

@end
