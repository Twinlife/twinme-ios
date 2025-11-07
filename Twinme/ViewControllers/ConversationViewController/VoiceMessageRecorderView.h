/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: VoiceMessageRecorderView
//

@class ConversationViewController;

@interface VoiceMessageRecorderView : UIView

@property (nonatomic) NSURL *url;

- (instancetype)initWithFrame:(CGRect)frame conversationViewController:(ConversationViewController *)conversationViewController;

- (void)updateSendView:(CGFloat)height trailing:(CGFloat)imageTrailing;

- (void)updateColor;

- (void)updateFont;

- (BOOL)isVoiceMessageToSend;

- (void)resetViews;

- (BOOL)isRecording;

- (void)startRecording;

- (void)pauseRecording;

@end
