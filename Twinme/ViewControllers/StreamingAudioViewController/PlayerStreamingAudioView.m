/*
 *  Copyright (c) 2022-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "PlayerStreamingAudioView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_CONTAINER_COLOR [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1]
#define DESIGN_PLACEHOLDER_COLOR [UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1]

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_MIN_MARGIN_ACTION = 34;
static const CGFloat DESIGN_ARTWORK_RADIUS = 6;


//
// Interface: PlayerStreamingAudioView ()
//

@interface PlayerStreamingAudioView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverPlaceholderViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *coverPlaceholderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artworkImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artworkImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *songLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *songLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stopViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *stopView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stopImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stopImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stopImageView;

@property (nonatomic) BOOL isLocalPlayer;

@end

#undef LOG_TAG
#define LOG_TAG @"PlayerStreamingAudioView"

@implementation PlayerStreamingAudioView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogVerbose(@"%@ initWithCoder", LOG_TAG);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *playerView = [[[NSBundle mainBundle] loadNibNamed:@"PlayerStreamingAudioView" owner:self options:nil] objectAtIndex:0];
        playerView.frame = self.bounds;
        playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:playerView];
        [self initViews];
    }
    
    return self;
}

- (void)setSound:(nonnull NSString *)title artwork:(nullable UIImage *)artwork {
    DDLogVerbose(@"%@ setSound: %@ artwork: %@", LOG_TAG, title, artwork);
    
    self.songLabel.text = title;
    
    if (artwork) {
        self.artworkImageView.image = artwork;
        self.coverPlaceholderView.hidden = YES;
    } else {
        self.coverPlaceholderView.hidden = NO;
    }
}

- (void)resumeStreaming {
    DDLogVerbose(@"%@ resumeStreaming", LOG_TAG);
    
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
}

- (void)pauseStreaming {
    DDLogVerbose(@"%@ pauseStreaming", LOG_TAG);
    
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPlay"];
}

- (void)stopStreaming {
    DDLogVerbose(@"%@ stopStreaming", LOG_TAG);
    
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
    
    self.songLabel.text = @"";
    self.artworkImageView.image = nil;
    self.coverPlaceholderView.hidden = NO;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
                
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewWidthConstraint.constant = Design.DISPLAY_WIDTH - (DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO * 2);
    
    self.containerView.backgroundColor = DESIGN_CONTAINER_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.artworkImageView.backgroundColor = DESIGN_PLACEHOLDER_COLOR;
    self.artworkImageView.clipsToBounds = YES;
    self.artworkImageView.layer.cornerRadius = DESIGN_ARTWORK_RADIUS;
    self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.coverPlaceholderViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.coverPlaceholderView.hidden = YES;
    
    self.artworkImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.artworkImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.songLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.songLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.songLabel.font = Design.FONT_MEDIUM34;
    self.songLabel.textColor = [UIColor whiteColor];
    
    self.playViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.playImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.playView.userInteractionEnabled = YES;
    UITapGestureRecognizer *playTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handlePlayTapGesture:)];
    [self.playView addGestureRecognizer:playTapGestureRecognizer];
    
    self.playView.hidden = NO;
    
    self.playImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.playImageView.tintColor = [UIColor whiteColor];
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
    
    self.stopViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stopImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.stopView.userInteractionEnabled = YES;
    UITapGestureRecognizer *stopTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStopTapGesture:)];
    [self.stopView addGestureRecognizer:stopTapGestureRecognizer];
    
    self.stopImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.stopImageView.tintColor = [UIColor whiteColor];
}

- (void)handlePlayTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlePlayTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.playerStreamingAudioViewDelegate respondsToSelector:@selector(onStreamingPlayPause:)]) {
            [self.playerStreamingAudioViewDelegate onStreamingPlayPause:self];
        }
    }
}

- (void)handleStopTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStopTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.playerStreamingAudioViewDelegate respondsToSelector:@selector(onStreamingStop:)]) {
            [self.playerStreamingAudioViewDelegate onStreamingStop:self];
        }
    }
}

@end
