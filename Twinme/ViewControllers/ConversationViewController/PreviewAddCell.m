/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "PreviewAddCell.h"

#import <TwinmeCommon/Design.h>

#import "UIPreviewFile.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PreviewAddCell ()
//

@interface PreviewAddCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;

@end

//
// Implementation: PreviewAddCell
//

#undef LOG_TAG
#define LOG_TAG @"PreviewAddCell"

@implementation PreviewAddCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
            
    self.addViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.addViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.addViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.addViewTrailingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addView.clipsToBounds = YES;
    self.addView.backgroundColor = [UIColor blackColor];
    self.addView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.addView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.addView.layer.borderWidth = 2;
    
    self.addImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
}

@end
