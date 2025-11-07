/*
 *  Copyright (c) 2021-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "VoiceMessageRecorderView.h"

#import <Twinme/TLSpace.h>
#import <Twinme/TLTwinmeContext.h>

#import <AVFoundation/AVFoundation.h>

#import <Utils/NSString+Utils.h>

#import "ConversationViewController.h"

#import "AudioTrackView.h"
#import "RecordView.h"
#import "UIView+Toast.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import <TwinmeCommon/Utils.h>

static CGFloat DESIGN_LINE_SPACE = 2;
static CGFloat DESIGN_LINE_WIDTH = 1;

static CGFloat DESIGN_AUDIO_TRACK_INITIAL_LEADING = 10;

static CGFloat MIN_DECIBEL = 45;

//
// Interface: VoiceMessageRecorderView ()
//

@interface VoiceMessageRecorderView () <AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet RecordView *recordView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordIconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *recordIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseRecordViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *pauseRecordView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseRecordIconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pauseRecordIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *playImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *pauseImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trashViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trashViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *trashView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trashImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *trashImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioTrackContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackScrollViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *trackScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentScrollView;
@property (nonatomic) UIView *trackView;

@property (weak, nonatomic) ConversationViewController *conversationViewController;

@property (nonatomic) AVAudioRecorder *recorder;
@property NSTimer *timer;
@property NSTimer *playTimer;
@property float recorderTime;

@property float startLine;

@property float currentTime;
@property BOOL isPaused;
@property BOOL isTouchCanceled;
@property BOOL sendFile;

@property NSURL *recordURL;

@end

@implementation VoiceMessageRecorderView

- (instancetype)initWithFrame:(CGRect)frame conversationViewController:(ConversationViewController *)conversationViewController {
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"VoiceMessageRecorderView" owner:self options:nil];
    VoiceMessageRecorderView  *nibView = [objects objectAtIndex:0];
    nibView.frame = frame;
    nibView.conversationViewController = conversationViewController;
    _isTouchCanceled = NO;
    _recorderTime = 0;
    _sendFile = NO;
    return nibView;
}

- (void)updateSendView:(CGFloat)height trailing:(CGFloat)trailing  {
    
    self.audioTrackContainerViewHeightConstraint.constant = height;
    
    self.sendViewHeightConstraint.constant = height;
    self.sendViewLeadingConstraint.constant = trailing;
    self.sendViewTrailingConstraint.constant = trailing;
    self.sendView.layer.cornerRadius = height * 0.5;
    
    self.recordViewHeightConstraint.constant = height;
    self.recordView.layer.cornerRadius = height * 0.5;
    
    self.pauseRecordViewHeightConstraint.constant = height;
    self.pauseRecordView.layer.cornerRadius = height * 0.5;
    
    self.trashViewHeightConstraint.constant = height;
    self.trashView.layer.cornerRadius = height * 0.5;
}

- (void)startRecording {
    
    if (!self.recorder && !self.url) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".m4a"];
        self.recordURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.trackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.audioTrackContainerViewHeightConstraint.constant)];
            [self.contentScrollView addSubview:self.trackView];
        });
        
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordURL settings:recordSetting error:nil];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        [self.recorder record];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
        self.pauseRecordView.hidden = NO;
        self.trashView.hidden = NO;
        self.recordView.hidden = YES;
        self.sendView.alpha = 1.f;
    }
}

- (void)pauseRecording {
    
    if (self.recorder && [self.recorder isRecording]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        self.recorderTime += self.recorder.currentTime;
        [self.recorder stop];
        [self mergeAudioTrack];
        
        self.trashView.hidden = NO;
        self.sendView.alpha = 1.f;
        
        self.playView.hidden = NO;
        self.trackScrollViewLeadingConstraint.constant = self.playViewHeightConstraint.constant + self.playViewLeadingConstraint.constant + (DESIGN_AUDIO_TRACK_INITIAL_LEADING * Design.WIDTH_RATIO);
        
        self.pauseRecordView.hidden = YES;
        self.recordView.hidden = NO;
    }
}

#pragma mark - NSObject(UINibLoadingAdditions)

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.recordViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.recordViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.recordView.userInteractionEnabled = YES;
    self.recordView.isAccessibilityElement = YES;
    self.recordView.backgroundColor = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:1.0];
    self.recordView.clipsToBounds = YES;
    self.recordView.layer.cornerRadius = self.recordViewHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *recordTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecordViewTapGesture:)];
    [self.recordView addGestureRecognizer:recordTapGesture];
    
    self.recordIconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.recordIconView.backgroundColor = [UIColor whiteColor];
    self.recordIconView.clipsToBounds = YES;
    self.recordIconView.layer.cornerRadius = self.recordIconViewHeightConstraint.constant * 0.5;
    
    self.pauseRecordViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.pauseRecordView.userInteractionEnabled = YES;
    self.pauseRecordView.isAccessibilityElement = YES;
    self.pauseRecordView.clipsToBounds = YES;
    self.pauseRecordView.backgroundColor = Design.WHITE_COLOR;
    self.pauseRecordView.layer.cornerRadius = self.pauseRecordViewHeightConstraint.constant * 0.5;
    self.pauseRecordView.layer.borderColor = Design.MAIN_COLOR.CGColor;
    self.pauseRecordView.layer.borderWidth = 1.0;
    self.pauseRecordView.hidden = YES;
    
    UITapGestureRecognizer *pauseRecordTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePauseRecordViewTapGesture:)];
    [self.pauseRecordView addGestureRecognizer:pauseRecordTapGesture];
    
    self.pauseRecordIconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.pauseRecordIconView.tintColor = Design.MAIN_COLOR;
    
    self.playViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.playView.userInteractionEnabled = YES;
    self.playView.isAccessibilityElement = YES;
    self.playView.clipsToBounds = YES;
    self.playView.backgroundColor = [UIColor whiteColor];
    self.playView.layer.cornerRadius = self.playViewHeightConstraint.constant * 0.5;
    self.playView.hidden = YES;
    UITapGestureRecognizer *playTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayViewTapGesture:)];
    [self.playView addGestureRecognizer:playTapGesture];
    
    self.playImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playImageView.tintColor = Design.MAIN_COLOR;
    
    self.pauseImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.pauseImageView.tintColor = Design.MAIN_COLOR;
    self.pauseImageView.hidden = YES;
    
    self.trashViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.trashViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.trashView.userInteractionEnabled = YES;
    self.trashView.backgroundColor = Design.BLACK_COLOR;
    self.trashView.clipsToBounds = YES;
    self.trashView.hidden = YES;
    self.trashView.layer.cornerRadius = self.trashViewHeightConstraint.constant * 0.5;
    UITapGestureRecognizer *trashTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTrashViewTapGesture:)];
    [self.trashView addGestureRecognizer:trashTapGesture];
    self.trashView.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_record_title", nil);
    
    self.trashImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.trashImageView.tintColor = Design.WHITE_COLOR;
    
    self.audioTrackContainerViewHeightConstraint.constant = Design.FONT_REGULAR32.lineHeight + (24 * Design.HEIGHT_RATIO * 2);
    self.audioTrackContainerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.audioTrackContainerView.backgroundColor = Design.MAIN_COLOR;
    self.audioTrackContainerView.clipsToBounds = YES;
    self.audioTrackContainerView.layer.cornerRadius = self.audioTrackContainerViewHeightConstraint.constant * 0.5;
    
    self.trackScrollViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.trackScrollView.showsHorizontalScrollIndicator = NO;
    
    self.sendViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.clipsToBounds = YES;
    self.sendView.alpha = 0.5f;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    
    UITapGestureRecognizer *sendTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendViewTapGesture:)];
    [self.sendView addGestureRecognizer:sendTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendViewLongPress:)];
    [self.sendView addGestureRecognizer:longPressGesture];
    
    self.sendImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.timerLabelLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.timerLabelTrailingConstraint.constant *= Design.HEIGHT_RATIO;
    self.timerLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.timerLabel.font = Design.FONT_REGULAR28;
    [self.timerLabel setTextColor:[UIColor whiteColor]];
    self.timerLabel.text = [NSString convertWithInterval:0 format:@"mm:ss"];
}

- (void)resetViews {
        
    [self stopRecording];
    self.startLine = 0;
    self.recorderTime = 0;
    
    if (self.trackView) {
        [self.trackView removeFromSuperview];
        self.trackView = nil;
    }
    
    self.recordView.hidden = NO;
    self.trashView.hidden = YES;
    self.playView.hidden = YES;
    self.pauseImageView.hidden = YES;
    self.playImageView.hidden = NO;
    self.sendView.alpha = 0.5f;
    self.timerLabel.text = [NSString convertWithInterval:0 format:@"mm:ss"];
    self.trackScrollViewLeadingConstraint.constant = DESIGN_AUDIO_TRACK_INITIAL_LEADING * Design.WIDTH_RATIO;
    [self.trackScrollView setContentOffset:CGPointMake(0, 0)];
    
    [[AudioPlayerManager sharedInstance] stop];
    self.isPaused = NO;
    
    if (self.playTimer) {
        [self.playTimer invalidate];
    }
    self.currentTime = 0;
    self.url = nil;
    
    [self.conversationViewController resetVoiceRecorder];
}

- (BOOL)isVoiceMessageToSend {
    
    return self.url && !self.recorder.isRecording;
}

- (BOOL)isRecording {
    
    return self.recorder.isRecording;
}

#pragma mark - RecordViewDelegate methods

- (void)recordViewTouchBegan:(RecordView *)recordView {
    
    self.isTouchCanceled = NO;
    if (!self.recorder && !self.url) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        [Utils hapticFeedback:UIImpactFeedbackStyleHeavy hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
        
        [UIView animateWithDuration:0.15 animations:^{
            self.recordView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            if (!self.isTouchCanceled) {
                [self startRecording];
            }
        }];
    }
}

- (void)recordViewTouchEnd:(RecordView *)recordView {
    
    if (self.recorder) {
        if ([self.recorder isRecording]) {
            [self.recorder stop];
            self.trashView.hidden = NO;
            self.sendView.alpha = 1.f;
            
            self.playView.hidden = NO;
            self.trackScrollViewLeadingConstraint.constant = self.playViewHeightConstraint.constant + self.playViewLeadingConstraint.constant + (DESIGN_AUDIO_TRACK_INITIAL_LEADING * Design.WIDTH_RATIO);
        }
    } else {
        [self stopRecording];
    }
}

- (void)recordViewTouchCancel:(RecordView *)recordView {
    
    self.isTouchCanceled = YES;
    
    if (self.recorder) {
        if ([self.recorder isRecording]) {
            [self.recorder stop];
        }
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    } else {
        [self stopRecording];
    }
    
    if (self.url) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.url.path error:nil];
        self.url = nil;
    }
    
    [self resetViews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_record_start_record",nil)];
    });
}


#pragma mark - Private methods

- (void)handleSendViewTapGesture:(UITapGestureRecognizer *)recognizer {
    
    if (self.url || self.recordURL) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
        
        if (self.recorder.isRecording) {
            self.recorderTime += self.recorder.currentTime;
            [self.recorder stop];
            self.sendFile = YES;
            if (![self mergeAudioTrack]) {
                [self.conversationViewController pushFileWithPath:self.url.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:YES allowCopy:twinmeApplication.allowCopyFile];
                self.url = nil;
                
                recognizer.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
                [UIView animateWithDuration:0.15 animations:^{
                    recognizer.view.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                    [self resetViews];
                }];
            }
            
        } else {
            [self.conversationViewController pushFileWithPath:self.url.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:YES allowCopy:twinmeApplication.allowCopyFile];
            self.url = nil;
            
            recognizer.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
            [UIView animateWithDuration:0.15 animations:^{
                recognizer.view.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                [self resetViews];
            }];
        }
    }
}

- (void)handleSendViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (self.url && !self.recorder.isRecording) {
        [self.conversationViewController openMenuSendOptions];
    }
}

- (void)handleTrashViewTapGesture:(UITapGestureRecognizer *)recognizer {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.url) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.url.path error:nil];
        self.url = nil;
    }
    
    if (self.recordURL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.recordURL.path error:nil];
        self.recordURL = nil;
    }
    
    recognizer.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.15 animations:^{
        recognizer.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [self resetViews];
    }];
}

- (void)handleRecordViewTapGesture:(UITapGestureRecognizer *)recognizer {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".m4a"];
    self.recordURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordURL settings:recordSetting error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    self.pauseRecordView.hidden = NO;
    self.recordView.hidden = YES;
    
    self.playView.hidden = YES;
    self.sendView.alpha = 1.f;
    self.trackScrollViewLeadingConstraint.constant = DESIGN_AUDIO_TRACK_INITIAL_LEADING * Design.WIDTH_RATIO;
}

- (void)handlePauseRecordViewTapGesture:(UITapGestureRecognizer *)recognizer {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
    
    [self pauseRecording];
}

- (void)handlePlayViewTapGesture:(UITapGestureRecognizer *)recognizer {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
    
    if (self.playTimer) {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }

    AudioPlayerManager *audioPlayerManager = [AudioPlayerManager sharedInstance];
    if (!self.isPaused) {
        self.pauseImageView.hidden = NO;
        self.playImageView.hidden = YES;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        [audioPlayerManager playWithURL:self.url currentTime:self.currentTime startPlayingBlock:^{
            self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        }];
        self.isPaused = YES;
    } else {
        self.pauseImageView.hidden = YES;
        self.playImageView.hidden = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [audioPlayerManager pause];
        self.isPaused = NO;
        self.currentTime = [audioPlayerManager currentPlaybackTime];
    }
}

- (void)updateTime:(NSTimer *)timer {
    
    AudioPlayerManager *audioPlayerManager = [AudioPlayerManager sharedInstance];
    float duration = [audioPlayerManager duration];
    float currentPlaybackTime = [audioPlayerManager currentPlaybackTime];
    float progress = currentPlaybackTime / duration;
    float contentOffset = 0;
    if ((self.trackView.frame.size.width * progress) > self.trackScrollView.frame.size.width) {
        contentOffset = self.startLine - self.trackScrollView.frame.size.width;
    }
    [self.trackScrollView setContentOffset:CGPointMake(contentOffset, 0) animated:YES];
    
    self.timerLabel.text = [NSString convertWithInterval:duration - currentPlaybackTime format:@"mm:ss"];
    
    if (![audioPlayerManager isPlaying]) {
        self.pauseImageView.hidden = YES;
        self.playImageView.hidden = NO;
        [audioPlayerManager stop];
        self.isPaused = NO;
        [self.playTimer invalidate];
        self.playTimer = nil;
        self.currentTime = 0;
        if ([UIDevice currentDevice].proximityMonitoringEnabled) {
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
}

- (void)stopRecording {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.recorder) {
        self.recorder = nil;
    }
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateTime {
    
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        
        float averagePowerForChannel = [self.recorder averagePowerForChannel:0];
        [self drawLine:averagePowerForChannel];
        self.timerLabel.text = [NSString convertWithInterval:self.recorderTime + self.recorder.currentTime format:@"mm:ss"];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    [self stopRecording];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    
    [self stopRecording];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    
    [self stopRecording];
}

- (void)drawLine:(float)power {
    
    float scaleFactor = self.trackView.frame.size.height / MIN_DECIBEL;
    float lineHeight = (MIN_DECIBEL - fabsf(power)) * scaleFactor;
    float startY = (self.trackView.frame.size.height - lineHeight) / 2;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
    [lineBezierPath moveToPoint:CGPointMake(self.startLine, startY)];
    [lineBezierPath addLineToPoint:CGPointMake(self.startLine, startY + lineHeight)];
    lineLayer.path = lineBezierPath.CGPath;
    lineLayer.lineWidth = DESIGN_LINE_WIDTH;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.fillColor = [UIColor whiteColor].CGColor;
    lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.trackView.layer addSublayer:lineLayer];
    
    self.startLine += DESIGN_LINE_SPACE;
    
    [self.trackView setFrame:CGRectMake(0, 0, self.startLine, self.trackView.frame.size.height)];
    [self.trackScrollView setContentSize:CGSizeMake(self.trackView.frame.size.width, self.trackScrollView.frame.size.height)];
    
    float contentOffset = 0;
    if (self.startLine > self.trackScrollView.frame.size.width) {
        contentOffset = self.startLine - self.trackScrollView.frame.size.width;
    }
    
    [self.trackScrollView setContentOffset:CGPointMake(contentOffset, 0) animated:YES];
}

- (BOOL)mergeAudioTrack {
    
    if (!self.url) {
        self.url = self.recordURL;
        return NO;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVURLAsset *originalAsset = [[AVURLAsset alloc] initWithURL:self.url options:nil];
    AVURLAsset *lastAsset = [[AVURLAsset alloc] initWithURL:self.recordURL options:nil];
    
    NSError* error = nil;
    
    NSArray<AVAssetTrack *> *originalTracks = [originalAsset tracksWithMediaType:AVMediaTypeAudio];
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, originalAsset.duration);
    [compositionTrack insertTimeRange:timeRange
                              ofTrack:[originalTracks objectAtIndex:0]
                               atTime:kCMTimeZero
                                error:&error];
    if (error) {
        return NO;
    }
    
    NSArray<AVAssetTrack *> *newTracks = [lastAsset tracksWithMediaType:AVMediaTypeAudio];
    timeRange = CMTimeRangeMake(kCMTimeZero, lastAsset.duration);
    [compositionTrack insertTimeRange:timeRange
                              ofTrack:[newTracks objectAtIndex:0]
                               atTime:originalAsset.duration
                                error:&error];
    
    if (error) {
        return NO;
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (!exportSession) {
        return NO;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".m4a"];
    exportSession.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            self.url = exportSession.outputURL;
            
            if (self.recordURL) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:self.recordURL.path error:nil];
                self.recordURL = nil;
            }
            
            if (self.sendFile) {
                self.sendFile = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
                    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
                    [self.conversationViewController pushFileWithPath:exportSession.outputURL.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:YES allowCopy:twinmeApplication.allowCopyFile];

                    [self resetViews];
                });
                
                self.url = nil;
            }
        }
    }];
    
    return YES;
}

- (void)updateFont {
    
    self.timerLabel.font = Design.FONT_REGULAR28;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
}

@end
