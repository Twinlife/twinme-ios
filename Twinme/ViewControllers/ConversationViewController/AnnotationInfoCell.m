/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AnnotationInfoCell.h"

#import <Twinlife/TLConversationService.h>

#import <TwinmeCommon/Design.h>
#import "UIAnnotation.h"
#import "UIContact.h"
#import "UIReaction.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AnnotationInfoViewCell ()
//

@interface AnnotationInfoCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *annotationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: AnnotationInfoViewCell
//

#undef LOG_TAG
#define LOG_TAG @"AnnotationInfoViewCell"


@implementation AnnotationInfoCell

- (void)awakeFromNib {
    
    [super awakeFromNib];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.annotationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.annotationImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)bindWithAnnotation:(UIAnnotation *)uiAnnotation hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithAnnotation: %@", LOG_TAG, uiAnnotation);
    
    self.nameLabel.text = uiAnnotation.name;
    self.avatarView.image = uiAnnotation.avatar;
    self.annotationImageView.image = uiAnnotation.uiReaction.reactionImage;
    self.annotationImageView.tintColor = uiAnnotation.uiReaction.reactionTintColor;
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
    [self updateFont];
}

- (void)updateColor {
    
    self.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_REGULAR34;
}

@end
