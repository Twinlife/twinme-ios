/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "LocationAnnotationView.h"

#import <TwinmeCommon/Design.h>
#import "RoundedShadowView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: LocationAnnotationView ()
//

@interface LocationAnnotationView ()

@property (weak, nonatomic) IBOutlet RoundedShadowView *avatarViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

//
// Implementation: LocationAnnotationView
//

#undef LOG_TAG
#define LOG_TAG @"LocationAnnotationView"

@implementation LocationAnnotationView

#pragma mark - NSObject(UINibLoadingAdditions)

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.avatarView.image = nil;
}

- (void)bindWithAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ bindWithAvatar: %@", LOG_TAG, avatar);
    
    float avatarViewShadowRadius = 6 * Design.HEIGHT_RATIO;
    [self.avatarViewContainer setShadowWithColor:Design.SHADOW_COLOR_DEFAULT shadowRadius:avatarViewShadowRadius shadowOffset:CGSizeMake(0, avatarViewShadowRadius) shadowOpacity:0.4];
    
    self.avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarView.layer.borderWidth = 6.0f * Design.HEIGHT_RATIO;
    self.avatarView.layer.cornerRadius = self.frame.size.height * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.avatarView.image = avatar;
}

@end
