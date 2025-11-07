/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import <Utils/NSString+Utils.h>

#import "CallItem.h"

//
// Interface: CallItem
//

@implementation CallItem

- (instancetype)initWithCallDescriptor:(TLCallDescriptor *)callDescriptor {
    
    self = [super initWithType:ItemTypeCall descriptor:callDescriptor];
    
    if (self) {
        _callDescriptor = callDescriptor;
        self.copyAllowed = NO;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (NSString *)getInformation:(NSString *)contactName {
    
    NSString *callStatus = @"";
    switch (self.callDescriptor.terminateReason) {
        case TLPeerConnectionServiceTerminateReasonDecline:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_decline %@", nil), contactName];
            break;
            
        case TLPeerConnectionServiceTerminateReasonGone:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_gone %@", nil), contactName];
            break;
            
        case TLPeerConnectionServiceTerminateReasonBusy:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_busy %@", nil), contactName];
            break;
            
        case TLPeerConnectionServiceTerminateReasonRevoked:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_revoked %@", nil), contactName];
            break;
            
        case TLPeerConnectionServiceTerminateReasonNotAuthorized:
            callStatus = TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_not_authorized", nil);
            break;
            
        case TLPeerConnectionServiceTerminateReasonCancel:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_cancel %@", nil), contactName];
            break;
            
        case TLPeerConnectionServiceTerminateReasonTimeout:
            callStatus = [NSString stringWithFormat:TwinmeLocalizedString(@"info_item_view_controller_call_terminated_reason_timeout %@", nil), contactName];
            break;
            
        default:
            break;
    }
    
    return callStatus;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"CallItem\n"];
    [self appendTo:string];
    return string;
}

@end
