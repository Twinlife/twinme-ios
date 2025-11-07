/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SideSpaceCell.h"

#import <Utils/NSString+Utils.h>

#import <Twinme/TLSpace.h>

#import "SideMenuViewController.h"

#import <TwinmeCommon/Design.h>

#import "UISpace.h"
#import "UIColor+Hex.h"
#import "UIView+GradientBackgroundColor.h"

//
// Interface: SideSpaceCell ()
//

@interface SideSpaceCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentSpaceViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *currentSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *spaceView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMarkContentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationContentMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;

@property (nonatomic) UISpace *uiSpace;

@end

//
// Implementation: SideSpaceCell
//

#undef LOG_TAG
#define LOG_TAG @"SideSpaceCell"

@implementation SideSpaceCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInsideContent:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.currentSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.currentSpaceViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.currentSpaceViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.currentSpaceView.clipsToBounds = YES;
    self.currentSpaceView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.currentSpaceViewHeightConstraint.constant;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.avatarViewHeightConstraint.constant;
    self.avatarView.clipsToBounds = YES;
    
    self.spacesViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
    self.spaceView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spacesViewHeightConstraint.constant;
    self.spaceView.clipsToBounds = YES;
    
    self.nameLabel.font = Design.FONT_BOLD44;
    self.nameLabel.textColor = [UIColor whiteColor];
    
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
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.spaceLabel.font = Design.FONT_REGULAR24;
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
}

- (void)bindWithSpace:(UISpace *)uiSpace isCurrentSpace:(BOOL)isCurrentSpace isSecretSpace:(BOOL)isSecretSpace {
    
    self.uiSpace = uiSpace;
    
    if (!isSecretSpace) {
        self.spaceLabel.text = uiSpace.nameSpace;
        self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
        if (uiSpace.space.avatarId) {
            self.spaceView.hidden = YES;
            self.nameLabel.hidden = YES;
            self.avatarView.hidden = NO;
            self.avatarView.image = uiSpace.avatarSpace;
        } else if (uiSpace.space.settings.name) {
            self.avatarView.hidden = YES;
            self.spaceView.hidden = NO;
            self.nameLabel.hidden = NO;
            if (uiSpace.spaceSettings.style) {
                self.spaceView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
            } else {
                self.spaceView.backgroundColor =  Design.MAIN_COLOR;
            }
            self.nameLabel.text = [NSString firstCharacter:uiSpace.nameSpace];
        } else {
            self.avatarView.hidden = YES;
            self.spaceView.hidden = NO;
            self.nameLabel.hidden = YES;
        }
    } else {
        self.avatarView.hidden = YES;
        self.spaceView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.spaceView.backgroundColor = Design.BACKGROUND_COLOR_GREY;
        self.nameLabel.textColor =  Design.MAIN_COLOR;
        self.nameLabel.text = @"?";
        self.spaceLabel.text = @"";
    }
    
    self.currentSpaceView.hidden = !isCurrentSpace;
    self.currentSpaceView.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    if (uiSpace.spaceSettings.style) {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:uiSpace.spaceSettings.style alpha:1.0];
    } else {
        self.currentSpaceView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
    }
    
    if (uiSpace.hasNotification) {
        self.notificationMarkView.hidden = NO;
    } else {
        self.notificationMarkView.hidden = YES;
    }
    
    [self updateColor];
    [self updateFont];
}

#pragma mark - UILongPressGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan && [self.sideSpaceDelegate respondsToSelector:@selector(showSpace:)]) {
        [self.sideSpaceDelegate showSpace:self.uiSpace];
    }
}

- (void)onTapInsideContent:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.sideSpaceDelegate respondsToSelector:@selector(setCurrentSpace:)]) {
        [self.sideSpaceDelegate setCurrentSpace:self.uiSpace];
    }
}

- (void)updateColor {
    
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_BOLD44;
    self.spaceLabel.font = Design.FONT_REGULAR24;
}


@end
