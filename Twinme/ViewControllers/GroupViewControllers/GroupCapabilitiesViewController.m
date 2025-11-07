/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLGroup.h>
#import <Twinme/TLSchedule.h>

#import "GroupCapabilitiesViewController.h"

#import <TwinmeCommon/EditGroupService.h>
#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: GroupCapabilitiesViewController ()
//

@interface GroupCapabilitiesViewController () <EditGroupServiceDelegate>

@property (nonatomic) TLGroup *group;
@property (nonatomic) TLCapabilities *capabilities;

@property (nonatomic) EditGroupService *editGroupService;

@end

//
// Implementation: GroupCapabilitiesViewController
//

#undef LOG_TAG
#define LOG_TAG @"GroupCapabilitiesViewController"

@implementation GroupCapabilitiesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _editGroupService = [[EditGroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (BOOL)isGroupCapabilities {
    DDLogVerbose(@"%@ isGroupCapabilities", LOG_TAG);
    
    return YES;
}

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    if (!self.group.capabilities) {
        self.capabilities = [[TLCapabilities alloc]init];
    } else {
        self.capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.group.capabilities attributeValue]];
    }
    
    self.allowAudioCall = self.group.capabilities.hasAudio;
    self.allowVideoCall = self.group.capabilities.hasVideo;
    self.scheduleEnable = self.group.capabilities.schedule.enabled;
    
    if (self.self.group.capabilities.schedule.timeRanges.count > 0) {
        TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[self.group.capabilities.schedule.timeRanges objectAtIndex:0];
        self.scheduleStartDate = dateTimeRange.start.date;
        self.scheduleStartTime = dateTimeRange.start.time;
        self.scheduleEndDate = dateTimeRange.end.date;
        self.scheduleEndTime = dateTimeRange.end.time;
    }
}

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
}

#pragma mark - EditGroupServiceDelegate

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
    [self finish];
}

- (void)onLeaveGroup:(TLGroup *)group memberTwincodeId:(NSUUID *)memberTwincodeId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberTwincodeId: %@", LOG_TAG, group, memberTwincodeId);
    
    [self finish];
}

- (void)onDeleteGroup:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
    if ([self.group isOwner]) {
        [self finish];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
        
    [self setNavigationTitle:TwinmeLocalizedString(@"contact_capabilities_view_controller_call_settings", nil)];
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)saveCapabilities {
    DDLogVerbose(@"%@ saveCapabilities", LOG_TAG);
    
    if (!self.canSave) {
        return;
    }
    
    [self.capabilities setCapAudioWithValue:self.allowAudioCall];
    [self.capabilities setCapVideoWithValue:self.allowVideoCall];
    
    if (self.scheduleStartDate) {
        TLDateTime *startDateTime = [[TLDateTime alloc]initWithDate:self.scheduleStartDate time:self.scheduleStartTime];
        TLDateTime *endDateTime = [[TLDateTime alloc]initWithDate:self.scheduleEndDate time:self.scheduleEndTime];
        TLDateTimeRange *dateTimeRange = [[TLDateTimeRange alloc]initWithStart:startDateTime end:endDateTime];
        
        TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[dateTimeRange]];
        [schedule setEnabled:self.scheduleEnable];
        [self.capabilities setSchedule:schedule];
    }
    
    [self.editGroupService updateGroupWithCapabilities:self.group capabilities:self.capabilities];    
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editGroupService) {
        [self.editGroupService dispose];
        self.editGroupService = nil;
    }
    
    [super finish];
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.group && self.group.capabilities.hasAudio == self.allowAudioCall && self.group.capabilities.hasVideo == self.allowVideoCall && self.group.capabilities.schedule.enabled == self.scheduleEnable) {
        if (!self.canSave) {
            return;
        }
        self.canSave = NO;
    } else {
        if (self.canSave) {
            return;
        }
        self.canSave = YES;
    }
}

@end
