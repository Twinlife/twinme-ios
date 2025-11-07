/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import <Twinme/TLCapabilities.h>

@interface AbstractCapabilitiesViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL allowAudioCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) TLVideoZoomable zoomable;
@property (nonatomic) BOOL discreetRelation;
@property (nonatomic) BOOL scheduleEnable;

- (void)initViews;

- (BOOL)isGroupCapabilities;

@end
