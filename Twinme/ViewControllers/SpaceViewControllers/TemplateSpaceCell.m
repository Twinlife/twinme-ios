/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "TemplateSpaceCell.h"

#import <TwinmeCommon/Design.h>
#import "UITemplateSpace.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: TemplateSpaceCell ()
//

@interface TemplateSpaceCell ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: TemplateSpaceCell
//

#undef LOG_TAG
#define LOG_TAG @"TemplateSpaceCell"

@implementation TemplateSpaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.spaceImageViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.spaceImageViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    self.spaceImageView.clipsToBounds = YES;
    self.spaceImageView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceImageViewHeightConstraint.constant;
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = Design.MAIN_COLOR;
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceLabel.font = Design.FONT_REGULAR34;
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
    

    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant / 2.0;
    self.colorView.clipsToBounds = YES;
    self.colorView.hidden = YES;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.spaceImageView.image = nil;
    self.spaceLabel.text = nil;
}

- (void)bindWithSpace:(UITemplateSpace *)uiTemplateSpace hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithSpace: %@", LOG_TAG, uiTemplateSpace);
        
    if ([uiTemplateSpace getImage]) {
        self.spaceImageView.image = [uiTemplateSpace getImage];
        self.spaceAvatarLabel.hidden = YES;
    } else {
        self.spaceImageView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        self.spaceImageView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
        if ([uiTemplateSpace getColor]) {
            self.spaceAvatarLabel.textColor = [UIColor colorWithHexString:[uiTemplateSpace getColor] alpha:1.0];
        } else {
            self.spaceAvatarLabel.textColor = Design.MAIN_COLOR;
        }
        self.spaceAvatarLabel.text = [NSString firstCharacter:[uiTemplateSpace getSpace]];
    }
    
    if ([uiTemplateSpace getColor]) {
        self.colorView.hidden = NO;
        self.colorView.backgroundColor = [UIColor colorWithHexString:[uiTemplateSpace getColor] alpha:1.0];
    } else {
        self.colorView.hidden = YES;
        self.colorView.backgroundColor = Design.BACKGROUND_COLOR_BLUE;
    }
    
    NSMutableAttributedString *nameAttributedString = [[NSMutableAttributedString alloc] initWithString:[uiTemplateSpace getSpace] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    if ([uiTemplateSpace getProfile]) {
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[uiTemplateSpace getProfile] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    }
    self.spaceLabel.attributedText = nameAttributedString;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
