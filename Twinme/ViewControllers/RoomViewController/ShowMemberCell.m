/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ShowMemberCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: ShowMemberCell ()
//

@interface ShowMemberCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *memberView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *memberLabel;

@end

//
// Implementation: ShowMemberCell
//

#undef LOG_TAG
#define LOG_TAG @"ShowMemberCell"

@implementation ShowMemberCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
        
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.clipsToBounds = YES;
    
    self.memberViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.memberView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
    self.memberView.layer.cornerRadius = self.memberViewHeightConstraint.constant * 0.5;
    self.memberView.clipsToBounds = YES;
    
    self.memberLabel.font = Design.FONT_BOLD44;
    self.memberLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar memberCount:(NSInteger)memberCount {
    
    if (name) {
        if (avatar) {
            self.memberView.hidden = YES;
            self.avatarView.hidden = NO;
            self.avatarView.image = avatar;
        } else {
            self.memberView.hidden = NO;
            self.memberView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
            self.memberLabel.textColor = Design.FONT_COLOR_DEFAULT;
            self.memberLabel.text = [name substringToIndex:1].capitalizedString;
            self.avatarView.hidden = YES;
        }
    } else {
        self.memberView.hidden = NO;
        self.memberView.backgroundColor = Design.MAIN_COLOR;
        self.memberLabel.textColor = [UIColor whiteColor];
        self.memberLabel.text = [NSString stringWithFormat:@"+%ld", (long)memberCount];
        self.avatarView.hidden = YES;
    }
}

@end

