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
#import "PremiumFeatureConfirmView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditContactCapabilitiesService.h>

#import "SwitchView.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ContactCapabilitiesViewController ()
//

@interface ContactCapabilitiesViewController () <EditContactCapabilitiesServiceDelegate>

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

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editCapabilitiesService) {
        [self.editCapabilitiesService dispose];
        self.editCapabilitiesService = nil;
    }
    
    [super finish];
}

@end
