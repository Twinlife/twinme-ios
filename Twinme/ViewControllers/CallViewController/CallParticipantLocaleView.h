/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractCallParticipantView.h"

#import <WebRTC/RTCVideoTrack.h>

//
// Interface: CallParticipantLocaleView
//

@interface CallParticipantLocaleView : AbstractCallParticipantView

@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) BOOL isAudioMute;
@property (nonatomic) BOOL isVideoMute;
@property (nonatomic) BOOL isFrontCamera;
@property (nonatomic) RTC_OBJC_TYPE(RTCVideoTrack) *localVideoTrack;

- (void)enableFrontCamera:(BOOL)frontCamera;

@end
