/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "DeleteSpaceConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define AVATAR_ROTATION 20

//
// Interface: DeleteSpaceConfirmView ()
//

@interface DeleteSpaceConfirmView ()

@property (weak, nonatomic) IBOutlet UILabel *spaceAvatarLabel;

@end



//
// Implementation: DeleteSpaceConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"DeleteSpaceConfirmView"

@implementation DeleteSpaceConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DeleteSpaceConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message spaceName:(NSString *)spaceName spaceStyle:(NSString *)spaceStyle avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon {
    DDLogVerbose(@"%@ initWithTitle: %@ message: %@ spaceName: %@ spaceStyle: %@ avatar: %@ icon: %@", LOG_TAG, title, message, spaceName, spaceStyle, avatar, icon);
 
    [super initWithTitle:title message:message avatar:avatar icon:icon];
    
    if (!avatar) {
        self.spaceAvatarLabel.hidden = NO;
        self.spaceAvatarLabel.text = [NSString firstCharacter:spaceName];
        
        if (spaceStyle) {
            self.avatarContainerView.backgroundColor = [UIColor colorWithHexString:spaceStyle alpha:1.0];
        } else {
            self.avatarContainerView.backgroundColor = Design.MAIN_COLOR;
        }
    } else {
        self.spaceAvatarLabel.hidden = YES;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD68;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    
    self.avatarContainerView.clipsToBounds = YES;
    self.avatarContainerView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.avatarContainerView.layer.borderWidth = 3.f;
    self.avatarContainerView.layer.borderColor = [UIColor whiteColor].CGColor;

    self.avatarContainerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.avatarContainerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.avatarContainerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.avatarContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarContainerView.layer.masksToBounds = NO;
        
    self.avatarContainerView.transform = CGAffineTransformMakeRotation(AVATAR_ROTATION * M_PI / 180);
    
    self.avatarView.layer.cornerRadius = Design.POPUP_RADIUS;

    self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm_deletion", nil);
    
    self.iconView.backgroundColor = Design.DELETE_COLOR_RED;
    self.bulletView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.confirmView.backgroundColor = Design.DELETE_COLOR_RED;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
