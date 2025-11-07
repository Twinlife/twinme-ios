/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "FullScreenVideoCell.h"

#import "FullScreenMediaViewController.h"

#import <AVKit/AVKit.h>

#import <Twinlife/TLConversationService.h>

#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/Utils.h>
#import "VideoItem.h"
#import "PeerVideoItem.h"
#import "Item.h"
#import "UIPreviewMedia.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "UIView+GradientBackgroundColor.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_BAR_COLOR;
static NSArray* DESIGN_BACKGROUND_GRADIENT_COLORS_BLACK;

static const CGFloat DESIGN_ACTION_PREVIEW_HEIGHT = 380;

//
// Interface: FullScreenVideoCell ()
//

@interface FullScreenVideoCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTimerLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoTimerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoDurationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderTrailingConstraint;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic) AVPlayer *videoPlayer;
@property (nonatomic) AVPlayerLayer *playerLayer;
@property id<NSObject> timeObserverToken;

@property (nonatomic) TLVideoDescriptor *videoDescriptor;
@property (nonatomic) AudioSessionManager *audioSessionManager;

@end

//
// Implementation: FullScreenVideoCell
//

#undef LOG_TAG
#define LOG_TAG @"FullScreenVideoCell"

@implementation FullScreenVideoCell

+ (void)initialize {

    DESIGN_BAR_COLOR = [UIColor colorWithRed:111./255. green:111./255. blue:111./255. alpha:1];
    
    UIColor* black1 = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0];
    UIColor* black2 = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.58];
    DESIGN_BACKGROUND_GRADIENT_COLORS_BLACK = @[(id)black1.CGColor, (id)black2.CGColor];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.actionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.actionView.backgroundColor = [UIColor blackColor];
        
    self.playViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.playView.userInteractionEnabled = YES;
    UITapGestureRecognizer *playPauseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayViewTapGestureRecognizer:)];
    [self.playView addGestureRecognizer:playPauseTapGesture];
    
    self.playImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
    self.playImageView.tintColor = [UIColor whiteColor];
    
    self.videoTimerLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoTimerLabel.textColor = [UIColor whiteColor];
    self.videoTimerLabel.font = Design.FONT_REGULAR28;
    
    self.videoDurationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoDurationLabel.textColor = [UIColor whiteColor];
    self.videoDurationLabel.font = Design.FONT_REGULAR28;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.text = TwinmeLocalizedString(@"conversation_view_controller_unsupported_media", nil);
    self.messageLabel.hidden = YES;
    
    self.sliderTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sliderHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sliderLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sliderTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    UIView *currentPositionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.sliderHeightConstraint.constant, self.sliderHeightConstraint.constant)];
    currentPositionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    currentPositionView.layer.borderColor = [UIColor blackColor].CGColor;
    currentPositionView.layer.borderWidth = 2;
    currentPositionView.layer.cornerRadius = self.sliderHeightConstraint.constant * 0.5f;

    UIGraphicsBeginImageContextWithOptions(currentPositionView.bounds.size, NO, 0.0);
    [currentPositionView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = DESIGN_BAR_COLOR;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.playerLayer = nil;
    self.actionView.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoPlayer.currentItem];
}

- (void)layoutSubviews {
    DDLogVerbose(@"%@ layoutSubviews", LOG_TAG);
    
    [super layoutSubviews];
    
    if (self.playerLayer) {
        self.playerLayer.frame = self.bounds;
    }
}

- (void)bindWithItem:(Item *)item {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, item);
    
    if (item.isPeerItem) {
        PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
        self.videoDescriptor = peerVideoItem.videoDescriptor;
    } else {
        VideoItem *videoItem = (VideoItem *)item;
        self.videoDescriptor = videoItem.videoDescriptor;
    }
    
    if (self.videoDescriptor) {
        self.messageLabel.hidden = YES;
        NSURL *videoURL = [self.videoDescriptor getURL];
        
        self.videoPlayer = [AVPlayer playerWithURL:videoURL];
        if (!self.playerLayer) {
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
            self.playerLayer.frame = self.bounds;
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [self.contentView.layer addSublayer:self.playerLayer];
            [self.contentView bringSubviewToFront:self.actionView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoPlayer.currentItem];
        }
    }
}

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia {
    DDLogVerbose(@"%@ bindWithPreviewMedia: %@", LOG_TAG, previewMedia);
    
    NSURL *videoURL = previewMedia.url;
    
    self.actionViewHeightConstraint.constant = DESIGN_ACTION_PREVIEW_HEIGHT * Design.HEIGHT_RATIO;
    
    self.videoPlayer = [AVPlayer playerWithURL:videoURL];
    if (!self.playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.contentView.layer addSublayer:self.playerLayer];
        [self.contentView bringSubviewToFront:self.actionView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoPlayer.currentItem];
        
        if (CMTIME_IS_NUMERIC([self.videoPlayer.currentItem.asset duration])) {
            float duration = CMTimeGetSeconds([self.videoPlayer.currentItem.asset duration]);
            if (duration != 0) {
                CGFloat sliderWidth = Design.DISPLAY_WIDTH - (self.sliderLeadingConstraint.constant + self.sliderTrailingConstraint.constant);
                float interval = 0.5f * duration / sliderWidth;
                
                FullScreenVideoCell __weak *weakSelf = self;
                self.timeObserverToken = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
                                          ^(CMTime time) {
                    [weakSelf updateProgressTime];
                }];
                
                self.slider.value = 0;
                self.slider.minimumValue = 0.0;
                self.slider.maximumValue = duration;
                
                self.videoDurationLabel.text = [NSString convertWithInterval:duration format:@"mm:ss"];
                self.videoTimerLabel.text = [NSString convertWithInterval:0 format:@"mm:ss"];
            } else {
                self.videoDurationLabel.text = @"";
                self.videoTimerLabel.text = @"";
            }
            self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPlay"];
        } else {
            self.videoDurationLabel.text = @"";
            self.videoTimerLabel.text = @"";
        }
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    DDLogVerbose(@"%@ sliderValueChanged: %@", LOG_TAG, sender);
    
    if (self.videoPlayer) {
        [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.slider.value, NSEC_PER_SEC)];
    }
}

