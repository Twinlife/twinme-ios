/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Utils/NSString+Utils.h>

#import "EnableNotificationCell.h"

#import <TwinmeCommon/Design.h>

static UIColor *DESIGN_BACKGROUND_COLOR;
static UIColor *DESIGN_ACCESSORY_COLOR;
static UIColor *DESIGN_MESSAGE_COLOR;

static const CGFloat DESIGN_ACCESSORY_RADIUS = 8;

//
// Interface: EnableNotificationCell ()
//

@interface EnableNotificationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageViewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageViewImageLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *notficationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enableViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *enableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enableImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *enableImageView;

@end

//
// Implementation: EnableNotificationCell
//

@implementation EnableNotificationCell

+ (void)initialize {
    
    DESIGN_BACKGROUND_COLOR = [UIColor colorWithRed:56./255. green:56./255. blue:56./255. alpha:1];
    DESIGN_ACCESSORY_COLOR = [UIColor colorWithRed:97./255. green:97./255. blue:97./255. alpha:1];
    DESIGN_MESSAGE_COLOR = [UIColor colorWithRed:195./255. green:195./255. blue:195./255. alpha:1];
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.containerView.backgroundColor = DESIGN_BACKGROUND_COLOR;
    
    self.notificationImageViewImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.notificationImageViewImageLeadingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabel.font = Design.FONT_MEDIUM30;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = TwinmeLocalizedString(@"application_warning_notification_title", nil);
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM26;
    self.messageLabel.textColor = DESIGN_MESSAGE_COLOR;
    self.messageLabel.text = TwinmeLocalizedString(@"application_warning_notification_description", nil);
    
    self.enableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.enableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.enableViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.enableViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.enableView.clipsToBounds = YES;
    self.enableView.userInteractionEnabled = YES;
    self.enableView.layer.cornerRadius = DESIGN_ACCESSORY_RADIUS;
    self.enableView.backgroundColor = DESIGN_ACCESSORY_COLOR;
    
    UITapGestureRecognizer *tapInfoGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInfoTapGesture:)];
    [self.enableView addGestureRecognizer:tapInfoGestureRecognizer];
    
    self.enableImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.enableImageView.tintColor = [UIColor whiteColor];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bind {
    
    [self updateFont];
    [self updateColor];
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.enableNotificationDelegate respondsToSelector:@selector(didTapInfoEnableNotification)]) {
        [self.enableNotificationDelegate didTapInfoEnableNotification];
    }
}

- (void)updateFont {
    
    self.titleLabel.font = Design.FONT_MEDIUM30;
    self.messageLabel.font = Design.FONT_MEDIUM26;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
}
@end
