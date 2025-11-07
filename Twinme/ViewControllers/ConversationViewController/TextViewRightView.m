/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TextViewRightView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_HEIGHT_INSET = 24;

//
// Interface: TextViewRightView
//

#undef LOG_TAG
#define LOG_TAG @"TextViewRightView"


@interface TextViewRightView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;

@end

//
// Implementation: TextViewRightView
//

@implementation TextViewRightView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TextViewRightView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = self.frame;
    [self addSubview:view];
    
    self.backgroundColor = [UIColor clearColor];
        
    CGFloat sendViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
            
    self.cameraViewHeightConstraint.constant = sendViewHeight;
        
    self.cameraView.backgroundColor = [UIColor clearColor];
    
    self.cameraImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.recordViewHeightConstraint.constant = sendViewHeight;
        
    self.microView.backgroundColor = [UIColor clearColor];

    self.recordImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ initViews", LOG_TAG);

    self.cameraImageView.tintColor = Design.MAIN_COLOR;
    self.recordImageView.tintColor = Design.MAIN_COLOR;
}

@end