- (void)stopVideo {
    DDLogVerbose(@"%@ stopVideo", LOG_TAG);
    
    if (self.videoPlayer) {
        [self.videoPlayer pause];
        [self.videoPlayer.currentItem seekToTime:kCMTimeZero completionHandler:nil];
        self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPlay"];
    }
    [self.audioSessionManager releaseAudioSession];
}

- (BOOL)isVideoFormatSupported {
    DDLogVerbose(@"%@ isVideoFormatSupported", LOG_TAG);
    
    if (self.videoPlayer && self.videoPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        return YES;
    }
    
    return NO;
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if ([self.fullScreenMediaDelegate respondsToSelector:@selector(didTapContent)]) {
        [self.fullScreenMediaDelegate didTapContent];
    }
    
    self.actionView.hidden = !self.actionView.hidden;
}

- (void)handlePlayViewTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handlePlayViewTapGestureRecognizer: %@", LOG_TAG, recognizer);
    
    if ([self videoPlayerIsPlaying]) {
        [self.videoPlayer pause];
        self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPlay"];
    } else {
        [self.videoPlayer play];
        self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
    }
}

#pragma mark - Video

- (CMTime)currentTime {
    DDLogVerbose(@"%@ currentTime", LOG_TAG);
    
    return self.videoPlayer.currentTime;
}

- (void)itemDidFinishPlaying {
    DDLogVerbose(@"%@ itemDidFinishPlaying", LOG_TAG);
    
    [self.videoPlayer.currentItem seekToTime:kCMTimeZero completionHandler:nil];
    [self.audioSessionManager releaseAudioSession];
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPlay"];
}

- (BOOL)videoPlayerIsPlaying {
    DDLogVerbose(@"%@ videoPlayerIsPlaying", LOG_TAG);
    
    if ((self.videoPlayer.rate != 0) && (self.videoPlayer.error == nil)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)playVideoWithAudioSession:(nonnull AudioSessionManager *)audioSession {
    DDLogVerbose(@"%@ playVideoWithAudioSession: %@", LOG_TAG, audioSession);
    
    self.audioSessionManager = audioSession;
    [audioSession startAudioSessionWithCompletion:^{
        [self.videoPlayer play];
    }];
    self.playImageView.image = [UIImage imageNamed:@"AudioItemPlayerPause"];
    
    if (CMTIME_IS_NUMERIC([self.videoPlayer.currentItem.asset duration])) {
        float duration = CMTimeGetSeconds([self.videoPlayer.currentItem.asset duration]);
        if (duration != 0) {
            CGFloat sliderWidth = Design.DISPLAY_WIDTH - (self.sliderLeadingConstraint.constant + self.sliderTrailingConstraint.constant);
            float interval = 0.5f * duration / sliderWidth;
            
            FullScreenVideoCell __weak *weakSelf = self;
            self.timeObserverToken = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
                                      ^(CMTime time) {
                [weakSelf updateProgressTime];
            }];
            
            self.slider.value = 0;
            self.slider.minimumValue = 0.0;
            self.slider.maximumValue = duration;
            
            self.videoDurationLabel.text = [NSString convertWithInterval:duration format:@"mm:ss"];
            self.messageLabel.hidden = YES;
        } else {
            self.videoDurationLabel.text = @"";
            self.videoTimerLabel.text = @"";
            self.messageLabel.hidden = NO;
        }
    } else {
        self.videoDurationLabel.text = @"";
        self.videoTimerLabel.text = @"";
    }
}

- (void)updateProgressTime {
    DDLogVerbose(@"%@ updateProgressTime", LOG_TAG);
    
    if (CMTIME_IS_NUMERIC(self.videoPlayer.currentTime)) {
        double time = CMTimeGetSeconds(self.videoPlayer.currentTime);
        self.slider.value = time;
        self.videoTimerLabel.text = [NSString convertWithInterval:time format:@"mm:ss"];
    } else {
        self.slider.value = 0;
        self.videoTimerLabel.text = @"";
    }
}


@end
