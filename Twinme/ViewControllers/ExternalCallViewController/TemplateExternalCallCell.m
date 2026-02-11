/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "TemplateExternalCallCell.h"

#import <TwinmeCommon/Design.h>
#import "UITemplateExternalCall.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: TemplateExternalCallCell ()
//

@interface TemplateExternalCallCell ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *externalCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *externalCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *externalCallImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *externalCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *externalCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *externalCallLabel;
@property (weak, nonatomic) IBOutlet UILabel *externalCallAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: TemplateExternalCallCell
//

#undef LOG_TAG
#define LOG_TAG @"TemplateExternalCallCell"

@implementation TemplateExternalCallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.externalCallImageViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.externalCallImageViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    self.externalCallImageView.clipsToBounds = YES;
    self.externalCallImageView.layer.cornerRadius = self.externalCallImageViewHeightConstraint.constant * 0.5;
    
    self.externalCallAvatarLabel.font = Design.FONT_BOLD44;
    self.externalCallAvatarLabel.textColor = Design.MAIN_COLOR;
    
    self.externalCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.externalCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.externalCallLabel.font = Design.FONT_REGULAR34;
    self.externalCallLabel.textColor = Design.FONT_COLOR_DEFAULT;

    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.externalCallImageView.image = nil;
    self.externalCallLabel.text = nil;
}

- (void)bindWithTemplate:(UITemplateExternalCall *)uiTemplateExternalCall hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithTemplate: %@", LOG_TAG, uiTemplateExternalCall);
        
    if ([uiTemplateExternalCall getImage]) {
        self.externalCallImageView.image = [uiTemplateExternalCall getImage];
        self.externalCallAvatarLabel.hidden = YES;
    } else {
        self.externalCallImageView.image = nil;
        self.externalCallAvatarLabel.hidden = NO;
        self.externalCallImageView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
        self.externalCallAvatarLabel.text = [NSString firstCharacter:[uiTemplateExternalCall getName]];
    }
    
    self.externalCallLabel.text = [uiTemplateExternalCall getName];
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
