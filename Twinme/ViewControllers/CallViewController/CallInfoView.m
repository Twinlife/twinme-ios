/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallInfoView.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_CONTAINER_COLOR [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1]

static const CGFloat DESIGN_CORNER_RADIUS = 14;


//
// Interface: CallInfoView ()
//

@interface CallInfoView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

#undef LOG_TAG
#define LOG_TAG @"CallInfoView"

@implementation CallInfoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogVerbose(@"%@ initWithCoder", LOG_TAG);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *playerView = [[[NSBundle mainBundle] loadNibNamed:@"CallInfoView" owner:self options:nil] objectAtIndex:0];
        playerView.frame = self.bounds;
        playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:playerView];
        [self initViews];
    }
    
    return self;
}

- (void)updateMessage:(NSString *)message {
    DDLogVerbose(@"%@ updateMessage: %@", LOG_TAG, message);
    
    self.messageLabel.text = message;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.backgroundColor = DESIGN_CONTAINER_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM34;
    self.messageLabel.textColor = [UIColor whiteColor];
}

@end
