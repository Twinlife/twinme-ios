/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import <Twinme/TLCapabilities.h>

@class TLDate;
@class TLTime;

@interface AbstractCapabilitiesViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL allowAudioCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) TLVideoZoomable zoomable;
@property (nonatomic) BOOL discreetRelation;
@property (nonatomic) BOOL scheduleEnable;
@property (nonatomic) BOOL canSave;

@property (nonatomic) TLDate *scheduleStartDate;
@property (nonatomic) TLTime *scheduleStartTime;
@property (nonatomic) TLDate *scheduleEndDate;
@property (nonatomic) TLTime *scheduleEndTime;

- (void)initViews;

- (BOOL)isGroupCapabilities;

- (void)openMenuSelectValue;

- (void)saveCapabilities;

- (void)setUpdated;

- (void)reloadData;

@end
