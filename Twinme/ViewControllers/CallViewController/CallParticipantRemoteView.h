/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractCallParticipantView.h"

//
// Interface: CallParticipantRemoteView
//

@interface CallParticipantRemoteView : AbstractCallParticipantView

@property (nonatomic) CallParticipant *callParticipant;
@property (nonatomic) UIColor *color;

@end
