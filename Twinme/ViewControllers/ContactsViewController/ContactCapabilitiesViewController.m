/*
 *  Copyright (c) 2021-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSchedule.h>

#import <Utils/NSString+Utils.h>

#import "MessageSettingsViewController.h"
#import "ContactCapabilitiesViewController.h"
#import "MenuSelectValueView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditContactCapabilitiesService.h>

#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ContactCapabilitiesViewController ()
//

@interface ContactCapabilitiesViewController () <EditContactCapabilitiesServiceDelegate, MenuSelectValueDelegate>

@property (nonatomic) TLContact *contact;
@property (nonatomic) TLCapabilities *identityCapabilities;

@property (nonatomic) EditContactCapabilitiesService *editCapabilitiesService;

@end

//
// Implementation: ContactCapabilitiesViewController
//

#undef LOG_TAG
#define LOG_TAG @"ContactCapabilitiesViewController"

@implementation ContactCapabilitiesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _editCapabilitiesService = [[EditContactCapabilitiesService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    
    if (!self.contact.identityCapabilities) {
        self.identityCapabilities = [[TLCapabilities alloc]init];
    } else {
        self.identityCapabilities = [[TLCapabilities alloc] initWithCapabilities:[self.contact.identityCapabilities attributeValue]];
    }
    
    self.allowAudioCall = self.contact.identityCapabilities.hasAudio;
    self.allowVideoCall = self.contact.identityCapabilities.hasVideo;
    self.zoomable = self.contact.identityCapabilities.zoomable;
    self.discreetRelation = self.contact.identityCapabilities.hasDiscreet;
    self.scheduleEnable = self.contact.identityCapabilities.schedule.enabled;
    
    if (self.contact.identityCapabilities.schedule.timeRanges.count > 0) {
        TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[self.contact.identityCapabilities.schedule.timeRanges objectAtIndex:0];
        self.scheduleStartDate = dateTimeRange.start.date;
        self.scheduleStartTime = dateTimeRange.start.time;
        self.scheduleEndDate = dateTimeRange.end.date;
        self.scheduleEndTime = dateTimeRange.end.time;
    }
}

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeCallZoomable];
    [menuSelectValueView setSelectedValueWithValue:(int)self.zoomable];
    [menuSelectValueView openMenu];
}

#pragma mark - MenuSelectValueDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];
    
    self.zoomable = value;
    
    [self setUpdated];
    [self reloadData];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
}

#pragma mark - EditContactCapabilitiesServiceDelegate

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    [self finish];
}

- (void)onDeleteContact:(nonnull NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);

    [self finish];
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
    
    [self.identityCapabilities setCapAudioWithValue:self.allowAudioCall];
    [self.identityCapabilities setCapVideoWithValue:self.allowVideoCall];
    [self.identityCapabilities setCapDiscreetWithValue:self.discreetRelation];
    [self.identityCapabilities setZoomableWithValue:self.zoomable];
    
    if (self.scheduleStartDate) {
        TLDateTime *startDateTime = [[TLDateTime alloc]initWithDate:self.scheduleStartDate time:self.scheduleStartTime];
        TLDateTime *endDateTime = [[TLDateTime alloc]initWithDate:self.scheduleEndDate time:self.scheduleEndTime];
        TLDateTimeRange *dateTimeRange = [[TLDateTimeRange alloc]initWithStart:startDateTime end:endDateTime];
        
        TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[dateTimeRange]];
        [schedule setEnabled:self.scheduleEnable];
        [self.identityCapabilities setSchedule:schedule];
    }
    
    [self.editCapabilitiesService updateIdentityWithContact:self.contact identityCapabilities:self.identityCapabilities];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editCapabilitiesService) {
        [self.editCapabilitiesService dispose];
        self.editCapabilitiesService = nil;
    }
    
    [super finish];
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.contact && self.contact.identityCapabilities.hasAudio == self.allowAudioCall && self.contact.identityCapabilities.hasVideo == self.allowVideoCall && self.contact.identityCapabilities.hasDiscreet == self.discreetRelation && self.contact.identityCapabilities.zoomable == self.zoomable && self.contact.identityCapabilities.schedule.enabled == self.scheduleEnable) {
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
