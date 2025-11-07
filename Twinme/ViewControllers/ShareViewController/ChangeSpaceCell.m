/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>

#import "ChangeSpaceCell.h"

#import <TwinmeCommon/Design.h>
#import "UISpace.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *BACKGROUND_CURRENT_SPACE_COLOR;

//
// Interface: ChangeSpaceCell ()
//

@interface ChangeSpaceCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorSpaceViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *currentSpaceView;

@property (nonatomic) UISpace *uiSpace;

@end

//
// Implementation: ChangeSpaceCell
//

#undef LOG_TAG
#define LOG_TAG @"ChangeSpaceCell"

@implementation ChangeSpaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
        
    BACKGROUND_CURRENT_SPACE_COLOR = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
        
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.spaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceImageView.clipsToBounds = YES;
    self.spaceImageView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceImageViewHeightConstraint.constant;
    self.spaceImageView.backgroundColor = [UIColor blueColor];
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceLabel.font = Design.FONT_BOLD36;
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.colorSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorSpaceViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.colorSpaceView.layer.cornerRadius = self.colorSpaceViewHeightConstraint.constant / 2.0;
    
    self.currentSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.currentSpaceViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.currentSpaceViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.currentSpaceView.clipsToBounds = YES;
    self.currentSpaceView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.currentSpaceViewHeightConstraint.constant;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.spaceImageView.image = nil;
    self.spaceLabel.text = nil;
}

- (void)bindWithSpace:(UISpace *)uiSpace {
    DDLogVerbose(@"%@ bindWithSpace: %@", LOG_TAG, uiSpace);
    
    self.uiSpace = uiSpace;
    
    if (uiSpace.space.avatarId) {
        self.spaceImageView.image = uiSpace.avatarSpace;
    } else {
        self.spaceImageView.image = nil;
        if (uiSpace.spaceSettings.style) {
            self.spaceImageView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
        } else {
            self.spaceImageView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
        }
    }
    
    if (uiSpace.spaceSettings.style) {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
        self.colorSpaceView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
    } else {
        self.currentSpaceView.backgroundColor = Design.MAIN_COLOR;
        self.colorSpaceView.backgroundColor = Design.MAIN_COLOR;
    }
    
    NSString *spaceName = @"";
    NSString *profileName = @"";
    if (uiSpace.nameSpace) {
        spaceName = uiSpace.nameSpace;
    }

    if (uiSpace.nameProfile) {
        profileName = uiSpace.nameProfile;
        
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:spaceName attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM44, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];

    if (![profileName isEqualToString:@""]) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:profileName attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    self.spaceLabel.attributedText = attributedString;
    
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end
