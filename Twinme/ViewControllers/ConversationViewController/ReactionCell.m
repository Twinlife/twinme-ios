/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ReactionCell.h"

#import "UIReaction.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ReactionCell ()
//

@interface ReactionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *reactionView;

@end

//
// Implementation: ReactionCell
//

#undef LOG_TAG
#define LOG_TAG @"ReactionCell"

@implementation ReactionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.reactionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)bindWithReaction:(UIReaction *)uiReaction {
    DDLogVerbose(@"%@ bindWithReaction: %@", LOG_TAG, uiReaction);
        
    self.reactionView.image = uiReaction.reactionImage;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.backgroundColor = [UIColor clearColor];
}

@end
