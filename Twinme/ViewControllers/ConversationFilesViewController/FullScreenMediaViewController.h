/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: FullScreenMediaDelegate
//

@protocol FullScreenMediaDelegate <NSObject>

- (void)didTapContent;

@end

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@interface FullScreenMediaViewController : AbstractTwinmeViewController

- (void)initWithItems:(NSMutableArray *)items atIndex:(int)index conversationId:(NSUUID *)conversationId originator:(id<TLOriginator>)originator;

@end
