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

#import "SpaceCell.h"

#import <TwinmeCommon/Design.h>
#import "UISpace.h"
#import "UIColor+Hex.h"
#import "UIView+GradientBackgroundColor.h"
#import "SpaceSetting.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *BACKGROUND_CURRENT_SPACE_COLOR;

//
// Interface: SpaceCell ()
//

@interface SpaceCell ()<UIGestureRecognizerDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkContentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationContentMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic) UISpace *uiSpace;
@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) UITapGestureRecognizer *tapGesture;

@end

//
// Implementation: SpaceCell
//

#undef LOG_TAG
#define LOG_TAG @"SpaceCell"

@implementation SpaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    self.longPressGesture.delegate = self;
    self.longPressGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:self.longPressGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInsideContent:)];
    self.tapGesture.delegate = self;
    self.tapGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:self.tapGesture];
    [self.tapGesture requireGestureRecognizerToFail:self.longPressGesture];
    
    BACKGROUND_CURRENT_SPACE_COLOR = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    
    self.spaceImageViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.spaceImageViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    self.spaceImageView.clipsToBounds = YES;
    self.spaceImageView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceImageViewHeightConstraint.constant;
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceLabel.font = Design.FONT_REGULAR34;
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.currentSpaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.currentSpaceImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.currentSpaceImageView.layer.cornerRadius = self.currentSpaceImageViewHeightConstraint.constant / 2.0;
    
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.colorView.layer.cornerRadius = self.colorViewHeightConstraint.constant / 2.0;
    self.colorView.clipsToBounds = YES;
    self.colorView.hidden = YES;
    
    self.currentSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.currentSpaceViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.currentSpaceViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.currentSpaceView.clipsToBounds = YES;
    self.currentSpaceView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.currentSpaceViewHeightConstraint.constant;
    
    self.notificationMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.notificationMarkViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.notificationMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.notificationMarkView.backgroundColor = Design.WHITE_COLOR;
    self.notificationMarkView.layer.cornerRadius = self.notificationMarkViewHeightConstraint.constant / 2.0;
    
    self.notificationMarkContentViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.notificationContentMarkView.layer.cornerRadius = self.notificationMarkContentViewHeightConstraint.constant / 2.0;
    
    UIColor *red1 = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:1.0];
    UIColor *red2 = [UIColor colorWithRed:254./255. green:4./255. blue:121./255. alpha:1.0];
    UIColor *red3 = [UIColor colorWithRed:254./255. green:0 blue:122./255. alpha:1.0];
    [self.notificationContentMarkView setupGradientBackgroundFromColors:@[(id)red1.CGColor, (id)red2.CGColor, (id)red3.CGColor] opacity:1.0 orientation:GradientOrientationDiagonal];
    
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

- (void)bindWithSpace:(UISpace *)uiSpace hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithSpace: %@", LOG_TAG, uiSpace);
    
    self.uiSpace = uiSpace;
    
    if (uiSpace.space.avatarId) {
        self.spaceImageView.backgroundColor = [UIColor clearColor];
        self.spaceImageView.image = uiSpace.avatarSpace;
        self.spaceAvatarLabel.hidden = YES;
    } else {
        self.spaceImageView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        self.spaceImageView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
        if (uiSpace.spaceSettings.style) {
            self.spaceImageView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
        } else {
            self.spaceImageView.backgroundColor = Design.MAIN_COLOR;
        }
        self.spaceAvatarLabel.text = [NSString firstCharacter:uiSpace.nameSpace];
    }
    
    if (uiSpace.spaceSettings.style) {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
        self.currentSpaceImageView.tintColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
        self.colorView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
    } else {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.currentSpaceImageView.tintColor =[UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.colorView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
    }
    
    if (uiSpace.hasNotification) {
        self.notificationMarkView.hidden = NO;
    } else {
        self.notificationMarkView.hidden = YES;
    }
    
    if (uiSpace.isCurrentSpace) {
        self.currentSpaceView.hidden = NO;
        self.currentSpaceImageView.hidden = NO;
    } else {
        self.currentSpaceView.hidden = YES;
        self.currentSpaceImageView.hidden = YES;
    }
    
    NSMutableAttributedString *nameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.uiSpace.nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    if ([self.uiSpace hasProfile]) {
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [nameAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.uiSpace.nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    self.spaceLabel.attributedText = nameAttributedString;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

#pragma mark - UILongPressGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan && [self.spaceActionDelegate respondsToSelector:@selector(activeSpace:)]) {
        [self.spaceActionDelegate activeSpace:self.uiSpace];
    }
}

- (void)onTapInsideContent:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.spaceActionDelegate respondsToSelector:@selector(showSpace:)]) {
        [self.spaceActionDelegate showSpace:self.uiSpace];
    }
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.notificationMarkView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
