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

#import <Utils/NSString+Utils.h>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateInfoLabel;
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
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR30;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.annotationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.annotationImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.dateInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateInfoLabel.font = Design.FONT_MEDIUM28;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)bindWithAnnotation:(UIAnnotation *)uiAnnotation hideSeparator:(BOOL)hideSeparator backgroundColor:(UIColor *)backgroundColor {
    DDLogVerbose(@"%@ bindWithAnnotation: %@", LOG_TAG, uiAnnotation);
    
    self.backgroundColor = backgroundColor;
    self.nameLabel.text = uiAnnotation.name;
    self.avatarView.image = uiAnnotation.avatar;
    self.nameLabel.font = Design.FONT_REGULAR30;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (uiAnnotation.annotationType == TLDescriptorAnnotationTypeLike && uiAnnotation.uiReaction) {
        self.annotationImageView.image = uiAnnotation.uiReaction.reactionImage;
        self.annotationImageView.tintColor = uiAnnotation.uiReaction.reactionTintColor;
        self.annotationImageView.hidden = NO;
        self.dateInfoLabel.hidden = YES;
    } else if (uiAnnotation.annotationType == TLDescriptorAnnotationTypeError && uiAnnotation.value > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:uiAnnotation.name attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        
        NSString *message = @"";
        TLBaseServiceErrorCode errorCode = [TLConversationService toErrorCode:(int)uiAnnotation.value];
        if (errorCode == TLBaseServiceErrorCodeFeatureNotSupportedByPeer) {
            message = TwinmeLocalizedString(@"info_item_view_not_delivered_update", nil);
        } else if (errorCode == TLBaseServiceErrorCodeExpired) {
            message = TwinmeLocalizedString(@"info_item_view_not_delivered_expiration", nil);
        } else if (errorCode == TLBaseServiceErrorCodeNoStorageSpace) {
            message = TwinmeLocalizedString(@"info_item_view_not_delivered_storage", nil);
        }
        
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:message attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM28, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        
        self.nameLabel.attributedText = attributedString;
        self.annotationImageView.hidden = NO;
        self.annotationImageView.image = [UIImage imageNamed:@"ItemStateNotSent"];
        self.annotationImageView.tintColor = [UIColor clearColor];
        self.dateInfoLabel.text = @"";
    } else {
        if (uiAnnotation.value > 0) {
            self.dateInfoLabel.text = [NSString formatItemTimeInterval:uiAnnotation.value  / 1000];
        } else if (uiAnnotation.annotationType != TLDescriptorAnnotationTypePoll) {
            self.dateInfoLabel.text = @"-";
        } else {
            self.dateInfoLabel.text = @"";
        }
        
        self.annotationImageView.hidden = YES;
        self.dateInfoLabel.hidden = NO;
    }
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
    [self updateFont];
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.dateInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    
    self.dateInfoLabel.font = Design.FONT_MEDIUM28;
}

@end
