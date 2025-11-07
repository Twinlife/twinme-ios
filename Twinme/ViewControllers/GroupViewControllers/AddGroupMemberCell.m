/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AddGroupMemberCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AddGroupMemberCell ()
//

@interface AddGroupMemberCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: AddGroupMemberCell
//

#undef LOG_TAG
#define LOG_TAG @"AddGroupMemberCell"

@implementation AddGroupMemberCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
    
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkView.clipsToBounds = YES;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    self.certifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
    self.contentView.alpha = 1.0;
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar isCertified:(BOOL)isCertified hideSeparator:(BOOL)hideSeparator {
    
    self.avatarView.hidden = NO;
    self.avatarView.image = avatar;
    self.nameLabel.text = name;
    self.separatorView.hidden = hideSeparator;
    
    self.certifiedRelationImageView.hidden = !isCertified;
    
    [self updateFont];
}

- (void)setChecked:(BOOL)checked {
    DDLogVerbose(@"%@ setChecked: %@", LOG_TAG, checked ? @"NO" : @"YES");
    
    if (_checked == checked) {
        return;
    }
    _checked = checked;
    
    if (_checked) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
}

- (void)setSelectable:(BOOL)selectable {
    DDLogVerbose(@"%@ setSelectable: %@", LOG_TAG, selectable ? @"NO" : @"YES");
    
    _selectable = selectable;
    
    if (!_selectable) {
        self.avatarView.alpha = 0.5;
        self.checkMarkImageView.alpha = 0.5;
        self.nameLabel.alpha = 0.5;
        self.separatorView.alpha = 0.5;
    } else {
        self.avatarView.alpha = 1.0;
        self.checkMarkImageView.alpha = 1.0;
        self.nameLabel.alpha = 1.0;
        self.separatorView.alpha = 1.0;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

@end
