/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>


//
// Protocol: AddCallParticipantDelegate
//

@protocol AddCallParticipantDelegate <NSObject>

- (void)addParticipantsToCall:(nonnull NSMutableArray *)contacts;

@end

//
// Interface: AddCallParticipantViewController
//

@class TLContact;

@interface AddCallParticipantViewController : AbstractTwinmeViewController

@property (nullable, weak, nonatomic) id<AddCallParticipantDelegate> addCallParticipantDelegate;
@property (nonnull) NSMutableArray<NSUUID *> *participantsUUID;
@property (nonatomic) int maxMemberCount;

@end
