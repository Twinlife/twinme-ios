/*
 *  Copyright (c) 2014-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Shiyi Gu (Shiyi.Gu@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <Twinlife/TLAccountService.h>
#import <Twinlife/TLAccountMigrationService.h>
#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLRepositoryService.h>
#import <Twinlife/TLTwincodeFactoryService.h>
#import <Twinlife/TLTwincodeInboundService.h>
#import <Twinlife/TLTwincodeOutboundService.h>
#import <Twinlife/TLManagementService.h>
#import <Twinlife/TLImageService.h>
#import <Twinlife/TLPeerCallService.h>
#import <Twinlife/TLCryptoService.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTyping.h>
#import <Twinme/TLRoomCommand.h>
#import <Twinme/TLRoomCommandResult.h>
#import <Twinme/TLRoomConfigResult.h>

#import "Configuration.h"

static NSString *APPLICATION_NAME = @"twinme";

#define NOTIFICATION_REFRESH_DELAY  (0.5)

//
// Implementation: Configuration
//

@implementation Configuration

- (instancetype)init {
    
    self = [super initWithName:APPLICATION_NAME applicationVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] serializers:@[[[TLMessageSerializer alloc] init], [[TLTypingSerializer alloc] init], [[TLRoomCommandSerializer alloc] init], [[TLRoomCommandResultSerializer alloc] init], [[TLRoomConfigResultSerializer alloc] init]] enableKeepAlive:YES enableSetup:YES enableCaches:YES enableReports:YES enableInvocations:YES enableSpaces:NO refreshBadgeDelay:NOTIFICATION_REFRESH_DELAY];
    
    if (self) {
        self.accountServiceConfiguration.defaultAuthenticationAuthority = TLAccountServiceAuthenticationAuthorityDevice;
        self.accountServiceConfiguration.serviceOn = true;
        self.conversationServiceConfiguration.serviceOn = true;
        self.conversationServiceConfiguration.enableScheduler = true;

        // Database conversation locking is enabled when the NotificationServiceExtension is used.
        if (@available(iOS 13.0, *)) {
            self.conversationServiceConfiguration.lockIdentifier = 1;
        } else {
            self.conversationServiceConfiguration.lockIdentifier = 0;
        }
        self.managementServiceConfiguration.saveEnvironment = true;
        self.connectivityServiceConfiguration.serviceOn = true;
        self.notificationServiceConfiguration.serviceOn = true;
        self.peerConnectionServiceConfiguration.serviceOn = true;
        self.peerConnectionServiceConfiguration.acceptIncomingCalls = true;
        self.peerConnectionServiceConfiguration.enableAudioVideo = true;
        self.repositoryServiceConfiguration.serviceOn = true;
        self.twincodeFactoryServiceConfiguration.serviceOn = true;
        self.twincodeInboundServiceConfiguration.serviceOn = true;
        self.twincodeOutboundServiceConfiguration.serviceOn = true;
        self.twincodeOutboundServiceConfiguration.enableTwincodeRefresh = true;
        self.imageServiceConfiguration.serviceOn = true;
        self.peerCallServiceConfiguration.serviceOn = true;
        self.accountMigrationServiceConfiguration.serviceOn = true;
        self.cryptoServiceConfiguration.serviceOn = true;
    }
    return self;
}

@end
