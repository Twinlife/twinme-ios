/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DefaultProfileCell.h"

#import <Utils/NSString+Utils.h>

#import "SideMenuViewController.h"

#import <TwinmeCommon/Design.h>

//
// Interface: DefaultProfileCell ()
//

@interface DefaultProfileCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addContactView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;

@end

//
// Implementation: DefaultProfileCell
//

#undef LOG_TAG
#define LOG_TAG @"DefaultProfileCell"

@implementation DefaultProfileCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.userInteractionEnabled = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTapGesture:)];
    [self.avatarView addGestureRecognizer:avatarTapGesture];
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.userInteractionEnabled = YES;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.font = Design.FONT_REGULAR34;
    
    UITapGestureRecognizer *nameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTapGesture:)];
    [self.nameLabel addGestureRecognizer:nameTapGesture];
    
    self.addContactViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.addContactView.userInteractionEnabled = YES;
    self.addContactView.isAccessibilityElement = YES;
    self.addContactView.clipsToBounds = YES;
    self.addContactView.layer.cornerRadius = self.addContactViewHeightConstraint.constant * 0.5;
    self.addContactView.backgroundColor = Design.MAIN_COLOR;
    self.addContactView.accessibilityLabel = TwinmeLocalizedString(@"add_contact_view_controller_title", nil);
    
    UITapGestureRecognizer *addContactTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddContactTapGesture:)];
    [self.addContactView addGestureRecognizer:addContactTapGesture];
    
    self.contactImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar {
    
    self.avatarView.image = avatar;
    self.nameLabel.text = name;
    
    [self updateFont];
    [self updateColor];
}

- (void)handleAddContactTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(addContact)]) {
            [self.delegate addContact];
        }
    }
}

- (void)handleProfileTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(showProfile)]) {
            [self.delegate showProfile];
        }
    }
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.addContactView.backgroundColor = Design.MAIN_COLOR;
}

@end
