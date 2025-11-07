/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>

#import "ShareExtensionSpaceCell.h"

#import "DesignExtension.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *BACKGROUND_CURRENT_SPACE_COLOR;

//
// Interface: ShareExtensionSpaceCell ()
//

@interface ShareExtensionSpaceCell ()<UIGestureRecognizerDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *currentSpaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *currentSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) TLSpace *space;

@end

//
// Implementation: ShareExtensionSpaceCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionSpaceCell"

@implementation ShareExtensionSpaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = DesignExtension.WHITE_COLOR;
    
    BACKGROUND_CURRENT_SPACE_COLOR = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    
    self.spaceImageViewHeightConstraint.constant = DesignExtension.AVATAR_HEIGHT;
    self.spaceImageViewLeadingConstraint.constant = DesignExtension.AVATAR_LEADING;
    
    self.spaceImageView.clipsToBounds = YES;
    self.spaceImageView.layer.cornerRadius = DesignExtension.SPACE_RADIUS_RATIO * self.spaceImageViewHeightConstraint.constant;
    
    self.spaceLabelLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    self.spaceLabel.font = DesignExtension.FONT_REGULAR34;
    self.spaceLabel.textColor = DesignExtension.FONT_COLOR_DEFAULT;
    
    self.spaceAvatarLabel.font = DesignExtension.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    
    self.currentSpaceImageViewHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    self.currentSpaceImageViewTrailingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    self.currentSpaceImageView.layer.cornerRadius = self.currentSpaceImageViewHeightConstraint.constant / 2.0;
    
    self.colorViewHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    self.colorViewTrailingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant / 2.0;
    self.colorView.clipsToBounds = YES;
    self.colorView.hidden = YES;
    
    self.currentSpaceViewHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    self.currentSpaceViewWidthConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.currentSpaceViewLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    self.currentSpaceView.clipsToBounds = YES;
    self.currentSpaceView.layer.cornerRadius = DesignExtension.SPACE_RADIUS_RATIO * self.currentSpaceViewHeightConstraint.constant;
    
    self.separatorViewLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.separatorViewBottomConstraint.constant = DesignExtension.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = DesignExtension.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = DesignExtension.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.spaceImageView.image = nil;
    self.spaceLabel.text = nil;
}

- (void)bindWithSpace:(TLSpace *)space avatar:(UIImage *)avatar currentSpace:(BOOL)isCurrentSpace hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithSpace: %@ hideSeparator: %@", LOG_TAG, space, hideSeparator ? @"YES":@"NO");
    
    self.space = space;
    
    if (self.space.avatarId) {
        self.spaceImageView.image = avatar;
        self.spaceAvatarLabel.hidden = YES;
    } else {
        self.spaceImageView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        if (self.space.settings.style) {
            self.spaceImageView.backgroundColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
        } else {
            self.spaceImageView.backgroundColor = DesignExtension.MAIN_COLOR;
        }
        
        self.spaceAvatarLabel.text = [NSString firstCharacter:space.settings.name];
    }
    
    if (self.space.settings.style) {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
        self.currentSpaceImageView.tintColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
        self.colorView.backgroundColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
    } else {
        self.currentSpaceView.backgroundColor = DesignExtension.MAIN_COLOR;
        self.currentSpaceImageView.tintColor = DesignExtension.MAIN_COLOR;
        self.colorView.backgroundColor = DesignExtension.MAIN_COLOR;
    }
    
    if (isCurrentSpace) {
        self.currentSpaceView.hidden = NO;
        self.currentSpaceImageView.hidden = NO;
    } else {
        self.currentSpaceView.hidden = YES;
        self.currentSpaceImageView.hidden = YES;
    }
    
    NSMutableAttributedString *nameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.space.settings.name attributes:[NSDictionary dictionaryWithObjectsAndKeys:DesignExtension.FONT_MEDIUM34, NSFontAttributeName, DesignExtension.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    if (self.space.profile) {
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.space.profile.name attributes:[NSDictionary dictionaryWithObjectsAndKeys:DesignExtension.FONT_MEDIUM32, NSFontAttributeName, DesignExtension.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    }
        
    self.spaceLabel.attributedText = nameAttributedString;
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = DesignExtension.WHITE_COLOR;
    self.separatorView.backgroundColor = DesignExtension.SEPARATOR_COLOR_GREY;
}

@end
