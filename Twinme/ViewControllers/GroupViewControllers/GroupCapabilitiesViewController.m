/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLGroup.h>

#import "GroupCapabilitiesViewController.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: GroupCapabilitiesViewController ()
//

@interface GroupCapabilitiesViewController ()

@property (nonatomic) TLGroup *group;

@end

//
// Implementation: GroupCapabilitiesViewController
//

#undef LOG_TAG
#define LOG_TAG @"GroupCapabilitiesViewController"

@implementation GroupCapabilitiesViewController

- (BOOL)isGroupCapabilities {
    DDLogVerbose(@"%@ isGroupCapabilities", LOG_TAG);
    
    return YES;
}

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
}

@end
